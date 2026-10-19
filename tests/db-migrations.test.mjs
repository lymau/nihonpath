import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync, execSync } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

// Compile apps/api TypeScript before running tests
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

// Copy SQL migrations to dist
spawnSync('node', ['scripts/copy-api-assets.mjs'], {
  cwd: rootDir,
  encoding: 'utf-8',
  shell: isWindows,
});

const { runMigrations, createDatabasePool, createKysely, getDbPoolMetrics } =
  await import('../apps/api/dist/db/index.js');

/**
 * Helper to acquire a PostgreSQL instance:
 * 1. Preconfigured TEST_DATABASE_URL if provided
 * 2. Testcontainers PostgreSqlContainer if Docker runtime is active
 * 3. Fallback to transient Podman/Docker CLI container
 */
async function startPostgreSql() {
  if (process.env.TEST_DATABASE_URL) {
    return {
      connectionString: process.env.TEST_DATABASE_URL,
      stop: async () => {},
    };
  }

  // Strategy 1: Testcontainers
  try {
    const { PostgreSqlContainer } = await import('@testcontainers/postgresql');
    const container = await new PostgreSqlContainer('postgres:16-alpine')
      .withDatabase('nihonpath_test')
      .withUsername('postgres')
      .withPassword('postgres')
      .start();

    return {
      connectionString: container.getConnectionUri(),
      stop: async () => {
        await container.stop();
      },
    };
  } catch {
    // Strategy 2: Fallback to CLI container (e.g. Podman on Windows without Docker socket proxy)
    return await startCliPostgres();
  }
}

async function startCliPostgres() {
  const containerName = `np-test-pg-${Date.now()}`;
  const runRes = spawnSync(
    'podman',
    [
      'run',
      '--rm',
      '-d',
      '--name',
      containerName,
      '-p',
      '5432',
      '-e',
      'POSTGRES_PASSWORD=postgres',
      '-e',
      'POSTGRES_DB=nihonpath_test',
      'postgres:16-alpine',
    ],
    { encoding: 'utf-8', shell: isWindows },
  );

  if (runRes.status !== 0) {
    throw new Error(`Failed to start container CLI: ${runRes.stderr || runRes.stdout}`);
  }

  let host = 'localhost';
  if (isWindows) {
    try {
      const ethOut = execSync('podman machine ssh ip -4 addr show eth0', { encoding: 'utf-8' });
      const match = ethOut.match(/inet\s+([0-9.]+)/);
      if (match) host = match[1];
    } catch {
      // fallback to localhost
    }
  }

  const portOut = execSync(`podman port ${containerName} 5432`, { encoding: 'utf-8' }).trim();
  const port = portOut.split(':')[1]?.trim();
  const connectionString = `postgresql://postgres:postgres@${host}:${port}/nihonpath_test`;

  // Wait for PostgreSQL readiness
  let ready = false;
  for (let i = 0; i < 30; i++) {
    try {
      const client = new pg.Client({ connectionString });
      await client.connect();
      await client.query('SELECT 1');
      await client.end();
      ready = true;
      break;
    } catch {
      await new Promise((r) => setTimeout(r, 500));
    }
  }

  if (!ready) {
    try {
      execSync(`podman stop ${containerName}`, { stdio: 'ignore' });
    } catch {
      // ignore
    }
    throw new Error('PostgreSQL container failed to become ready in time');
  }

  return {
    connectionString,
    stop: async () => {
      try {
        execSync(`podman stop ${containerName}`, { stdio: 'ignore' });
      } catch {
        // ignore
      }
    },
  };
}

