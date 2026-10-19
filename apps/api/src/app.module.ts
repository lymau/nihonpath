import { Module } from '@nestjs/common';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { ClockModule } from './common/clock/clock.module.js';
import { ConfigModule } from './common/config/config.module.js';
import { LoggingModule } from './common/logging/logging.module.js';
import { LoggingInterceptor } from './common/logging/logging.interceptor.js';
import { Rfc9457ExceptionFilter } from './common/errors/rfc9457-exception.filter.js';
import { HealthModule } from './modules/health/health.module.js';

@Module({
  imports: [ClockModule, ConfigModule.forRoot(), LoggingModule, HealthModule],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
    {
      provide: APP_FILTER,
      useClass: Rfc9457ExceptionFilter,
    },
  ],
})
export class AppModule {}
