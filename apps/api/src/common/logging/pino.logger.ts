import { Injectable, LoggerService, Optional, Inject } from '@nestjs/common';
import pino, { type Logger as PinoInstance, type DestinationStream } from 'pino';
import { AppConfigService } from '../config/config.service.js';
import { computeUserHash, sanitizeLogData } from './pii-filter.js';
import {
  getActiveSpanContext,
  generateTraceId,
  generateSpanId,
} from '../telemetry/trace-context.js';

export const PINO_DESTINATION = Symbol('PINO_DESTINATION');

export interface StructuredRequestLog {
  ts: string;
  level: string;
  service: string;
  env: string;
  version: string;
  trace_id: string;
  span_id: string;
  route: string;
  status: number;
  latency_ms: number;
  error_code: string | null;
  user_hash: string | null;
  [key: string]: unknown;
}

export interface LogRequestParams {
  trace_id?: string;
  span_id?: string;
  route: string;
  status: number;
  latency_ms: number;
  error_code?: string | null;
  user_id?: string | null;
  extra?: Record<string, unknown>;
}

@Injectable()
export class PinoLoggerService implements LoggerService {
  private readonly logger: PinoInstance;

  constructor(
    private readonly config: AppConfigService,
    @Optional()
    @Inject(PINO_DESTINATION)
    destination?: DestinationStream,
  ) {
    const isProduction = this.config.isProduction;
    const logLevel = this.config.get('LOG_LEVEL') || 'info';

    this.logger = pino(
      {
        level: logLevel,
        formatters: {
          level: (label: string) => ({ level: label }),
        },
        redact: {
          paths: [
            '*.email',
            '*.*.email',
            '*.token',
            '*.accessToken',
            '*.refreshToken',
            '*.password',
            '*.otp',
            '*.authorization',
            '*.headers.authorization',
          ],
          censor: '[REDACTED]',
        },
      },
      destination ?? (isProduction ? pino.destination(1) : undefined),
    );
  }

  logRequest(params: LogRequestParams): void {
    const traceContext = getActiveSpanContext();
    const traceId = params.trace_id || traceContext?.traceId || generateTraceId();
    const spanId = params.span_id || traceContext?.spanId || generateSpanId();

    const userHash = computeUserHash(params.user_id, this.config.get('USER_HASH_SECRET'));

    const level = params.status >= 500 ? 'error' : params.status >= 400 ? 'warn' : 'info';

    const logEntry: StructuredRequestLog = {
      ts: new Date().toISOString(),
      level,
      service: this.config.get('SERVICE_NAME'),
      env: this.config.get('NODE_ENV'),
      version: this.config.get('APP_VERSION'),
      trace_id: traceId,
      span_id: spanId,
      route: params.route,
      status: params.status,
      latency_ms: params.latency_ms,
      error_code: params.error_code ?? null,
      user_hash: userHash,
    };

    if (params.extra) {
      const sanitizedExtra = sanitizeLogData(params.extra) as Record<string, unknown>;
      Object.assign(logEntry, sanitizedExtra);
    }

    if (level === 'error') {
      this.logger.error(logEntry);
    } else if (level === 'warn') {
      this.logger.warn(logEntry);
    } else {
      this.logger.info(logEntry);
    }
  }

  private writeLog(
    level: 'info' | 'error' | 'warn' | 'debug' | 'trace',
    message: unknown,
    optionalParams: unknown[],
  ): void {
    const sanitized = sanitizeLogData(message);
    const sanitizedParams = optionalParams.map(sanitizeLogData);

    if (typeof sanitized === 'string') {
      if (sanitizedParams.length > 0) {
        this.logger[level]({ params: sanitizedParams }, sanitized);
      } else {
        this.logger[level](sanitized);
      }
    } else if (typeof sanitized === 'object' && sanitized !== null) {
      if (sanitizedParams.length > 0) {
        this.logger[level]({ ...(sanitized as object), params: sanitizedParams });
      } else {
        this.logger[level](sanitized as object);
      }
    } else {
      this.logger[level](String(sanitized));
    }
  }

  log(message: unknown, ...optionalParams: unknown[]): void {
    this.writeLog('info', message, optionalParams);
  }

  error(message: unknown, ...optionalParams: unknown[]): void {
    this.writeLog('error', message, optionalParams);
  }

  warn(message: unknown, ...optionalParams: unknown[]): void {
    this.writeLog('warn', message, optionalParams);
  }

  debug(message: unknown, ...optionalParams: unknown[]): void {
    this.writeLog('debug', message, optionalParams);
  }

  verbose(message: unknown, ...optionalParams: unknown[]): void {
    this.writeLog('trace', message, optionalParams);
  }

  getPino(): PinoInstance {
    return this.logger;
  }
}