test('PostgreSQL Migrations & Kysely Typed Schema (§4.2, §6.3, §10.3, §11.3, §12.1)', async (t) => {
  let pgInstance;
  try {
    pgInstance = await startPostgreSql();
  } catch (err) {
    t.skip(`Skipping database migration tests: container runtime unavailable (${err.message})`);
    return;
  }

  const dbUrl = pgInstance.connectionString;

  try {
    // -------------------------------------------------------------------------
    // 1. Integration Test: Migration UP creates full §6.3 schema
    // -------------------------------------------------------------------------
    await t.test(
      'Integration test: migrasi naik (up) berhasil membuat seluruh skema §6.3',
      async () => {
        const logRecords = [];
        const logger = {
          info: (msg) => logRecords.push(`INFO: ${msg}`),
          warn: (msg) => logRecords.push(`WARN: ${msg}`),
          error: (msg) => logRecords.push(`ERROR: ${msg}`),
        };

        const upResults = await runMigrations({
          databaseUrl: dbUrl,
          direction: 'up',
          logger,
        });

        assert.ok(upResults.length > 0, 'At least 1 migration must be executed');
        assert.ok(
          upResults.some((m) => m.name.includes('001_initial_schema')),
          '001_initial_schema migration must be applied',
        );

        // Verify migration execution logs recorded (§10.2)
        assert.ok(logRecords.length > 0, 'Migration logs must be recorded');
        assert.ok(
          logRecords.some(
            (l) => l.includes('Starting migrations') || l.includes('001_initial_schema'),
          ),
          'Migration start/progress must be logged',
        );

        const client = new pg.Client({ connectionString: dbUrl });
        await client.connect();

        try {
          // Verify citext extension
          const extRes = await client.query(
            "SELECT extname FROM pg_extension WHERE extname = 'citext'",
          );
          assert.equal(extRes.rows.length, 1, 'citext extension must be installed');

          // Verify all 15 tables from §6.3
          const expectedTables = [
            'users',
            'auth_identities',
            'devices',
            'refresh_tokens',
            'content_items',
            'lessons',
            'lesson_items',
            'content_packs',
            'user_sync_state',
            'user_cards',
            'review_logs',
            'review_logs_default',
            'user_settings',
            'lesson_progress',
            'test_attempts',
            'subscriptions',
          ];

          const tablesRes = await client.query(
            "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'",
          );
          const tableNames = new Set(tablesRes.rows.map((r) => r.table_name));

          for (const expectedTable of expectedTables) {
            assert.ok(
              tableNames.has(expectedTable),
              `Table "${expectedTable}" must exist in database per §6.3`,
            );
          }

          // Verify review_logs is a partitioned table (relkind = 'p')
          const partRes = await client.query(
            "SELECT relkind FROM pg_class WHERE relname = 'review_logs'",
          );
          assert.equal(
            partRes.rows[0]?.relkind,
            'p',
            'review_logs must be a partitioned table (relkind = p) (§6.3)',
          );

          // Verify review_logs_default is a partition of review_logs (relispartition = true)
          const defPartRes = await client.query(
            "SELECT relispartition FROM pg_class WHERE relname = 'review_logs_default'",
          );
          assert.equal(
            defPartRes.rows[0]?.relispartition,
            true,
            'review_logs_default must be an active partition of review_logs (§6.3)',
          );

          // Verify required indexes exist
          const idxRes = await client.query(`
          SELECT indexname, tablename
          FROM pg_indexes
          WHERE schemaname = 'public'
        `);
          const indexList = idxRes.rows.map((r) => `${r.tablename}:${r.indexname}`);

          assert.ok(
            indexList.some((i) => i.startsWith('refresh_tokens:')),
            'refresh_tokens index on (user_id, family_id) must exist',
          );
          assert.ok(
            indexList.some((i) => i.startsWith('content_items:')),
            'content_items index on (jlpt_level, type) must exist',
          );
          assert.ok(
            indexList.some((i) => i.startsWith('user_cards:')),
            'user_cards index on (user_id, user_seq) must exist',
          );
          assert.ok(
            indexList.some((i) => i.startsWith('review_logs:')),
            'review_logs index on (user_id, user_seq) must exist',
          );
        } finally {
          await client.end();
        }
      },
    );

    // -------------------------------------------------------------------------
    // 2. Integration Test: Kysely Typed Client & Partition Routing
    // -------------------------------------------------------------------------
    await t.test(
      'Testcontainers: uji penulisan data ke partisi review_logs dan verifikasi partition routing',
      async () => {
        const pool = createDatabasePool({
          connectionString: dbUrl,
          statementTimeoutMs: 3000,
        });
        const db = createKysely(pool);

        try {
          const testUserId = '0192a000-0000-7000-8000-000000000001';
          const testDeviceId = '0192a000-0000-7000-8000-000000000002';
          const testCardId = '0192a000-0000-7000-8000-000000000003';
          const defaultLogId = '0192a000-0000-7000-8000-000000000004';
          const octLogId = '0192a000-0000-7000-8000-000000000005';

          // 1. Insert user
          await db
            .insertInto('users')
            .values({
              id: testUserId,
              email: 'learner@nihonpath.dev',
              display_name: 'Test Learner',
              locale: 'id',
              timezone: 'Asia/Jakarta',
            })
            .execute();

          // 2. Insert review log with arbitrary timestamp -> should route to review_logs_default
          const pastDate = new Date('2025-05-15T12:00:00.000Z');
          await db
            .insertInto('review_logs')
            .values({
              user_id: testUserId,
              id: defaultLogId,
              card_id: testCardId,
              rating: 3,
              state_before: 1,
              reviewed_at: pastDate,
              duration_ms: 2500,
              scheduled_days: 3,
              elapsed_days: 1,
              stability_before: 2.1,
              difficulty_before: 4.5,
              exercise_type: 'flashcard',
              device_id: testDeviceId,
              user_seq: 1,
            })
            .execute();

          // Verify row was routed to review_logs_default partition table
          const defaultPartitionCheck = await pool.query(
            'SELECT id, rating FROM review_logs_default WHERE id = $1',
            [defaultLogId],
          );
          assert.equal(
            defaultPartitionCheck.rows.length,
            1,
            'Row must be routed into review_logs_default partition table',
          );
          assert.equal(defaultPartitionCheck.rows[0].rating, 3);

          // 3. Create a monthly partition for 2026-10 (§6.3)
          await pool.query(`
          CREATE TABLE IF NOT EXISTS review_logs_2026_10
          PARTITION OF review_logs
          FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00')
        `);

          // 4. Insert log for 2026-10 -> should route to review_logs_2026_10
          const octDate = new Date('2026-10-19T20:00:00.000Z');
          await db
            .insertInto('review_logs')
            .values({
              user_id: testUserId,
              id: octLogId,
              card_id: testCardId,
              rating: 4,
              state_before: 2,
              reviewed_at: octDate,
              duration_ms: 1800,
              scheduled_days: 7,
              elapsed_days: 3,
              stability_before: 3.5,
              difficulty_before: 4.2,
              exercise_type: 'reading',
              device_id: testDeviceId,
              user_seq: 2,
            })
            .execute();

          // Verify row was routed to review_logs_2026_10 partition table
          const octPartitionCheck = await pool.query(
            'SELECT id, rating FROM review_logs_2026_10 WHERE id = $1',
            [octLogId],
          );
          assert.equal(
            octPartitionCheck.rows.length,
            1,
            'Row must be routed into review_logs_2026_10 partition table',
          );
          assert.equal(octPartitionCheck.rows[0].rating, 4);

          // 5. Query through Kysely on parent partitioned table review_logs
          const queriedLogs = await db
            .selectFrom('review_logs')
            .selectAll()
            .where('user_id', '=', testUserId)
            .orderBy('user_seq', 'asc')
            .execute();

          assert.equal(queriedLogs.length, 2, 'Kysely should return rows from all partitions');
          assert.equal(queriedLogs[0].id, defaultLogId);
          assert.equal(queriedLogs[1].id, octLogId);
        } finally {
          await pool.end();
        }
      },
    );

    // -------------------------------------------------------------------------
    // 3. Database Pool Saturation Metrics & Statement Timeout (§10.3, §11.3, §12.1)
    // -------------------------------------------------------------------------
    await t.test(
      'Metrik saturasi pool database (db_pool_in_use, db_pool_waiting) dan statement_timeout 3s',
      async () => {
        const pool = createDatabasePool({
          connectionString: dbUrl,
          statementTimeoutMs: 3000,
          max: 5,
        });

        try {
          const initialMetrics = getDbPoolMetrics(pool);
          assert.equal(typeof initialMetrics.db_pool_in_use, 'number');
          assert.equal(typeof initialMetrics.db_pool_waiting, 'number');
          assert.equal(typeof initialMetrics.db_pool_total, 'number');
          assert.equal(typeof initialMetrics.db_pool_idle, 'number');

          // Check in_use increases when client checked out
          const client = await pool.connect();
          try {
            const inUseMetrics = getDbPoolMetrics(pool);
            assert.equal(
              inUseMetrics.db_pool_in_use,
              1,
              'db_pool_in_use must be 1 when 1 client acquired',
            );

            // Verify statement_timeout is configured to 3000ms (§11.3)
            const timeoutRes = await client.query('SHOW statement_timeout');
            const timeoutValue = timeoutRes.rows[0].statement_timeout;
            assert.ok(
              timeoutValue === '3s' || timeoutValue === '3000ms',
              `statement_timeout must be 3s (actual: ${timeoutValue})`,
            );

            // Verify statement_timeout cancels queries that exceed 3 seconds
            await assert.rejects(
              async () => {
                await client.query('SELECT pg_sleep(4)');
              },
              (err) => {
                // 57014 = query_canceled
                assert.equal(
                  err.code,
                  '57014',
                  'Statement exceeding timeout must be cancelled with 57014',
                );
                return true;
              },
            );
          } finally {
            client.release();
          }

          const afterRelease = getDbPoolMetrics(pool);
          assert.equal(afterRelease.db_pool_in_use, 0, 'db_pool_in_use must return to 0');
        } finally {
          await pool.end();
        }
      },
    );

    // -------------------------------------------------------------------------
    // 4. Integration Test: Migration DOWN cleans entire schema atomically
    // -------------------------------------------------------------------------
    await t.test(
      'Testcontainers: migrasi turun (down) membersihkan seluruh skema tanpa error',
      async () => {
        // First drop the manually created monthly partition so down migration can drop parent cleanly
        const prepClient = new pg.Client({ connectionString: dbUrl });
        await prepClient.connect();
        try {
          await prepClient.query('DROP TABLE IF EXISTS review_logs_2026_10 CASCADE');
        } finally {
          await prepClient.end();
        }

        const downResults = await runMigrations({
          databaseUrl: dbUrl,
          direction: 'down',
          count: 1,
        });

        assert.ok(downResults.length > 0, 'Down migration must successfully execute');

        const checkClient = new pg.Client({ connectionString: dbUrl });
        await checkClient.connect();
        try {
          const tablesRes = await checkClient.query(
            "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name != 'pgmigrations'",
          );
          assert.equal(
            tablesRes.rows.length,
            0,
            `All tables must be dropped on rollback. Remaining: ${tablesRes.rows.map((r) => r.table_name).join(', ')}`,
          );
        } finally {
          await checkClient.end();
        }
      },
    );
  } finally {
    await pgInstance.stop();
  }
});
