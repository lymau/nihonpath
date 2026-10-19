import { randomBytes } from 'node:crypto';
import { trace, context } from '@opentelemetry/api';

export interface TraceContext {
  traceId: string;
  spanId: string;
}

/**
 * Parses W3C traceparent header value (§10.4):
 * format: 00-{trace_id(32 hex)}-{span_id(16 hex)}-{flags(2 hex)}
 */
export function parseTraceParent(headerValue?: string | string[]): TraceContext | null {
  if (!headerValue) return null;
  const value = Array.isArray(headerValue) ? headerValue[0] : headerValue;
  if (!value || typeof value !== 'string') return null;

  const parts = value.trim().split('-');
  if (parts.length === 4 && parts[0] === '00') {
    const traceId = parts[1];
    const spanId = parts[2];
    if (
      traceId &&
      spanId &&
      /^[0-9a-f]{32}$/i.test(traceId) &&
      /^[0-9a-f]{16}$/i.test(spanId) &&
      traceId !== '00000000000000000000000000000000'
    ) {
      return {
        traceId: traceId.toLowerCase(),
        spanId: spanId.toLowerCase(),
      };
    }
  }
  return null;
}

/**
 * Retrieves the currently active span context from OpenTelemetry API.
 */
export function getActiveSpanContext(): TraceContext | null {
  const activeSpan = trace.getSpan(context.active());
  if (!activeSpan) return null;

  const spanContext = activeSpan.spanContext();
  if (
    !spanContext ||
    !spanContext.traceId ||
    spanContext.traceId === '00000000000000000000000000000000'
  ) {
    return null;
  }

  return {
    traceId: spanContext.traceId,
    spanId: spanContext.spanId,
  };
}

/**
 * Generates a fallback 128-bit (32 hex) trace ID.
 */
export function generateTraceId(): string {
  return randomBytes(16).toString('hex');
}

/**
 * Generates a fallback 64-bit (16 hex) span ID.
 */
export function generateSpanId(): string {
  return randomBytes(8).toString('hex');
}

/**
 * Resolves trace context for a request by checking active span,
 * traceparent header, or creating a new trace context.
 */
export function resolveTraceContext(traceparentHeader?: string | string[]): TraceContext {
  const active = getActiveSpanContext();
  if (active) {
    return active;
  }

  const fromHeader = parseTraceParent(traceparentHeader);
  if (fromHeader) {
    return fromHeader;
  }

  return {
    traceId: generateTraceId(),
    spanId: generateSpanId(),
  };
}
