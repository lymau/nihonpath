import { createHmac } from 'node:crypto';

/**
 * Computes HMAC-SHA256 of user_id using the secret key (§10.2).
 * Raw user_id is never stored directly in logs.
 */
export function computeUserHash(userId: string | null | undefined, secret: string): string | null {
  if (!userId) return null;
  return createHmac('sha256', secret).update(userId).digest('hex');
}

/**
 * Sanitizes IP addresses to prevent storing raw IP identifiers (§10.2).
 * Truncates IPv4 to /24 subnet (e.g., 192.168.1.0/24) and IPv6 to /48 subnet.
 */
export function sanitizeIp(ip: string | null | undefined): string | null {
  if (!ip) return null;
  const trimmed = ip.trim();

  // Match IPv4 embedded or standalone
  const ipv4Match = trimmed.match(/(?:\d{1,3}\.){3}\d{1,3}$/);
  if (ipv4Match) {
    const parts = ipv4Match[0].split('.');
    return `${parts[0]}.${parts[1]}.${parts[2]}.0/24`;
  }

  // IPv6
  if (trimmed.includes(':')) {
    const parts = trimmed.split(':').filter(Boolean);
    const prefix = parts.slice(0, 3).join(':');
    return prefix ? `${prefix}::/48` : null;
  }

  return null;
}

const PII_KEY_PATTERNS = [
  /^email$/i,
  /.*email.*/i,
  /^token$/i,
  /.*token.*/i,
  /^authorization$/i,
  /^password$/i,
  /.*password.*/i,
  /^otp$/i,
  /.*otp.*/i,
  /^code$/i,
  /^free_text$/i,
  /^free_response$/i,
  /^answer$/i,
  /.*answer.*/i,
  /^jawaban$/i,
];

const IP_KEY_PATTERNS = [/^ip$/i, /^client_ip$/i, /^remote_address$/i, /^x-forwarded-for$/i];

const SYNC_PAYLOAD_PATTERNS = [/^sync_payload$/i, /^ops$/i, /^sync_ops$/i];

/**
 * Recursively sanitizes any payload or object, redacting PII according to §10.2.
 */
export function sanitizeLogData(data: unknown, depth = 0): unknown {
  if (depth > 8 || data === null || data === undefined) {
    return data;
  }

  if (typeof data !== 'object') {
    return data;
  }

  if (Array.isArray(data)) {
    return data.map((item) => sanitizeLogData(item, depth + 1));
  }

  const result: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(data as Record<string, unknown>)) {
    // Check if key matches sync payload
    if (SYNC_PAYLOAD_PATTERNS.some((pattern) => pattern.test(key))) {
      if (Array.isArray(value)) {
        result[key] = `[SYNC_PAYLOAD_REDACTED: ${value.length} ops]`;
      } else {
        result[key] = '[SYNC_PAYLOAD_REDACTED]';
      }
      continue;
    }

    // Check if key matches IP
    if (IP_KEY_PATTERNS.some((pattern) => pattern.test(key))) {
      result[key] = typeof value === 'string' ? sanitizeIp(value) : '[REDACTED_IP]';
      continue;
    }

    // Check if key matches forbidden PII keywords
    if (PII_KEY_PATTERNS.some((pattern) => pattern.test(key))) {
      result[key] = '[REDACTED]';
      continue;
    }

    // Recurse into nested objects
    result[key] = sanitizeLogData(value, depth + 1);
  }

  return result;
}
