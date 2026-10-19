import { Injectable, Inject } from '@nestjs/common';
import { CLOCK, type Clock } from '../../common/clock/clock.interface.js';
import {
  DB_HEALTH_CHECKER,
  REDIS_HEALTH_CHECKER,
  type HealthChecker,
} from './health-indicators.js';

export interface LivenessResult {
  status: 'ok';
  timestamp: string;
}

export interface ReadinessResult {
  status: 'ok' | 'down';
  timestamp: string;
  checks: {
    database: 'up' | 'down';
    redis: 'up' | 'down';
  };
}

@Injectable()
export class HealthService {
  constructor(
    @Inject(CLOCK)
    private readonly clock: Clock,
    @Inject(DB_HEALTH_CHECKER)
    private readonly dbChecker: HealthChecker,
    @Inject(REDIS_HEALTH_CHECKER)
    private readonly redisChecker: HealthChecker,
  ) {}

  checkLiveness(): LivenessResult {
    return {
      status: 'ok',
      timestamp: this.clock.nowIso(),
    };
  }

  async checkReadiness(): Promise<ReadinessResult> {
    const [dbHealthy, redisHealthy] = await Promise.all([
      this.dbChecker.check().catch(() => false),
      this.redisChecker.check().catch(() => false),
    ]);

    const isHealthy = dbHealthy && redisHealthy;

    return {
      status: isHealthy ? 'ok' : 'down',
      timestamp: this.clock.nowIso(),
      checks: {
        database: dbHealthy ? 'up' : 'down',
        redis: redisHealthy ? 'up' : 'down',
      },
    };
  }
}
