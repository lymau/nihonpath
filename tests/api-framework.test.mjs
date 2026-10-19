import test from 'node:test';
import assert from 'node:assert/strict';
import { Writable } from 'node:stream';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter } from '@nestjs/platform-fastify';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');
const apiDir = resolve(rootDir, 'apps/api');
const apiDistDir = resolve(apiDir, 'dist');

// Always compile apps/api TypeScript to dist/ to guarantee fresh test artifacts
const isWindows = process.platform === 'win32';
const npxCmd = isWindows ? 'npx.cmd' : 'npx';
const buildResult = spawnSync(npxCmd, ['tsc', '-p', 'apps/api/tsconfig.json'], {
  cwd: rootDir,
  encoding: 'utf-8',
  shell: isWindows,
});
if (buildResult.status !== 0) {
  throw new Error(`Failed to compile apps/api: ${buildResult.stderr || buildResult.stdout}`);
}

// Setup minimal valid environment for testing
const validEnv = {
  NODE_ENV: 'test',
  PORT: '3000',
  DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/nihonpath_test',
  REDIS_URL: 'redis://localhost:6379',
  USER_HASH_SECRET: 'test-super-secret-user-hash-key-32chars!',
  SERVICE_NAME: 'nihonpath-api-test',
  APP_VERSION: '0.1.0',
  LOG_LEVEL: 'info',
};

// Ensure process.env has minimal valid env for module instantiation during tests
for (const [key, value] of Object.entries(validEnv)) {
  process.env[key] = value;
}

const { validateEnv, ConfigValidationError } =
  await import('../apps/api/dist/common/config/index.js');

const { SystemClock, MockClock } = await import('../apps/api/dist/common/clock/index.js');

const { computeUserHash, sanitizeIp, sanitizeLogData, PinoLoggerService } =
  await import('../apps/api/dist/common/logging/index.js');

const { parseTraceParent, resolveTraceContext } =
  await import('../apps/api/dist/common/telemetry/index.js');

const { ValidationException, RateLimitedException, Rfc9457ExceptionFilter } =
  await import('../apps/api/dist/common/errors/index.js');

const { AppModule } = await import('../apps/api/dist/app.module.js');
const { DB_HEALTH_CHECKER, REDIS_HEALTH_CHECKER } =
  await import('../apps/api/dist/modules/health/health-indicators.js');

test('Config validation: throws error when mandatory environment variables are missing (§14.2, M1-1)', () => {
  // Missing DATABASE_URL
  assert.throws(
    () => {
      validateEnv({
        REDIS_URL: 'redis://localhost:6379',
        USER_HASH_SECRET: 'test-secret-at-least-16-characters',
      });
    },
    (err) => {
      assert.ok(err instanceof ConfigValidationError);
      assert.ok(err.message.includes('DATABASE_URL'));
      return true;
    },
  );

  // Missing REDIS_URL
  assert.throws(
    () => {
      validateEnv({
        DATABASE_URL: 'postgresql://localhost:5432/db',
        USER_HASH_SECRET: 'test-secret-at-least-16-characters',
      });
    },
    (err) => {
      assert.ok(err instanceof ConfigValidationError);
      assert.ok(err.message.includes('REDIS_URL'));
      return true;
    },
  );

  // Missing or short USER_HASH_SECRET (< 16 chars)
  assert.throws(
    () => {
      validateEnv({
        DATABASE_URL: 'postgresql://localhost:5432/db',
        REDIS_URL: 'redis://localhost:6379',
        USER_HASH_SECRET: 'short',
      });
    },
    (err) => {
      assert.ok(err instanceof ConfigValidationError);
      assert.ok(err.message.includes('USER_HASH_SECRET'));
      return true;
    },
  );

  // Valid config succeeds with applied defaults
  const parsed = validateEnv(validEnv);
  assert.equal(parsed.NODE_ENV, 'test');
  assert.equal(parsed.PORT, 3000);
  assert.equal(parsed.HOST, '0.0.0.0');
  assert.equal(parsed.SERVICE_NAME, 'nihonpath-api-test');
  assert.equal(parsed.APP_VERSION, '0.1.0');
  assert.equal(parsed.LOG_LEVEL, 'info');
  assert.equal(parsed.CORS_ORIGIN, '*');
});

