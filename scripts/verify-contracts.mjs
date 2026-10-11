#!/usr/bin/env node

/**
 * scripts/verify-contracts.mjs
 *
 * Verifies that generated contract clients (TypeScript & Dart) are up-to-date,
 * not modified manually, and compile without errors (M0-2 / §0 Aturan 2).
 */

import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

function log(stage, message) {
  const ts = new Date().toISOString();
  // eslint-disable-next-line no-console
  console.log(`[${ts}] [verify:contracts] [${stage}] ${message}`);
}

function runCommand(command, args, cwd = rootDir) {
  const isWindows = process.platform === 'win32';
  const executable = isWindows && ['npx', 'npm', 'pnpm'].includes(command)
    ? `${command}.cmd`
    : command;

  return spawnSync(executable, args, {
    cwd,
    encoding: 'utf-8',
    shell: isWindows,
    env: process.env,
  });
}

async function main() {
  log('START', 'Verifying generated contract clients and compilation integrity...');

  const pathsToCheck = [
    'apps/api/src/types/api.generated.ts',
    'apps/mobile/lib/data/api',
  ];

  // 1. Check git diff for uncommitted modifications on tracked files
  log('CHECK_DIFF', 'Checking git diff on tracked generated contract files...');
  const diffResult = runCommand('git', ['diff', '--exit-code', ':!**/*.g.dart', ...pathsToCheck]);
  if (diffResult.status !== 0) {
    // eslint-disable-next-line no-console
    console.error(`[verify:contracts] [ERROR] Stale or manually modified contract files detected:\n${diffResult.stdout}`);
    // eslint-disable-next-line no-console
    console.error('[verify:contracts] [ERROR] Please run "pnpm run generate:contracts" and commit the changes.');
    process.exit(1);
  }
  log('CHECK_DIFF', 'No manual diffs found on generated files.');

  // 2. Verify TypeScript types compile
  log('CHECK_TS', 'Verifying TypeScript compilation (apps/api)...');
  const tsResult = runCommand('npx', ['tsc', '--noEmit'], resolve(rootDir, 'apps/api'));
  if (tsResult.status !== 0) {
    // eslint-disable-next-line no-console
    console.error(`[verify:contracts] [ERROR] TypeScript compilation failed:\n${tsResult.stderr || tsResult.stdout}`);
    process.exit(1);
  }
  log('CHECK_TS', 'TypeScript compilation passed with 0 errors.');

  // 3. Verify Dart client compiles and passes static analysis
  log('CHECK_DART', 'Verifying Dart static analysis (apps/mobile/lib/data/api)...');
  const dartApiDir = resolve(rootDir, 'apps/mobile/lib/data/api');
  runCommand('dart', ['pub', 'get'], dartApiDir);
  const dartResult = runCommand('dart', ['analyze', '.'], dartApiDir);
  if (dartResult.status !== 0) {
    // eslint-disable-next-line no-console
    console.error(`[verify:contracts] [ERROR] Dart analysis failed:\n${dartResult.stderr || dartResult.stdout}`);
    process.exit(1);
  }
  log('CHECK_DART', 'Dart static analysis passed with 0 errors.');

  log('SUCCESS', 'All contract verifications passed successfully.');
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(`[verify:contracts] [ERROR] ${err.message}`);
  process.exit(1);
});
