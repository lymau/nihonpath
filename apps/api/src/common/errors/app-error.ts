import { HttpException, HttpStatus } from '@nestjs/common';
import type { components } from '../../types/api.generated.js';

export type ErrorCode = components['schemas']['ErrorCode'];
export type InvalidParam = components['schemas']['InvalidParam'];
export type ProblemDetails = components['schemas']['ProblemDetails'];

export interface AppExceptionOptions {
  code: ErrorCode;
  status?: HttpStatus;
  title?: string;
  detail: string;
  type?: string;
  invalidParams?: InvalidParam[];
}

export class AppException extends HttpException {
  public readonly code: ErrorCode;
  public readonly title: string;
  public readonly typeUri: string;
  public readonly invalidParams?: InvalidParam[];

  constructor(options: AppExceptionOptions) {
    const status = options.status ?? HttpStatus.BAD_REQUEST;
    super(options.detail, status);
    this.code = options.code;
    this.title = options.title ?? getTitleForStatus(status);
    this.typeUri =
      options.type ??
      `https://api.nihonpath.com/errors/${options.code.toLowerCase().replace(/_/g, '-')}`;
    this.invalidParams = options.invalidParams;
  }
}

export class ValidationException extends AppException {
  constructor(detail: string, invalidParams?: InvalidParam[]) {
    super({
      code: 'VALIDATION_FAILED',
      status: HttpStatus.BAD_REQUEST,
      title: 'Validation Failed',
      detail,
      invalidParams,
    });
  }
}

export class UnauthorizedException extends AppException {
  constructor(detail = 'Authentication is required and failed or was not provided.') {
    super({
      code: 'AUTH_INVALID_TOKEN',
      status: HttpStatus.UNAUTHORIZED,
      title: 'Unauthorized',
      detail,
    });
  }
}

export class NotFoundException extends AppException {
  constructor(detail = 'Requested resource was not found.') {
    super({
      code: 'CONTENT_NOT_FOUND',
      status: HttpStatus.NOT_FOUND,
      title: 'Not Found',
      detail,
    });
  }
}

export class RateLimitedException extends AppException {
  constructor(detail = 'Rate limit quota exceeded. Please try again later.') {
    super({
      code: 'RATE_LIMITED',
      status: HttpStatus.TOO_MANY_REQUESTS,
      title: 'Rate Limited',
      detail,
    });
  }
}

export class InternalException extends AppException {
  constructor(detail = 'An unexpected internal server error occurred.') {
    super({
      code: 'INTERNAL',
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      title: 'Internal Server Error',
      detail,
    });
  }
}

function getTitleForStatus(status: number): string {
  switch (status) {
    case 400:
      return 'Bad Request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not Found';
    case 409:
      return 'Conflict';
    case 422:
      return 'Unprocessable Entity';
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