test('Clock abstraction: provides UTC time and deterministic mocking (§0 Aturan 5, M1-1)', () => {
  const systemClock = new SystemClock();
  const date = systemClock.now();
  assert.ok(date instanceof Date);
  assert.ok(typeof systemClock.nowEpochMs() === 'number');
  assert.ok(typeof systemClock.nowIso() === 'string');

  const frozenTime = '2026-10-19T12:00:00.000Z';
  const mockClock = new MockClock(frozenTime);
  assert.equal(mockClock.nowIso(), frozenTime);
  assert.equal(mockClock.nowEpochMs(), new Date(frozenTime).getTime());

  mockClock.advanceByMs(5000);
  assert.equal(mockClock.nowIso(), '2026-10-19T12:00:05.000Z');
});

test('Telemetry & W3C Trace Context: parses traceparent and resolves context (§10.4, M1-1)', () => {
  const validTraceparent = '00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01';
  const parsed = parseTraceParent(validTraceparent);
  assert.ok(parsed !== null);
  assert.equal(parsed.traceId, '4bf92f3577b34da6a3ce929d0e0e4736');
  assert.equal(parsed.spanId, '00f067aa0ba902b7');

  // Invalid traceparent returns null and falls back to generated IDs
  assert.equal(parseTraceParent('invalid-traceparent'), null);
  assert.equal(parseTraceParent(''), null);

  const resolved = resolveTraceContext();
  assert.ok(/^[0-9a-f]{32}$/.test(resolved.traceId));
  assert.ok(/^[0-9a-f]{16}$/.test(resolved.spanId));
});

test('PII filter and user_hash: redacts sensitive data and masks IPs (§10.2, M1-1)', () => {
  const secret = 'super-secret-key-for-hmac-sha256-test';
  const hash1 = computeUserHash('user-12345', secret);
  const hash2 = computeUserHash('user-12345', secret);
  assert.equal(hash1, hash2, 'HMAC must be deterministic');
  assert.ok(/^[0-9a-f]{64}$/.test(hash1 || ''), 'HMAC must be 64-char sha256 hex');
  assert.equal(computeUserHash(null, secret), null);

  // IP sanitization: masks IPv4 to /24 and IPv6 to /48
  assert.equal(sanitizeIp('192.168.1.155'), '192.168.1.0/24');
  assert.equal(sanitizeIp('10.0.50.22'), '10.0.50.0/24');
  assert.equal(sanitizeIp('2001:0db8:85a3:0000:0000:8a2e:0370:7334'), '2001:0db8:85a3::/48');

  // PII data sanitization
  const sensitivePayload = {
    email: 'learner@example.com',
    token: 'jwt.secret.token',
    authorization: 'Bearer sensitive-token',
    otp: '123456',
    password: 'super-password',
    ip: '192.168.10.42',
    user_answer: 'Tokyo wa ookii desu',
    sync_payload: [
      { op_id: '1', type: 'review_log' },
      { op_id: '2', type: 'card_state' },
    ],
    nested: {
      user_email: 'nested@example.com',
      auth_token: 'secret123',
    },
    safe_field: 'JLPT N5 Lesson 1',
  };

  const sanitized = sanitizeLogData(sensitivePayload);
  assert.equal(sanitized.email, '[REDACTED]');
  assert.equal(sanitized.token, '[REDACTED]');
  assert.equal(sanitized.authorization, '[REDACTED]');
  assert.equal(sanitized.otp, '[REDACTED]');
  assert.equal(sanitized.password, '[REDACTED]');
  assert.equal(sanitized.ip, '192.168.10.0/24');
  assert.equal(sanitized.user_answer, '[REDACTED]');
  assert.equal(sanitized.sync_payload, '[SYNC_PAYLOAD_REDACTED: 2 ops]');
  assert.equal(sanitized.nested.user_email, '[REDACTED]');
  assert.equal(sanitized.nested.auth_token, '[REDACTED]');
  assert.equal(sanitized.safe_field, 'JLPT N5 Lesson 1');
});

