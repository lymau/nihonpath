import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { existsSync, readdirSync } from 'node:fs';
import { runner } from 'node-pg-migrate';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function resolveDefaultMigrationsDir(): string {
  const localDir = resolve(__dirname, 'migrations');
  if (existsSync(localDir) && readdirSync(localDir).some((f) => f.endsWith('.sql'))) {
    return localDir;
  }
  const srcDir = resolve(__dirname, '../../src/db/migrations');
  if (existsSync(srcDir) && readdirSync(srcDir).some((f) => f.endsWith('.sql'))) {
    return srcDir;
  }
  return localDir;
}

export interface RunMigrationsOptions {
  databaseUrl: string;
  direction?: 'up' | 'down';
  count?: number;
  migrationsDir?: string;
  migrationsTable?: string;
  logger?: {
    info(msg: string): void;
    warn(msg: string): void;
    error(msg: string): void;
  };
}

export interface MigrationResult {
  path: string;
  name: string;
  timestamp: number;
}

export async function runMigrations(options: RunMigrationsOptions): Promise<MigrationResult[]> {
  const migrationsDir = options.migrationsDir ?? resolveDefaultMigrationsDir();
  const direction = options.direction ?? 'up';
  const migrationsTable = options.migrationsTable ?? 'pgmigrations';

  const logger = options.logger ?? {
    info: (msg: string) => process.stdout.write(`[db:migrate] ${msg}\n`),
    warn: (msg: string) => console.warn(`[db:migrate:warn] ${msg}`),
    error: (msg: string) => console.error(`[db:migrate:error] ${msg}`),
  };

  logger.info(`Starting migrations: direction=${direction}, dir=${migrationsDir}`);

  const results = await runner({
    databaseUrl: options.databaseUrl,
    dir: migrationsDir,
    direction,
    count: options.count ?? Infinity,
    migrationsTable,
    verbose: false,
    logger: {
      info: (msg: string) => logger.info(msg),
      warn: (msg: string) => logger.warn(msg),
      error: (msg: string) => logger.error(msg),
    },
  });

  logger.info(`Successfully finished migrations (${results.length} applied/reverted)`);
  return results;
}
