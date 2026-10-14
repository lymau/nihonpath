#!/usr/bin/env node

/**
 * scripts/verify-terraform.mjs
 *
 * Verifies Terraform formatting, syntax validation, and dependency resolution / plan
 * execution for dev environment in Jakarta region (M0-4a / §4.2, §11.2, §14.1, §14.2).
 */

import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { writeFileSync, unlinkSync, existsSync } from 'node:fs';

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

  return spawnSync(executable, args, {
    cwd,
    encoding: 'utf-8',
    env: { ...process.env, ...envOverrides },
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
  log('VALIDATE', `Initializing and validating: ${relativeDir}`);

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
  validateDirectory('infra/terraform/environments/dev');
  testDevPlan();
  verifyNoSecretsCommitted();
  log('FINISH', 'All Terraform validation checks passed successfully.');
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('[verify:terraform] [FATAL]', err);
  process.exit(1);
});