test('Pino logger: includes trace_id, 12 mandatory fields, and avoids PII leaks (§10.2, M1-1)', () => {
  const logEntries = [];
  const testStream = new Writable({
    write(chunk, encoding, callback) {
      try {
        const line = chunk.toString().trim();
        if (line) {
          logEntries.push(JSON.parse(line));
        }
      } catch {
        // ignore non-json
      }
      callback();
    },
  });

  const mockConfigService = {
    get(key) {
      return validEnv[key] || '';
    },
    isProduction: false,
  };

  const loggerService = new PinoLoggerService(mockConfigService, testStream);

  loggerService.logRequest({
    trace_id: '4bf92f3577b34da6a3ce929d0e0e4736',
    span_id: '00f067aa0ba902b7',
    route: 'GET /healthz',
    status: 200,
    latency_ms: 12,
    user_id: 'user-uuid-12345',
    extra: {
      email: 'test@example.com',
      ip: '172.16.5.99',
    },
  });

  assert.equal(logEntries.length, 1);
  const entry = logEntries[0];

  // Verify all 12 mandatory fields from §10.2
  const requiredFields = [
    'ts',
    'level',
    'service',
    'env',
    'version',
    'trace_id',
    'span_id',
    'route',
    'status',
    'latency_ms',
    'error_code',
    'user_hash',
  ];

  for (const field of requiredFields) {
    assert.ok(field in entry, `Missing mandatory field in Pino log: ${field}`);
  }

  assert.equal(entry.trace_id, '4bf92f3577b34da6a3ce929d0e0e4736');
  assert.equal(entry.span_id, '00f067aa0ba902b7');
  assert.equal(entry.route, 'GET /healthz');
  assert.equal(entry.status, 200);
  assert.equal(entry.latency_ms, 12);
  assert.equal(entry.service, 'nihonpath-api-test');
  assert.equal(entry.env, 'test');
  assert.equal(entry.version, '0.1.0');
  assert.equal(entry.error_code, null);
  assert.ok(/^[0-9a-f]{64}$/.test(entry.user_hash));

  // PII must be redacted in extra
  assert.equal(entry.email, '[REDACTED]');
  assert.equal(entry.ip, '172.16.5.0/24');
});

test('RFC 9457 Exception Filter: formats errors to application/problem+json (§8.1, §8.4, M1-1)', () => {
  const filter = new Rfc9457ExceptionFilter();

  let capturedStatus = 0;
  const capturedHeaders = {};
  let capturedBody = null;

  const mockReply = {
    status(code) {
      capturedStatus = code;
      return this;
    },
    header(name, value) {
      capturedHeaders[name] = value;
      return this;
    },
    send(body) {
      capturedBody = body;
      return this;
    },
  };

  const mockRequest = {
    url: '/v1/sync/push',
    method: 'POST',
    headers: {
      traceparent: '00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01',
    },
  };

  const mockHost = {
    switchToHttp: () => ({
      getRequest: () => mockRequest,
      getResponse: () => mockReply,
    }),
  };

  // Test 1: ValidationException
  const validationError = new ValidationException('Invalid payload schema', [
    { name: 'device_id', reason: 'Field must be a valid UUID' },
  ]);

  filter.catch(validationError, mockHost);

  assert.equal(capturedStatus, 400);
  assert.equal(capturedHeaders['Content-Type'], 'application/problem+json; charset=utf-8');
  assert.equal(capturedHeaders['X-Trace-Id'], '4bf92f3577b34da6a3ce929d0e0e4736');
  assert.equal(capturedBody.code, 'VALIDATION_FAILED');
  assert.equal(capturedBody.status, 400);
  assert.equal(capturedBody.title, 'Validation Failed');
  assert.equal(capturedBody.instance, '/v1/sync/push');
  assert.equal(capturedBody.trace_id, '4bf92f3577b34da6a3ce929d0e0e4736');
  assert.deepEqual(capturedBody.invalid_params, [
    { name: 'device_id', reason: 'Field must be a valid UUID' },
  ]);

  // Test 2: RateLimitedException
  filter.catch(new RateLimitedException(), mockHost);
  assert.equal(capturedStatus, 429);
  assert.equal(capturedBody.code, 'RATE_LIMITED');
  assert.equal(capturedBody.title, 'Rate Limited');

  // Test 3: Generic unexpected Error
  filter.catch(new Error('Database query timed out'), mockHost);
  assert.equal(capturedStatus, 500);
  assert.equal(capturedBody.code, 'INTERNAL');
  assert.equal(capturedBody.title, 'Internal Server Error');
  assert.equal(capturedBody.trace_id, '4bf92f3577b34da6a3ce929d0e0e4736');
});

