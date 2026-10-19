import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Optional,
} from '@nestjs/common';
import type { FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import {
  AppException,
  type ErrorCode,
  type InvalidParam,
  type ProblemDetails,
} from './app-error.js';
import { resolveTraceContext } from '../telemetry/trace-context.js';
import { PinoLoggerService } from '../logging/pino.logger.js';

interface RequestWithTrace extends FastifyRequest {
  traceContext?: { traceId: string; spanId: string };
  user?: { id?: string; user_id?: string };
}

@Catch()
export class Rfc9457ExceptionFilter implements ExceptionFilter {
  constructor(@Optional() private readonly pinoLogger?: PinoLoggerService) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest<RequestWithTrace>();
    const res = ctx.getResponse<FastifyReply>();

    // Resolve trace context from request or traceparent header
    const traceContext = req.traceContext || resolveTraceContext(req.headers?.['traceparent']);
    const traceId = traceContext.traceId;

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code: ErrorCode = 'INTERNAL';
    let title = 'Internal Server Error';
    let detail = 'An internal server error occurred.';
    let type = 'https://api.nihonpath.com/errors/internal';
    let invalidParams: InvalidParam[] | undefined = undefined;

    if (exception instanceof AppException) {
      status = exception.getStatus();
      code = exception.code;
      title = exception.title;
      detail = exception.message;
      type = exception.typeUri;
      invalidParams = exception.invalidParams;
    } else if (exception instanceof ZodError) {
      status = HttpStatus.BAD_REQUEST;
      code = 'VALIDATION_FAILED';
      title = 'Validation Failed';
      detail = 'The request payload failed schema validation.';
      type = 'https://api.nihonpath.com/errors/validation-failed';
      invalidParams = exception.issues.map((issue) => ({
        name: issue.path.join('.') || 'body',
        reason: issue.message,
      }));
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      title = this.mapStatusToTitle(status);
      code = this.mapStatusToCode(status);
      type = `https://api.nihonpath.com/errors/${code.toLowerCase().replace(/_/g, '-')}`;

      const response = exception.getResponse();
      if (typeof response === 'string') {
        detail = response;
      } else if (typeof response === 'object' && response !== null) {
        const respObj = response as Record<string, unknown>;
        if (typeof respObj.message === 'string') {
          detail = respObj.message;
        } else if (Array.isArray(respObj.message)) {
          detail = respObj.message.join('; ');
        }
      }
    } else if (exception instanceof Error) {
      // In non-production or for known safe errors, detail may provide error message
      detail = exception.message || detail;
    }

    const instance = req.url ? req.url.split('?')[0] : undefined;

    const problem: ProblemDetails = {
      type,
      title,
      status,
      detail,
      ...(instance ? { instance } : {}),
      code,
      trace_id: traceId,
      ...(invalidParams && invalidParams.length > 0 ? { invalid_params: invalidParams } : {}),
    };

    if (this.pinoLogger) {
      this.pinoLogger.error({
        msg: `Handled exception: ${detail}`,
        error_code: code,
        status,
        route: req.method && instance ? `${req.method} ${instance}` : 'UNKNOWN',
        trace_id: traceId,
        exception: exception instanceof Error ? exception.stack : String(exception),
      });
    }

    res.status(status);
    res.header('Content-Type', 'application/problem+json; charset=utf-8');
    res.header('X-Trace-Id', traceId);
    res.send(problem);
  }

  private mapStatusToCode(status: number): ErrorCode {
    switch (status) {
      case 400:
        return 'VALIDATION_FAILED';
      case 401:
        return 'AUTH_INVALID_TOKEN';
      case 403:
        return 'ENTITLEMENT_REQUIRED';
      case 404:
        return 'CONTENT_NOT_FOUND';
      case 429:
        return 'RATE_LIMITED';
      default:
        return 'INTERNAL';
    }
  }

  private mapStatusToTitle(status: number): string {
    switch (status) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Error';
    }
  }
}
