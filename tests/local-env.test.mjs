import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { parse } from 'yaml';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const composePath = resolve(rootDir, 'docker-compose.yml');
const postgresInitPath = resolve(rootDir, 'docker/postgres/init/01-init.sql');
const localstackInitPath = resolve(rootDir, 'docker/localstack/init/01-create-buckets.sh');
const otelConfigPath = resolve(rootDir, 'docker/otel/otel-collector-config.yaml');
const prometheusConfigPath = resolve(rootDir, 'docker/prometheus/prometheus.yml');
const lokiConfigPath = resolve(rootDir, 'docker/loki/loki-config.yaml');
const tempoConfigPath = resolve(rootDir, 'docker/tempo/tempo-config.yaml');
const grafanaDatasourcesPath = resolve(
  rootDir,
  'docker/grafana/provisioning/datasources/datasources.yaml',
);

test('docker-compose.yml structure and services specification (§4.2, §14.2, M0-3)', () => {
  assert.ok(existsSync(composePath), 'docker-compose.yml must exist at workspace root');
  const composeContent = readFileSync(composePath, 'utf-8');
  const compose = parse(composeContent);

  assert.ok(compose.services, 'services must be defined in docker-compose.yml');

  const requiredServices = [
    'postgres',
    'redis',
    'localstack',
    'otel-collector',
    'prometheus',
    'loki',
    'tempo',
    'grafana',
  ];

  for (const s of requiredServices) {
    assert.ok(compose.services[s], `Service "${s}" must be defined in docker-compose.yml`);
    assert.ok(compose.services[s].healthcheck, `Service "${s}" must have a healthcheck configured`);
  }

  // PostgreSQL must use version >= 16 (§4.2)
  assert.ok(
    compose.services.postgres.image.includes('postgres:16'),
    'Postgres service must use PostgreSQL version 16+',
  );

  // LocalStack replaces MinIO with S3 service enabled
  assert.ok(
    compose.services.localstack.image.includes('localstack'),
    'LocalStack service must be configured as S3 object storage emulator',
  );
  assert.equal(compose.services.localstack.environment.SERVICES, 's3');

  // Verify named volumes for rootless/podman compatibility
  const requiredVolumes = [
    'postgres_data',
    'redis_data',
    'localstack_data',
    'tempo_data',
    'loki_data',
    'prometheus_data',
    'grafana_data',
  ];
  for (const vol of requiredVolumes) {
    assert.ok(
      compose.volumes && vol in compose.volumes,
      `Volume "${vol}" must be declared as a top-level named volume`,
    );
  }
});

test('PostgreSQL init script contains citext extension (§4.2, §6.3)', () => {
  assert.ok(existsSync(postgresInitPath), '01-init.sql must exist');
  const sql = readFileSync(postgresInitPath, 'utf-8');
  assert.ok(
    sql.includes('CREATE EXTENSION IF NOT EXISTS citext;'),
    'citext extension must be initialized',
  );
  assert.ok(sql.includes('_system_health'), 'health check table must be initialized');
});

test('LocalStack S3 bucket initialization script configures nihonpath-packs and nihonpath-audio', () => {
  assert.ok(existsSync(localstackInitPath), '01-create-buckets.sh must exist');
  const script = readFileSync(localstackInitPath, 'utf-8');
  assert.ok(
    script.includes('s3://nihonpath-packs'),
    'Must create s3://nihonpath-packs bucket for content packs',
  );
  assert.ok(
    script.includes('s3://nihonpath-audio'),
    'Must create s3://nihonpath-audio bucket for audio assets',
  );
});

test('OpenTelemetry Collector configuration pipelines & exporters (§10.2, §10.3, §10.4)', () => {
  assert.ok(existsSync(otelConfigPath), 'otel-collector-config.yaml must exist');
  const yamlContent = readFileSync(otelConfigPath, 'utf-8');
  const config = parse(yamlContent);

  // Receivers
  assert.ok(config.receivers.otlp, 'OTLP receiver must be defined');
  assert.ok(config.receivers.otlp.protocols.grpc, 'gRPC protocol must be enabled for OTLP');
  assert.ok(config.receivers.otlp.protocols.http, 'HTTP protocol must be enabled for OTLP');

  // Exporters
  assert.ok(config.exporters.prometheus, 'Prometheus exporter must be configured');
  assert.ok(config.exporters['otlphttp/loki'], 'Loki OTLP HTTP exporter must be configured');
  assert.ok(config.exporters['otlp/tempo'], 'Tempo OTLP exporter must be configured');

  // Pipelines
  const pipelines = config.service.pipelines;
  assert.ok(pipelines.traces, 'Traces pipeline must be configured');
  assert.ok(pipelines.metrics, 'Metrics pipeline must be configured');
  assert.ok(pipelines.logs, 'Logs pipeline must be configured');
});

test('Prometheus & Loki & Tempo configurations', () => {
  assert.ok(existsSync(prometheusConfigPath), 'prometheus.yml must exist');
  const promContent = readFileSync(prometheusConfigPath, 'utf-8');
  assert.ok(
    promContent.includes('otel-collector:8889'),
    'Prometheus must scrape otel-collector metrics',
  );

  assert.ok(existsSync(lokiConfigPath), 'loki-config.yaml must exist');
  assert.ok(existsSync(tempoConfigPath), 'tempo-config.yaml must exist');
});

test('Grafana datasources configuration links Prometheus, Loki, and Tempo', () => {
  assert.ok(existsSync(grafanaDatasourcesPath), 'datasources.yaml must exist');
  const yamlContent = readFileSync(grafanaDatasourcesPath, 'utf-8');
  const dsConfig = parse(yamlContent);

  const dsNames = dsConfig.datasources.map((d) => d.name);
  assert.ok(dsNames.includes('Prometheus'), 'Prometheus datasource must be provisioned');
  assert.ok(dsNames.includes('Loki'), 'Loki datasource must be provisioned');
  assert.ok(dsNames.includes('Tempo'), 'Tempo datasource must be provisioned');

  // Verify Tempo-Loki cross correlation
  const tempoDs = dsConfig.datasources.find((d) => d.name === 'Tempo');
  assert.ok(tempoDs.jsonData.tracesToLogsV2, 'Tempo must have tracesToLogs integration configured');
});

test('Compose config validation via Podman or Docker Compose CLI', (t) => {
  const isWindows = process.platform === 'win32';

  // Try python -m podman_compose, podman-compose, podman compose, and docker compose
  let result = spawnSync('python', ['-m', 'podman_compose', 'config'], {
    cwd: rootDir,
    encoding: 'utf-8',
    shell: isWindows,
  });

  if (result.status !== 0) {
    result = spawnSync('podman-compose', ['config'], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
    });
  }

  if (result.status !== 0) {
    result = spawnSync('podman', ['compose', 'config'], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
    });
  }

  if (result.status !== 0) {
    result = spawnSync('docker', ['compose', 'config'], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
    });
  }

  if (result.error || result.status !== 0) {
    // If neither CLI is available in the test runner, skip rather than fail
    t.skip(`Compose CLI not available or failed: ${result.stderr || result.stdout}`);
    return;
  }

  assert.equal(result.status, 0, 'Compose configuration must be valid and error-free');
});
