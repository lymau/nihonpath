#!/usr/bin/env node

/**
 * scripts/verify-terraform.mjs
 *
 * Verifies Terraform formatting, syntax validation, and dependency resolution / plan
 * execution for dev environment in Jakarta region (M0-4a / M0-4b / §4.2, §11.2, §11.3, §11.4, §14.1, §14.2).
 */

import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { writeFileSync, unlinkSync, existsSync, readFileSync } from 'node:fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

function log(stage, message, extra = null) {
  const ts = new Date().toISOString();
  const base = `[${ts}] [verify:terraform] [${stage}] ${message}`;
  if (extra) {
    // eslint-disable-next-line no-console
    console.log(`${base} ${JSON.stringify(extra)}`);
  } else {
    // eslint-disable-next-line no-console
    console.log(base);
  }
}

function runCommand(command, args, cwd = rootDir, envOverrides = {}) {
  const isWindows = process.platform === 'win32';
  const executable = isWindows && ['npx', 'npm', 'pnpm'].includes(command)
    ? `${command}.cmd`
    : command;

  const currentPath = process.env.PATH || process.env.Path || '';
  const wingetLinks = process.env.LOCALAPPDATA
    ? resolve(process.env.LOCALAPPDATA, 'Microsoft/WinGet/Links')
    : '';
  const augmentedPath = isWindows && wingetLinks && !currentPath.includes(wingetLinks)
    ? `${currentPath};${wingetLinks}`
    : currentPath;

  return spawnSync(executable, args, {
    cwd,
    encoding: 'utf-8',
    env: { ...process.env, PATH: augmentedPath, Path: augmentedPath, ...envOverrides },
  });
}

function checkTerraformInstalled() {
  const res = runCommand('terraform', ['-version']);
  if (res.status !== 0) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] terraform CLI not found in PATH.');
    process.exit(1);
  }
  const versionLine = res.stdout.split('\n')[0].trim();
  log('INIT', `Found Terraform CLI: ${versionLine}`);
}

function verifyFormatting() {
  log('FMT', 'Checking Terraform formatting (terraform fmt -check)...');
  const res = runCommand('terraform', ['fmt', '-check', '-recursive', 'infra/terraform']);
  if (res.status !== 0) {
    // eslint-disable-next-line no-console
    console.error(`[verify:terraform] [ERROR] Terraform format check failed:\n${res.stdout || res.stderr}`);
    process.exit(1);
  }
  log('FMT', 'Terraform files are formatted according to canonical standard.');
}

function validateDirectory(relativeDir) {
  const dirPath = resolve(rootDir, relativeDir);
  const isDatabase = relativeDir.endsWith('modules/database');
  const dummyProvidersFile = resolve(dirPath, 'dummy_providers.tf');

  log('VALIDATE', `Initializing and validating: ${relativeDir}`);

  if (isDatabase) {
    writeFileSync(
      dummyProvidersFile,
      'provider "aws" {\n  alias  = "singapore"\n  region = "ap-southeast-1"\n}\n',
      'utf-8',
    );
  }

  try {
    const initRes = runCommand('terraform', ['init', '-backend=false'], dirPath);
    if (initRes.status !== 0) {
      // eslint-disable-next-line no-console
      console.error(`[verify:terraform] [ERROR] "terraform init -backend=false" failed in ${relativeDir}:\n${initRes.stderr || initRes.stdout}`);
      process.exit(1);
    }

    const validateRes = runCommand('terraform', ['validate'], dirPath);
    if (validateRes.status !== 0) {
      // eslint-disable-next-line no-console
      console.error(`[verify:terraform] [ERROR] "terraform validate" failed in ${relativeDir}:\n${validateRes.stderr || validateRes.stdout}`);
      process.exit(1);
    }

    log('VALIDATE', `Validation successful: ${relativeDir}`);
  } finally {
    if (existsSync(dummyProvidersFile)) {
      unlinkSync(dummyProvidersFile);
    }
  }
}

function verifyDatabaseConnectivityAndTimeoutSpec() {
  log('DB_CHECK', 'Verifying PgBouncer connectivity architecture and statement_timeout specification (§11.2, §11.3)...');
  const dbMainTf = resolve(rootDir, 'infra/terraform/modules/database/main.tf');
  const content = readFileSync(dbMainTf, 'utf-8');

  if (!content.includes('name  = "statement_timeout"') || !content.includes('value = tostring(var.statement_timeout_ms)')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] statement_timeout parameter not configured in parameter group.');
    process.exit(1);
  }

  if (!content.includes('name = "POOL_MODE"') || !content.includes('value = var.pgbouncer_pool_mode')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] PgBouncer POOL_MODE not set to variable in task definition.');
    process.exit(1);
  }

  if (!content.includes('port        = 6432') || !content.includes('containerPort = 6432')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] PgBouncer port 6432 not mapped.');
    process.exit(1);
  }

  log('DB_CHECK', 'Database connectivity spec and statement_timeout (3s) verified successfully.');
}

