import { Injectable } from '@nestjs/common';
import { createPrivateKey, createPublicKey, sign } from 'node:crypto';
import type { KeyObject } from 'node:crypto';
import { AppConfigService } from '../../common/config/config.service.js';

export const ACCESS_TOKEN_TTL_SECONDS = 900;

export interface PublicEcJwk {
  kty: string;
  crv: string;
  x: string;
  y: string;
}

@Injectable()
export class AuthTokenService {
  private readonly privateKey: KeyObject;
  private readonly publicJwk: PublicEcJwk;
  private readonly keyId: string;

  constructor(config: AppConfigService) {
    this.keyId = config.get('AUTH_JWT_KEY_ID');
    const pem = config.get('AUTH_JWT_PRIVATE_KEY').replace(/\\n/g, '\n');
    this.privateKey = createPrivateKey(pem);
    if (
      this.privateKey.asymmetricKeyType !== 'ec' ||
      this.privateKey.asymmetricKeyDetails?.namedCurve !== 'prime256v1'
    ) {
      throw new Error('AUTH_JWT_PRIVATE_KEY must be an ES256 P-256 private key');
    }

    const jwk = createPublicKey(this.privateKey).export({ format: 'jwk' });
    if (!jwk.kty || !jwk.crv || !jwk.x || !jwk.y) {
      throw new Error('Failed to derive public JWK from AUTH_JWT_PRIVATE_KEY');
    }
    this.publicJwk = { kty: jwk.kty, crv: jwk.crv, x: jwk.x, y: jwk.y };
  }

  createAccessToken(userId: string, deviceId: string, now: Date): string {
    const issuedAt = Math.floor(now.getTime() / 1000);
    const header = encode({
      alg: 'ES256',
      kid: this.keyId,
      typ: 'JWT',
    });
    const payload = encode({
      sub: userId,
      device_id: deviceId,
      iat: issuedAt,
      exp: issuedAt + ACCESS_TOKEN_TTL_SECONDS,
    });
    const signingInput = `${header}.${payload}`;
    const signature = sign('sha256', Buffer.from(signingInput), {
      key: this.privateKey,
      dsaEncoding: 'ieee-p1363',
    }).toString('base64url');
    return `${signingInput}.${signature}`;
  }

  jwks(): {
    keys: Array<PublicEcJwk & { use: string; alg: string; kid: string; key_ops: string[] }>;
  } {
    return {
      keys: [
        {
          ...this.publicJwk,
          use: 'sig',
          alg: 'ES256',
          kid: this.keyId,
          key_ops: ['verify'],
        },
      ],
    };
  }
}

function encode(value: Record<string, unknown>): string {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}
