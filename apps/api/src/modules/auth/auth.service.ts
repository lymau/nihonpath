import { Inject, Injectable } from '@nestjs/common';
import { sql, type Transaction } from 'kysely';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import type { components } from '../../types/api.generated.js';
import { PinoLoggerService } from '../../common/logging/pino.logger.js';
import { CLOCK } from '../../common/clock/clock.interface.js';
import type { Clock } from '../../common/clock/clock.interface.js';
import {
  RefreshTokenReusedException,
  UnauthorizedException,
} from '../../common/errors/app-error.js';
import { AuthDatabase } from './auth-database.js';
import { AuthMetrics } from './auth-metrics.js';
import { ACCESS_TOKEN_TTL_SECONDS, AuthTokenService } from './auth-token.service.js';
import type { Database } from '../../db/types.js';

type GuestRequest = components['schemas']['GuestAuthRequest'];
type AuthResponse = components['schemas']['AuthResponse'];

const REFRESH_TOKEN_TTL_DAYS = 30;

@Injectable()
export class AuthService {
  constructor(
    private readonly database: AuthDatabase,
    private readonly tokenService: AuthTokenService,
    private readonly metrics: AuthMetrics,
    private readonly logger: PinoLoggerService,
    @Inject(CLOCK) private readonly clock: Clock,
  ) {}

  async createGuest(input: GuestRequest): Promise<AuthResponse> {
    try {
      const userId = randomUUID();
      const familyId = randomUUID();
      const refreshTokenId = randomUUID();
      const now = this.clock.now();
      const refreshToken = createRefreshToken();
      const response = this.createAuthResponse(userId, input.device_id, refreshToken);

      await this.database.db.transaction().execute(async (trx) => {
        await trx.insertInto('users').values({ id: userId, is_guest: true }).execute();
        await trx
          .insertInto('devices')
          .values({
            id: input.device_id,
            user_id: userId,
            platform: input.platform,
            app_version: input.app_version ?? null,
            os_version: input.os_version ?? null,
            push_token: null,
            last_seen_at: now,
          })
          .execute();
        await trx
          .insertInto('refresh_tokens')
          .values({
            id: refreshTokenId,
            user_id: userId,
            device_id: input.device_id,
            family_id: familyId,
            token_hash: hashRefreshToken(refreshToken),
            expires_at: expiresAt(now),
            revoked_at: null,
            replaced_by: null,
          })
          .execute();
      });

      this.metrics.recordGuestLogin('success');
      this.logger.log({ event: 'auth.guest_created', provider: 'guest' });
      return response;
    } catch (error) {
      this.metrics.recordGuestLogin('failure');
      throw error;
    }
  }

  async refresh(refreshToken: string): Promise<AuthResponse> {
    const now = this.clock.now();
    const hash = hashRefreshToken(refreshToken);
    const outcome = await this.database.db.transaction().execute(async (trx) => {
      const candidate = await trx
        .selectFrom('refresh_tokens')
        .select(['id', 'family_id'])
        .where('token_hash', '=', hash)
        .executeTakeFirst();

      if (!candidate) {
        return { kind: 'invalid' } as const;
      }

      await lockTokenFamily(trx, candidate.family_id);
      const current = await trx
        .selectFrom('refresh_tokens')
        .selectAll()
        .where('id', '=', candidate.id)
        .forUpdate()
        .executeTakeFirst();
      if (!current) return { kind: 'invalid' } as const;

      if (current.revoked_at) {
        await trx
          .updateTable('refresh_tokens')
          .set({ revoked_at: now })
          .where('user_id', '=', current.user_id)
          .where('family_id', '=', current.family_id)
          .where('revoked_at', 'is', null)
          .execute();
        return { kind: 'reused' } as const;
      }

      if (new Date(current.expires_at).getTime() <= now.getTime()) {
        return { kind: 'invalid' } as const;
      }

      const nextToken = createRefreshToken();
      const nextTokenId = randomUUID();
      await trx
        .insertInto('refresh_tokens')
        .values({
          id: nextTokenId,
          user_id: current.user_id,
          device_id: current.device_id,
          family_id: current.family_id,
          token_hash: hashRefreshToken(nextToken),
          expires_at: expiresAt(now),
          revoked_at: null,
          replaced_by: null,
        })
        .execute();
      await trx
        .updateTable('refresh_tokens')
        .set({ revoked_at: now, replaced_by: nextTokenId })
        .where('id', '=', current.id)
        .execute();

      return {
        kind: 'success',
        response: this.createAuthResponse(current.user_id, current.device_id, nextToken),
      } as const;
    });

    if (outcome.kind === 'reused') {
      this.metrics.recordRefreshReuse();
      this.logger.log({ event: 'auth.refresh_reuse_detected' });
      throw new RefreshTokenReusedException();
    }
    if (outcome.kind === 'invalid') {
      throw new UnauthorizedException('The refresh token is invalid or expired.');
    }
    return outcome.response;
  }

  async logout(refreshToken: string): Promise<void> {
    const now = this.clock.now();
    const hash = hashRefreshToken(refreshToken);
    const loggedOut = await this.database.db.transaction().execute(async (trx) => {
      const current = await trx
        .selectFrom('refresh_tokens')
        .select(['user_id', 'family_id'])
        .where('token_hash', '=', hash)
        .executeTakeFirst();
      if (!current) return false;

      await lockTokenFamily(trx, current.family_id);
      await trx
        .updateTable('refresh_tokens')
        .set({ revoked_at: now })
        .where('user_id', '=', current.user_id)
        .where('family_id', '=', current.family_id)
        .where('revoked_at', 'is', null)
        .execute();
      return true;
    });

    if (!loggedOut) {
      throw new UnauthorizedException('The refresh token is invalid.');
    }
  }

  private createAuthResponse(userId: string, deviceId: string, refreshToken: string): AuthResponse {
    return {
      user_id: userId,
      access_token: this.tokenService.createAccessToken(userId, deviceId, this.clock.now()),
      refresh_token: refreshToken,
      expires_in: ACCESS_TOKEN_TTL_SECONDS,
      token_type: 'Bearer',
    };
  }
}

function createRefreshToken(): string {
  return randomBytes(32).toString('base64url');
}

function hashRefreshToken(token: string): Buffer {
  return createHash('sha256').update(token, 'utf8').digest();
}

function expiresAt(now: Date): Date {
  return new Date(now.getTime() + REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);
}

async function lockTokenFamily(trx: Transaction<Database>, familyId: string): Promise<void> {
  await sql`SELECT pg_advisory_xact_lock(hashtextextended(${familyId}, 0))`.execute(trx);
}