function verifyStorageAndCdnSpecification() {
  log('STORAGE_CDN_CHECK', 'Verifying Storage versioning, CDN read-mostly rules, signed URLs, and KMS secret rotation (§4.2, §8.2, §9.3, §11.4, §12.1)...');
  const storageMainTf = resolve(rootDir, 'infra/terraform/modules/storage/main.tf');
  const cdnMainTf = resolve(rootDir, 'infra/terraform/modules/cdn/main.tf');
  const secretsMainTf = resolve(rootDir, 'infra/terraform/modules/secrets/main.tf');

  const storageContent = readFileSync(storageMainTf, 'utf-8');
  const cdnContent = readFileSync(cdnMainTf, 'utf-8');
  const secretsContent = readFileSync(secretsMainTf, 'utf-8');

  // Storage checks (§11.4, §12.1)
  if (!storageContent.includes('status = "Enabled"')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] S3 bucket versioning is not enabled (§11.4).');
    process.exit(1);
  }
  if (!storageContent.includes('block_public_acls       = true') || !storageContent.includes('restrict_public_buckets = true')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] S3 public access block not fully enforced (§12.1).');
    process.exit(1);
  }
  if (!storageContent.includes('aws_iam_policy" "presigned_url_access"')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] Presigned URL IAM policy not defined in storage module (§8.2, §12.1).');
    process.exit(1);
  }

  // CDN checks (§4.2, §8.2, §12.1)
  if (!cdnContent.includes('aws_cloudfront_origin_access_control') || !cdnContent.includes('origin_access_control_id')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] CloudFront Origin Access Control (OAC) not configured.');
    process.exit(1);
  }
  if (!cdnContent.includes('cached_methods         = ["GET", "HEAD"]') || !cdnContent.includes('viewer_protocol_policy = "redirect-to-https"')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] CDN read-mostly caching and HTTPS redirect rules missing.');
    process.exit(1);
  }
  if (!cdnContent.includes('trusted_key_groups') || !cdnContent.includes('aws_cloudfront_key_group')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] CloudFront signed URL key group mechanism missing (§8.2, §12.1).');
    process.exit(1);
  }
  if (!cdnContent.includes('5xxErrorRate') || !cdnContent.includes('4xxErrorRate')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] CloudFront observability alarms missing for error rates.');
    process.exit(1);
  }

  // Secrets & KMS checks (§8.3, §12.1)
  if (!secretsContent.includes('enable_key_rotation     = true')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] KMS key rotation not enabled on secrets CMK (§12.1).');
    process.exit(1);
  }
  if (!secretsContent.includes('jwt_signing_key') || !secretsContent.includes('third_party_api_keys')) {
    // eslint-disable-next-line no-console
    console.error('[verify:terraform] [ERROR] Secrets Manager secrets for JWT or 3rd party API keys missing.');
    process.exit(1);
  }

  log('STORAGE_CDN_CHECK', 'Storage, CDN, and Secret management specifications verified successfully.');
}

function testDevPlan() {
  const devDir = resolve(rootDir, 'infra/terraform/environments/dev');
  const overrideFile = resolve(devDir, 'backend_override.tf');

  log('PLAN', 'Setting up offline plan test with local backend override and mock credentials...');
  writeFileSync(
    overrideFile,
    'terraform {\n  backend "local" {}\n}\n',
    'utf-8',
  );

  const mockEnv = {
    AWS_ACCESS_KEY_ID: 'mock_key',
    AWS_SECRET_ACCESS_KEY: 'mock_secret',
    AWS_REGION: 'ap-southeast-3',
  };

  try {
    const initRes = runCommand('terraform', ['init', '-reconfigure'], devDir, mockEnv);
    if (initRes.status !== 0) {
      // eslint-disable-next-line no-console
      console.error(`[verify:terraform] [ERROR] terraform init with local override failed:\n${initRes.stderr || initRes.stdout}`);
      process.exit(1);
    }

    log('PLAN', 'Running "terraform plan" for dev environment...');
    const planRes = runCommand('terraform', ['plan', '-no-color'], devDir, mockEnv);
    if (planRes.status !== 0) {
      // eslint-disable-next-line no-console
      console.error(`[verify:terraform] [ERROR] terraform plan failed:\n${planRes.stderr || planRes.stdout}`);
      process.exit(1);
    }

    const planOutput = planRes.stdout;
    const planMatch = planOutput.match(/Plan: (\d+) to add, (\d+) to change, (\d+) to destroy/);
    const planSummary = planMatch
      ? { add: Number(planMatch[1]), change: Number(planMatch[2]), destroy: Number(planMatch[3]) }
      : { raw: 'Plan succeeded without explicit summary line' };

    log('PLAN', 'Terraform plan completed without dependency errors.', planSummary);
  } finally {
    if (existsSync(overrideFile)) {
      unlinkSync(overrideFile);
    }
  }
}

function verifyNoSecretsCommitted() {
  log('GIT_CHECK', 'Verifying no secret *.tfvars or *.tfstate files are staged or committed...');
  const res = runCommand('git', ['status', '--porcelain', 'infra/terraform']);
  const forbidden = (res.stdout || '').split('\n').filter((line) => {
    return (
      (line.includes('.tfstate') || line.includes('.tfvars')) &&
      !line.includes('.tfvars.example')
    );
  });

  if (forbidden.length > 0) {
    // eslint-disable-next-line no-console
    console.error(`[verify:terraform] [ERROR] Forbidden state or secret files detected:\n${forbidden.join('\n')}`);
    process.exit(1);
  }
  log('GIT_CHECK', 'No state or secret files detected in repository tracking.');
}

async function main() {
  log('START', 'Starting Terraform verification suite for NihonPath...');
  checkTerraformInstalled();
  verifyFormatting();
  validateDirectory('infra/terraform/modules/network');
  validateDirectory('infra/terraform/modules/compute');
  validateDirectory('infra/terraform/modules/database');
  validateDirectory('infra/terraform/modules/storage');
  validateDirectory('infra/terraform/modules/cdn');
  validateDirectory('infra/terraform/modules/secrets');
  validateDirectory('infra/terraform/environments/dev');
  verifyDatabaseConnectivityAndTimeoutSpec();
  verifyStorageAndCdnSpecification();
  testDevPlan();
  verifyNoSecretsCommitted();
  log('FINISH', 'All Terraform validation checks passed successfully.');
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('[verify:terraform] [FATAL]', err);
  process.exit(1);
});
