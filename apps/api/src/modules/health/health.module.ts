import { Module } from '@nestjs/common';
import { HealthController } from './health.controller.js';
import { HealthService } from './health.service.js';
import {
  DB_HEALTH_CHECKER,
  REDIS_HEALTH_CHECKER,
  DefaultDatabaseHealthChecker,
  DefaultRedisHealthChecker,
} from './health-indicators.js';

@Module({
  controllers: [HealthController],
  providers: [
    HealthService,
    {
      provide: DB_HEALTH_CHECKER,
      useClass: DefaultDatabaseHealthChecker,
    },
    {
      provide: REDIS_HEALTH_CHECKER,
      useClass: DefaultRedisHealthChecker,
    },
    DefaultDatabaseHealthChecker,
    DefaultRedisHealthChecker,
  ],
  exports: [HealthService, DB_HEALTH_CHECKER, REDIS_HEALTH_CHECKER],
})
export class HealthModule {}
