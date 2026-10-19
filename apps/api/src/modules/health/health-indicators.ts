import { Injectable } from '@nestjs/common';
import pg from 'pg';
import { Redis } from 'ioredis';
import { AppConfigService } from '../../common/config/config.service.js';

export const DB_HEALTH_CHECKER = Symbol('DB_HEALTH_CHECKER');
export const REDIS_HEALTH_CHECKER = Symbol('REDIS_HEALTH_CHECKER');

export interface HealthChecker {
  check(): Promise<boolean>;
}

@Injectable()
export class DefaultDatabaseHealthChecker implements HealthChecker {
  private pool: pg.Pool | null = null;

  constructor(private readonly config: AppConfigService) {}

  async check(): Promise<boolean> {
    try {
      if (!this.pool) {
        this.pool = new pg.Pool({
          connectionString: this.config.get('DATABASE_URL'),
          connectionTimeoutMillis: 2000,
          max: 1,
        });
      }
      const client = await this.pool.connect();
      try {
        await client.query('SELECT 1');
        return true;
      } finally {
        client.release();
      }
    } catch {
      return false;
    }
  }

  async close(): Promise<void> {
    if (this.pool) {
      await this.pool.end();
      this.pool = null;
    }
  }
}

@Injectable()
export class DefaultRedisHealthChecker implements HealthChecker {
  private client: Redis | null = null;

  constructor(private readonly config: AppConfigService) {}

  async check(): Promise<boolean> {
    try {
      if (!this.client) {
        this.client = new Redis(this.config.get('REDIS_URL'), {
          connectTimeout: 2000,
          maxRetriesPerRequest: 1,
          lazyConnect: true,
          retryStrategy: () => null, // Do not auto-reconnect continuously on check failure
        });
        await this.client.connect();
      }
      const pong = await this.client.ping();
      return pong === 'PONG';
    } catch {
      return false;
    }
  }

  async close(): Promise<void> {
    if (this.client) {
      this.client.disconnect();
      this.client = null;
    }
  }
}
