import { cpSync, existsSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const src = resolve(__dirname, '../apps/api/src/db/migrations');
const dist = resolve(__dirname, '../apps/api/dist/db/migrations');

if (existsSync(src)) {
  mkdirSync(dist, { recursive: true });
  cpSync(src, dist, { recursive: true, force: true });
}
