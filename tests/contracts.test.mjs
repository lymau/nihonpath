import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { parse } from 'yaml';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const openapiPath = resolve(rootDir, 'packages/contracts/openapi.yaml');
const jsonSchemaDir = resolve(rootDir, 'packages/contracts/json-schema');
const tsGeneratedPath = resolve(rootDir, 'apps/api/src/types/api.generated.ts');
const dartApiDir = resolve(rootDir, 'apps/mobile/lib/data/api');

test('OpenAPI contract structure & compliance (§8.1, §8.2, RFC 9457)', () => {
  assert.ok(existsSync(openapiPath), 'openapi.yaml must exist');
  const yamlContent = readFileSync(openapiPath, 'utf-8');
  const doc = parse(yamlContent);

  // Basic OpenAPI checks
  assert.equal(doc.openapi, '3.0.3');
  assert.equal(doc.info.title, 'NihonPath API');

  // Required endpoints (§8.2)
  const paths = Object.keys(doc.paths);
  const requiredEndpoints = [
    '/auth/guest',
    '/config',
    '/content/manifest',
    '/sync/push',
    '/sync/pull',
  ];
  for (const ep of requiredEndpoints) {
    assert.ok(paths.includes(ep), `Missing required endpoint: ${ep}`);
  }

  // RFC 9457 error schema (§8.1, §8.4)
  const schemas = doc.components.schemas;
  assert.ok(schemas.ProblemDetails, 'ProblemDetails schema must exist');
  assert.ok(schemas.ProblemDetails.required.includes('code'), 'code is required in ProblemDetails');
  assert.ok(
    schemas.ProblemDetails.required.includes('trace_id'),
    'trace_id is required in ProblemDetails',
  );

  // ErrorCode enum (§8.4)
  const expectedCodes = [
    'AUTH_INVALID_TOKEN',
    'AUTH_REFRESH_REUSED',
    'VALIDATION_FAILED',
    'RATE_LIMITED',
    'SYNC_OP_REJECTED',
    'SYNC_CLOCK_INVALID',
    'CONTENT_NOT_FOUND',
    'ENTITLEMENT_REQUIRED',
    'APP_UPDATE_REQUIRED',
    'INTERNAL',
  ];
  assert.deepEqual(schemas.ErrorCode.enum, expectedCodes);
});

test('Content JSON Schemas (§9.1, §9.2)', () => {
  const schemaFiles = [
    'vocab.schema.json',
    'kanji.schema.json',
    'grammar.schema.json',
    'kana.schema.json',
    'content-item.schema.json',
  ];

  for (const file of schemaFiles) {
    const filePath = resolve(jsonSchemaDir, file);
    assert.ok(existsSync(filePath), `Schema file ${file} must exist`);
    const parsed = JSON.parse(readFileSync(filePath, 'utf-8'));
    assert.ok(parsed.$schema, `$schema must be defined in ${file}`);
    assert.ok(parsed.title, `title must be defined in ${file}`);
  }
});

test('Generated TypeScript types integrity & compilation (§0 Aturan 2)', () => {
  assert.ok(existsSync(tsGeneratedPath), 'api.generated.ts must exist');
  const tsContent = readFileSync(tsGeneratedPath, 'utf-8');
  assert.ok(tsContent.includes('export interface paths'), 'paths interface must be exported');
  assert.ok(tsContent.includes("'/auth/guest'"), 'guest auth path must be defined');
  assert.ok(tsContent.includes("'/sync/push'"), 'sync push path must be defined');

  // TypeScript compiler check
  const isWindows = process.platform === 'win32';
  const tscCmd = isWindows ? 'npx.cmd' : 'npx';
  const tscCheck = spawnSync(tscCmd, ['tsc', '--noEmit'], {
    cwd: resolve(rootDir, 'apps/api'),
    encoding: 'utf-8',
    shell: isWindows,
  });
  assert.equal(tscCheck.status, 0, `tsc --noEmit failed: ${tscCheck.stderr || tscCheck.stdout}`);
});

test('Generated Dart client integrity & compilation (§0 Aturan 2)', (t) => {
  const libFile = resolve(dartApiDir, 'lib/nihonpath_api.dart');
  assert.ok(existsSync(libFile), 'nihonpath_api.dart must exist');

  // Check if dart is available on PATH (may be absent in Node-only CI environments)
  const isWindows = process.platform === 'win32';
  const dartAvailable = spawnSync('dart', ['--version'], { shell: isWindows });
  if (dartAvailable.status !== 0 || !dartAvailable.status === null) {
    t.skip('Dart SDK is not installed in this environment; skipping dart analyze check.');
    return;
  }

  // Ensure packages are resolved
  spawnSync('dart', ['pub', 'get'], { cwd: dartApiDir, shell: isWindows });

  // Dart analyze check
  const dartCheck = spawnSync('dart', ['analyze', '.'], {
    cwd: dartApiDir,
    encoding: 'utf-8',
    shell: isWindows,
  });
  assert.equal(dartCheck.status, 0, `dart analyze failed: ${dartCheck.stderr || dartCheck.stdout}`);
});

test('Verification fails when generated contract files have manual modifications (§0 Aturan 2)', () => {
  const tsContent = readFileSync(tsGeneratedPath, 'utf-8');
  try {
    // Stage the file first to ensure git diff tracks modifications
    const isWindows = process.platform === 'win32';
    spawnSync('git', ['add', tsGeneratedPath], { cwd: rootDir, shell: isWindows });

    writeFileSync(tsGeneratedPath, tsContent + '\n// Manual unauthorized edit\n', 'utf-8');
    const verifyScript = resolve(rootDir, 'scripts/verify-contracts.mjs');
    const result = spawnSync('node', [verifyScript], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
    });
    assert.notEqual(result.status, 0, 'Verification must fail when generated file is modified');
  } finally {
    writeFileSync(tsGeneratedPath, tsContent, 'utf-8');
  }
});
