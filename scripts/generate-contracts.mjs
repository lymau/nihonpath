#!/usr/bin/env node

/**
 * scripts/generate-contracts.mjs
 *
 * Deterministic contract code generator for NihonPath (M0-2 / §0 Aturan 2).
 * Generates:
 *   1. TypeScript types for apps/api via openapi-typescript
 *   2. Dart Dio API client for apps/mobile via openapi-generator-cli (dart-dio)
 *   3. Runs build_runner for built_value serialization
 *   4. Formats generated files
 */

import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const openapiPath = resolve(rootDir, 'packages/contracts/openapi.yaml');
const tsOutputPath = resolve(rootDir, 'apps/api/src/types/api.generated.ts');
const dartOutputDir = resolve(rootDir, 'apps/mobile/lib/data/api');
const jsonSchemaDir = resolve(rootDir, 'packages/contracts/json-schema');

function log(stage, message) {
  const ts = new Date().toISOString();
  // eslint-disable-next-line no-console
  console.log(`[${ts}] [generate:contracts] [${stage}] ${message}`);
}

function runCommand(command, args, cwd = rootDir) {
  log('EXEC', `Running: ${command} ${args.join(' ')} (in ${cwd})`);
  const isWindows = process.platform === 'win32';
  const executable = isWindows && ['npx', 'npm', 'pnpm'].includes(command)
    ? `${command}.cmd`
    : command;

  const result = spawnSync(executable, args, {
    cwd,
    stdio: 'inherit',
    shell: isWindows,
    env: process.env,
  });

  if (result.error) {
    // If executable not found with extension, try fallback directly
    const fallback = spawnSync(command, args, {
      cwd,
      stdio: 'inherit',
      shell: isWindows,
      env: process.env,
    });
    if (fallback.status !== 0) {
      throw new Error(`Command failed: ${command} ${args.join(' ')}`);
    }
    return;
  }

  if (result.status !== 0) {
    throw new Error(`Command failed with exit code ${result.status}: ${command} ${args.join(' ')}`);
  }
}

async function main() {
  const startTime = Date.now();
  log('START', 'Starting contract generation pipeline...');

  // 1. Verify contracts exist
  if (!existsSync(openapiPath)) {
    throw new Error(`OpenAPI spec not found at: ${openapiPath}`);
  }
  const schemas = ['vocab.schema.json', 'kanji.schema.json', 'grammar.schema.json', 'kana.schema.json', 'content-item.schema.json'];
  for (const s of schemas) {
    const sPath = resolve(jsonSchemaDir, s);
    if (!existsSync(sPath)) {
      throw new Error(`Content JSON Schema missing: ${sPath}`);
    }
  }
  log('VERIFY', 'Contracts and JSON schemas verified.');

  // 2. Generate TypeScript types for NestJS
  log('TS_GEN', `Generating TypeScript types at ${tsOutputPath}...`);
  runCommand('npx', ['openapi-typescript', openapiPath, '-o', tsOutputPath]);
  log('TS_GEN', 'TypeScript contract types generated successfully.');

  // 3. Generate Dart client via openapi-generator-cli
  log('DART_GEN', `Generating Dart client at ${dartOutputDir}...`);
  runCommand('npx', [
    '@openapitools/openapi-generator-cli',
    'generate',
    '-i',
    openapiPath,
    '-g',
    'dart-dio',
    '-o',
    dartOutputDir,
    '--additional-properties=pubName=nihonpath_api',
  ]);

  // Adjust analysis_options.yaml in generated dart package to ignore unused_import
  const dartAnalysisPath = resolve(dartOutputDir, 'analysis_options.yaml');
  if (existsSync(dartAnalysisPath)) {
    let analysisContent = readFileSync(dartAnalysisPath, 'utf-8');
    if (!analysisContent.includes('unused_import: ignore')) {
      analysisContent = analysisContent.replace(
        'deprecated_member_use_from_same_package: ignore',
        'deprecated_member_use_from_same_package: ignore\n    unused_import: ignore',
      );
      writeFileSync(dartAnalysisPath, analysisContent, 'utf-8');
      log('DART_CONFIG', 'Configured analysis_options.yaml in generated Dart client.');
    }
  }

  // 4. Resolve Dart dependencies & run build_runner
  log('DART_BUILD', 'Resolving Dart client dependencies (dart pub get)...');
  runCommand('dart', ['pub', 'get'], dartOutputDir);

  log('DART_BUILD', 'Running Dart build_runner for built_value serialization...');
  runCommand(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    dartOutputDir,
  );
  log('DART_BUILD', 'Dart build_runner generation completed.');

  // 5. Code formatting
  log('FORMAT', 'Formatting generated Dart and TypeScript files...');
  runCommand('dart', ['format', dartOutputDir]);
  runCommand('npx', [
    'prettier',
    '--write',
    tsOutputPath,
    openapiPath,
    jsonSchemaDir,
    resolve(dartOutputDir, 'pubspec.yaml'),
    resolve(dartOutputDir, 'analysis_options.yaml'),
  ]);

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
  log('SUCCESS', `Contract generation completed deterministically in ${elapsed}s.`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(`[generate:contracts] [ERROR] ${err.message}`);
  process.exit(1);
});
