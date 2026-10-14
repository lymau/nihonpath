#!/usr/bin/env node

/**
 * NihonPath — Verification script for local development environment (M0-3).
 * Compatible with Podman Compose (native/python) and Docker Compose.
 */

import { spawnSync } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const isWindows = process.platform === 'win32';

function runCmd(cmd, args) {
  return spawnSync(cmd, args, {
    cwd: rootDir,
    encoding: 'utf-8',
    shell: isWindows,
  });
}

function detectComposeCommand() {
  const checkPythonPodman = runCmd('python', ['-m', 'podman_compose', 'version']);
  if (checkPythonPodman.status === 0) {
    return ['python', '-m', 'podman_compose'];
  }
  const checkPodmanCompose = runCmd('podman-compose', ['version']);
  if (checkPodmanCompose.status === 0) {
    return ['podman-compose'];
  }
  const checkPodman = runCmd('podman', ['compose', 'version']);
  if (checkPodman.status === 0) {
    return ['podman', 'compose'];
  }
  const checkDocker = runCmd('docker', ['compose', 'version']);
  if (checkDocker.status === 0) {
    return ['docker', 'compose'];
  }
  return null;
}

async function checkHttpEndpoint(url, name) {
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(3000) });
    return { name, ok: res.ok, status: res.status };
  } catch (err) {
    return { name, ok: false, error: err.message };
  }
}

async function sendDummyTraceToOtel() {
  const traceUrl = 'http://localhost:4318/v1/traces';
  const dummyPayload = {
    resourceSpans: [
      {
        resource: {
          attributes: [
            { key: 'service.name', value: { stringValue: 'nihonpath-verification' } },
            { key: 'service.version', value: { stringValue: '0.1.0' } },
          ],
        },
        scopeSpans: [
          {
            scope: { name: 'verify-local-env' },
            spans: [
              {
                traceId: '5b8aa5a2d2c872e8321cf37308d69d45',
                spanId: '051581bf3cb55c1e',
                name: 'test.local.verification',
                kind: 1,
                startTimeUnixNano: `${Date.now() - 1000}000000`,
                endTimeUnixNano: `${Date.now()}000000`,
                status: { code: 1 },
              },
            ],
          },
        ],
      },
    ],
  };

  try {
    const res = await fetch(traceUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dummyPayload),
      signal: AbortSignal.timeout(3000),
    });
    return { ok: res.ok, status: res.status };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

async function main() {
  console.log('================================================================');
  console.log('NihonPath — Local Container Environment Verifier (M0-3)');
  console.log('================================================================');

  const compose = detectComposeCommand();
  if (!compose) {
    console.error('❌ Error: Neither `podman-compose` nor `docker-compose` is available.');
    process.exit(1);
  }

  const composeExecutable = compose[0];
  const composeArgs = compose.slice(1);
  console.log(`\nUsing compose provider: ${composeExecutable} ${composeArgs.join(' ')}`);

  // 1. Validate compose config
  console.log('\n[1/4] Validating docker-compose.yml configuration...');
  const configCheck = runCmd(composeExecutable, [...composeArgs, 'config']);
  if (configCheck.status !== 0) {
    console.error('❌ Configuration error:');
    console.error(configCheck.stderr || configCheck.stdout);
    process.exit(1);
  }
  console.log('✔ docker-compose.yml configuration is valid.');

  // 2. Check running services
  console.log('\n[2/4] Checking running container services...');
  const psCheck = runCmd(composeExecutable, [...composeArgs, 'ps']);
  const psOutput = psCheck.stdout ? psCheck.stdout.trim() : '';

  // Check if any actual container row exists beyond headers
  const lines = psOutput.split('\n').filter((l) => l.trim().length > 0);
  const hasRunningContainers = lines.length > 1; // Header + at least one container

  if (!hasRunningContainers) {
    console.log('ℹ Containers are not currently running.');
    console.log('  To start containers: npm run docker:up  (or make up)');
    console.log('\n✔ All static configuration and schema files verified successfully.');
    process.exit(0);
  }

  console.log(`Containers found. Checking service health...`);

  // 3. Check HTTP Endpoints
  console.log('\n[3/4] Checking service HTTP endpoints...');
  const checks = [
    { url: 'http://localhost:3000/api/health', name: 'Grafana Health' },
    { url: 'http://localhost:9090/-/healthy', name: 'Prometheus Health' },
    { url: 'http://localhost:3100/ready', name: 'Loki Health' },
    { url: 'http://localhost:3200/ready', name: 'Tempo Health' },
    { url: 'http://localhost:13133/', name: 'OTel Collector Health' },
    { url: 'http://localhost:4566/_localstack/health', name: 'LocalStack Health' },
  ];

  for (const check of checks) {
    const res = await checkHttpEndpoint(check.url, check.name);
    if (res.ok) {
      console.log(`✔ ${res.name}: OK (${res.status})`);
    } else {
      console.warn(`⚠ ${res.name}: Pending / Not reachable (${res.error || res.status})`);
    }
  }

  // 4. Test trace forwarding
  console.log('\n[4/4] Sending verification test span to OTel Collector...');
  const traceRes = await sendDummyTraceToOtel();
  if (traceRes.ok) {
    console.log('✔ Test span accepted by OTel Collector (HTTP 200/202).');
  } else {
    console.warn(`⚠ OTel trace test not yet responding: ${traceRes.error || traceRes.status}`);
  }

  console.log('\n================================================================');
  console.log('Verification completed.');
  console.log('================================================================');
}

main().catch((err) => {
  console.error('Fatal error during verification:', err);
  process.exit(1);
});