test('Integration: GET /healthz and GET /readyz endpoints with Fastify adapter (§8.2, M1-1)', async () => {
  // Create mock health checkers for isolated deterministic testing
  let dbStatus = true;
  let redisStatus = true;

  const mockDbChecker = {
    async check() {
      return dbStatus;
    },
  };

  const mockRedisChecker = {
    async check() {
      return redisStatus;
    },
  };

  const app = await NestFactory.create(AppModule, new FastifyAdapter({ logger: false }), {
    logger: false,
  });

  // Override health checkers with test mocks
  app.get(DB_HEALTH_CHECKER).check = mockDbChecker.check;
  app.get(REDIS_HEALTH_CHECKER).check = mockRedisChecker.check;

  await app.init();
  const fastify = app.getHttpAdapter().getInstance();

  try {
    // 1. Test GET /healthz (liveness)
    const healthzRes = await fastify.inject({
      method: 'GET',
      url: '/healthz',
    });

    assert.equal(healthzRes.statusCode, 200);
    const healthzBody = JSON.parse(healthzRes.payload);
    assert.equal(healthzBody.status, 'ok');
    assert.ok(healthzBody.timestamp, 'timestamp must be present');
    assert.ok(healthzRes.headers['x-trace-id'], 'X-Trace-Id header must be set');

    // 2. Test GET /readyz when all healthy
    dbStatus = true;
    redisStatus = true;

    const readyzRes = await fastify.inject({
      method: 'GET',
      url: '/readyz',
    });

    assert.equal(readyzRes.statusCode, 200);
    const readyzBody = JSON.parse(readyzRes.payload);
    assert.equal(readyzBody.status, 'ok');
    assert.equal(readyzBody.checks.database, 'up');
    assert.equal(readyzBody.checks.redis, 'up');

    // 3. Test GET /readyz when database is down
    dbStatus = false;
    redisStatus = true;

    const readyzDbDownRes = await fastify.inject({
      method: 'GET',
      url: '/readyz',
    });

    assert.equal(readyzDbDownRes.statusCode, 503);
    const readyzDbDownBody = JSON.parse(readyzDbDownRes.payload);
    assert.equal(readyzDbDownBody.status, 'down');
    assert.equal(readyzDbDownBody.checks.database, 'down');
    assert.equal(readyzDbDownBody.checks.redis, 'up');

    // 4. Test GET /readyz when Redis is down
    dbStatus = true;
    redisStatus = false;

    const readyzRedisDownRes = await fastify.inject({
      method: 'GET',
      url: '/readyz',
    });

    assert.equal(readyzRedisDownRes.statusCode, 503);
    const readyzRedisDownBody = JSON.parse(readyzRedisDownRes.payload);
    assert.equal(readyzRedisDownBody.status, 'down');
    assert.equal(readyzRedisDownBody.checks.database, 'up');
    assert.equal(readyzRedisDownBody.checks.redis, 'down');
  } finally {
    await app.close();
  }
});
