import pg from 'pg';
import { Kysely, PostgresDialect } from 'kysely';
import type { Database } from './types.js';

const { Pool } = pg;

export interface DatabasePoolConfig {
  connectionString: string;
  statementTimeoutMs?: number;
  max?: number;
  idleTimeoutMillis?: number;
  connectionTimeoutMillis?: number;
  applicationRole?: string;
}

export interface DbPoolMetrics {
  db_pool_in_use: number;
  db_pool_waiting: number;
  db_pool_total: number;
  db_pool_idle: number;
}

/**
 * Creates and configures a PostgreSQL connection pool with:
 * - statement_timeout of 3000ms (3 seconds) enforced per §11.3
 * - optional application role assignment without DDL rights per §12.1
 */
export function createDatabasePool(config: DatabasePoolConfig): pg.Pool {
  const statementTimeout = config.statementTimeoutMs ?? 3000;

  const pool = new Pool({
    connectionString: config.connectionString,
    statement_timeout: statementTimeout,
    max: config.max ?? 20,
    idleTimeoutMillis: config.idleTimeoutMillis ?? 10000,
    connectionTimeoutMillis: config.connectionTimeoutMillis ?? 3000,
  });

  // Enforce session statement timeout and optional non-DDL application role (§11.3, §12.1)
  pool.on('connect', (client: pg.PoolClient) => {
    client.query(`SET statement_timeout = ${statementTimeout}`).catch((err) => {
      // In case the query fails during connect initialization
      console.error('Failed to set statement_timeout on client connect:', err);
    });

    if (config.applicationRole) {
      // Prevent SQL injection in role identifier
      const sanitizedRole = config.applicationRole.replace(/[^a-zA-Z0-9_]/g, '');
      if (sanitizedRole.length > 0) {
        client.query(`SET ROLE ${sanitizedRole}`).catch((err) => {
          console.error(`Failed to set application role ${sanitizedRole}:`, err);
        });
      }
    }
  });

  return pool;
}

/**
 * Exposes pool saturation metrics (db_pool_in_use, db_pool_waiting) per §10.3
 */
export function getDbPoolMetrics(pool: pg.Pool): DbPoolMetrics {
  const inUse = Math.max(0, pool.totalCount - pool.idleCount);
  return {
    db_pool_in_use: inUse,
    db_pool_waiting: pool.waitingCount,
    db_pool_total: pool.totalCount,
    db_pool_idle: pool.idleCount,
  };
}

/**
 * Creates a strongly-typed Kysely query builder instance bound to the PostgreSQL pool (§4.2)
 */
export function createKysely(pool: pg.Pool): Kysely<Database> {
  const dialect = new PostgresDialect({
    pool,
  });

  return new Kysely<Database>({
    dialect,
  });
}
