#!/usr/bin/env node

/**
 * Cross-platform runner for Docker / Podman Compose commands.
 * Prioritizes native Podman Compose, followed by podman compose or docker compose.
 */

import { spawnSync } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const isWindows = process.platform === 'win32';
const args = process.argv.slice(2);

function run(cmd, cmdArgs) {
  return spawnSync(cmd, cmdArgs, {
    cwd: rootDir,
    encoding: 'utf-8',
    shell: isWindows,
  });
}

function getComposeCommand() {
  // 1. Try python -m podman_compose (most reliable on Windows rootless Podman)
  const checkPythonPodman = run('python', ['-m', 'podman_compose', 'version']);
  if (checkPythonPodman.status === 0) {
    return { cmd: 'python', baseArgs: ['-m', 'podman_compose'] };
  }

  // 2. Try podman-compose CLI executable
  const checkPodmanCompose = run('podman-compose', ['version']);
  if (checkPodmanCompose.status === 0) {
    return { cmd: 'podman-compose', baseArgs: [] };
  }

  // 3. Try podman compose
  const checkPodman = run('podman', ['compose', 'version']);
  if (checkPodman.status === 0) {
    return { cmd: 'podman', baseArgs: ['compose'] };
  }

  // 4. Try docker compose
  const checkDocker = run('docker', ['compose', 'version']);
  if (checkDocker.status === 0) {
    return { cmd: 'docker', baseArgs: ['compose'] };
  }

  return null;
}

const compose = getComposeCommand();
if (!compose) {
  console.error('❌ Error: No Compose provider found (podman-compose, podman compose, or docker compose).');
  process.exit(1);
}

const fullArgs = [...compose.baseArgs, ...args];
const result = spawnSync(compose.cmd, fullArgs, {
  cwd: rootDir,
  stdio: 'inherit',
  shell: isWindows,
});

process.exit(result.status ?? 0);
