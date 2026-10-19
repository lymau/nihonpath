import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { PinoLoggerService } from './pino.logger.js';
import { resolveTraceContext } from '../telemetry/trace-context.js';

interface RequestWithUser extends FastifyRequest {
  user?: { id?: string; user_id?: string };
  traceContext?: { traceId: string; spanId: string };
}

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(private readonly pinoLogger: PinoLoggerService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const req = http.getRequest<RequestWithUser>();
    const res = http.getResponse<FastifyReply>();

    const startTime = performance.now();
    const traceContext = resolveTraceContext(req.headers['traceparent']);
    req.traceContext = traceContext;

    // Attach trace_id to response headers for debugging / client tracing
    if (res.header) {
      res.header('X-Trace-Id', traceContext.traceId);
    }

    const route = `${req.method} ${req.url.split('?')[0]}`;

    return next.handle().pipe(
      tap({
        next: () => {
          const latencyMs = Math.round(performance.now() - startTime);
          const statusCode = res.statusCode || 200;
          const userId = req.user?.id || req.user?.user_id || null;

          this.pinoLogger.logRequest({
            trace_id: traceContext.traceId,
            span_id: traceContext.spanId,
            route,
            status: statusCode,
            latency_ms: latencyMs,
            user_id: userId,
          });
        },
        error: (error: unknown) => {
          const latencyMs = Math.round(performance.now() - startTime);
          const statusCode =
            typeof error === 'object' &&
            error !== null &&
            'getStatus' in error &&
            typeof (error as { getStatus: () => number }).getStatus === 'function'
              ? (error as { getStatus: () => number }).getStatus()
              : 500;

          const errorCode =
            typeof error === 'object' && error !== null && 'code' in error
              ? String((error as { code: unknown }).code)
              : null;

          const userId = req.user?.id || req.user?.user_id || null;

          this.pinoLogger.logRequest({
            trace_id: traceContext.traceId,
            span_id: traceContext.spanId,
            route,
            status: statusCode,
            latency_ms: latencyMs,
            error_code: errorCode,
            user_id: userId,
          });
        },
      }),
    );
  }
}
