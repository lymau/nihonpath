import { z } from 'zod';

export const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default('0.0.0.0'),
  SERVICE_NAME: z.string().default('nihonpath-api'),
  APP_VERSION: z.string().default('0.1.0'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required and cannot be empty'),
  REDIS_URL: z.string().min(1, 'REDIS_URL is required and cannot be empty'),
  USER_HASH_SECRET: z
    .string()
    .min(16, 'USER_HASH_SECRET must be at least 16 characters for secure HMAC-SHA256'),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().optional().or(z.literal('')),
  CORS_ORIGIN: z.string().default('*'),
});

export type EnvConfig = z.infer<typeof EnvSchema>;

export class ConfigValidationError extends Error {
  constructor(public readonly issues: z.ZodIssue[]) {
    const formatted = issues.map((i) => `${i.path.join('.') || 'root'}: ${i.message}`).join('; ');
    super(`Config validation failed: ${formatted}`);
    this.name = 'ConfigValidationError';
  }
}

export function validateEnv(rawEnv: Record<string, unknown> = process.env): EnvConfig {
  const result = EnvSchema.safeParse(rawEnv);
  if (!result.success) {
    throw new ConfigValidationError(result.error.issues);
  }
  return result.data;
}
