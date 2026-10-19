import { Global, Module } from '@nestjs/common';
import { PinoLoggerService } from './pino.logger.js';
import { LoggingInterceptor } from './logging.interceptor.js';

@Global()
@Module({
  providers: [PinoLoggerService, LoggingInterceptor],
  exports: [PinoLoggerService, LoggingInterceptor],
})
export class LoggingModule {}
