# Decision Log — NihonPath

Dokumen pencatatan keputusan teknis dan arsitektural proyek NihonPath (format: tanggal, konteks, keputusan, alasan) sesuai standar §0 Aturan 1.

## Panduan Implementer (§0 Aturan 1 & 8)

Dokumen ini adalah **sumber kebenaran tunggal** (*single source of truth*) untuk keputusan teknis dan arsitektur proyek NihonPath. Seluruh engineer dan model implementer wajib mematuhi panduan berikut:

1. **Pencatatan Keputusan & Asumsi (§0 Aturan 1):**
   - Jika ada hal yang ambigu dalam spesifikasi teknis, pilih opsi paling sederhana yang konsisten dengan dokumen rancangan.
   - **Setiap asumsi, pemilihan pendekatan teknis baru, atau modifikasi arsitektur WAJIB dicatat di dokumen ini.**
   - Dilarang keras mengubah arsitektur atau menambahkan dependensi secara diam-diam (*no silent architectural drift*).
2. **Kewajiban Pencatatan Opsi B / Fallback (§0 Aturan 8):**
   - Jika spesifikasi teknis utama tidak dapat dipenuhi (misalnya pustaka tidak tersedia/kompatibel, keterbatasan platform, dsb.), implementer **DILARANG berimprovisasi diam-diam**.
   - Implementer WAJIB:
     1. Menggunakan **opsi B** yang sudah disiapkan di dokumen rancangan teknis, ATAU
     2. Mencatat *blocker* dan justifikasi pemilihan alternatif di decision log sebelum mengeksekusi, ATAU
     3. Mencatat *blocker* di decision log dan beralih mengerjakan task lain.
3. **Format Baku Entri:**
   Setiap entri keputusan wajib menggunakan struktur persis berikut:
   ```markdown
   ## YYYY-MM-DD — [Task-ID] Judul Keputusan

   - **Tanggal:** YYYY-MM-DD
   - **Konteks:** Latar belakang masalah, kebutuhan fitur/arsitektur, dan referensi pasal (§...).
   - **Keputusan:**
     1. Rincian keputusan teknis konkret yang diambil (termasuk opsi B jika relevan).
   - **Alasan:**
     - Justifikasi mengapa opsi ini dipilih dibanding alternatif lain serta kepatuhan DoD.
   ```

---

## 2026-10-11 — [M0-1] Monorepo Tooling, Linter, Formatter & CI Kerangka

- **Tanggal:** 2026-10-11
- **Konteks:** Inisialisasi struktur monorepo, tooling linter/formatter, validasi Conventional Commits, serta kerangka pipeline CI GitHub Actions untuk milestone M0-1 (§14.1 & §14.3).
- **Keputusan:**
  1. **Monorepo Manager:** Memilih `pnpm workspace` (`pnpm-workspace.yaml`) untuk mengelola TypeScript packages (`apps/api`, `packages/*`, `tools/*`).
  2. **TypeScript Linter & Formatter:** Menggunakan ESLint 9 flat configuration (`eslint.config.mjs`) dengan `typescript-eslint` (strict rules) dan Prettier dengan integrasi `eslint-config-prettier`.
  3. **Dart / Flutter Linter:** Mengonfigurasi `analysis_options.yaml` di root dan `apps/mobile/analysis_options.yaml` dengan aturan ketat (`strict-casts: true`, `strict-inference: true`, `strict-raw-types: true` dan aturan linter eksplisit).
  4. **Commit & Git Hooks:** Menggunakan `@commitlint/cli` + `@commitlint/config-conventional`, `lint-staged`, dan Husky hook (`pre-commit`, `commit-msg`).
  5. **CI Pipeline:** Menyusun `.github/workflows/ci.yml` dengan job terpisah `lint-node` dan `lint-dart` untuk kejelasan log output pada setiap PR dan push ke branch utama.
- **Alasan:**
  - `pnpm` cepat, hemat ruang disk dengan content-addressable store, dan handal untuk struktur monorepo.
  - Flat config merupakan standar masa depan ESLint 9, memberikan type-safety dan performa linting optimal.
  - Aturan ketat Dart memastikan tidak ada dynamic typing tak terduga sebelum kode Flutter M3 ditulis.
  - Memenuhi seluruh kriteria Definition of Done (DoD) M0-1 dan §0 Aturan 1-4.

---

## 2026-10-11 — [M0-2] OpenAPI v0, JSON Schema Konten & Generator Klien Dart/TS

- **Tanggal:** 2026-10-11
- **Konteks:** Penyusunan kontrak API OpenAPI v0, JSON Schema untuk konten kurikulum, serta generator otomatis klien Dart dan tipe TypeScript (Contract-First §0 Aturan 2, §8.1, §8.2, §9.1, §14.3).
- **Keputusan:**
  1. **Kontrak OpenAPI v0 (`packages/contracts/openapi.yaml`):**
     - Mendefinisikan endpoint dasar: `POST /auth/guest`, `GET /config`, `GET /content/manifest`, `POST /sync/push`, `GET /sync/pull`.
     - Standar error RFC 9457 `application/problem+json` dengan ekstensi wajib field `code` (enum `ErrorCode` standar §8.4) dan `trace_id` untuk korelasi observability terdistribusi (§10.1).
     - Skema keamanan HTTP Bearer JWT untuk endpoint sinkronisasi.
  2. **JSON Schema Konten (`packages/contracts/json-schema/`):**
     - Mendefinisikan schema Draft 2020-12 untuk item `vocab`, `kanji`, `grammar`, dan `kana`, serta unified schema `content-item.schema.json`.
     - Validasi ketat untuk integritas item: format `external_key`, ruby furigana segmen, minimal 1 audio & 1 contoh untuk vocab, dan provenance mnemonik (`human_reviewed` / `llm_draft`) (§9.1).
  3. **Tooling Code Generation:**
     - Backend TypeScript (NestJS): Menggunakan `openapi-typescript` untuk menghasilkan tipe type-safe deterministik di `apps/api/src/types/api.generated.ts`.
     - Mobile Flutter: Menggunakan `@openapitools/openapi-generator-cli` dengan target `dart-dio` di `apps/mobile/lib/data/api/`, memanfaatkan serialisasi `built_value` dan build runner deterministik.
  4. **Automasi Generator & Verifikasi CI:**
     - Skrip generator terpadu di `scripts/generate-contracts.mjs` (`pnpm run generate:contracts`) dan verifikator di `scripts/verify-contracts.mjs` (`pnpm run verify:contracts`).
     - Logging terstruktur ber-timestamp pada setiap tahap eksekusi generator dan verifikasi.
     - CI verification job `contracts-ci` di `.github/workflows/ci.yml` yang menjalankan unit test, breaking change detection menggunakan `oasdiff` terhadap target branch PR, dan git diff check untuk menggagalkan CI jika file ter-generate basi atau diedit manual.
- **Alasan:**
  - Menjamin prinsip contract-first: tipe backend dan klien mobile selalu diturunkan dari single source of truth (`openapi.yaml`), mencegah inkonsistensi payload antara backend NestJS dan mobile Flutter.
  - Sesuai standar DoD milestone M0-2 dan batasan arsitektur §0, §8, §9, dan §14.

---

## 2026-10-14 — [M0-3] Docker Compose Lokal & Observability Stack (Penggantian MinIO ke LocalStack)

- **Tanggal:** 2026-10-14
- **Konteks:** Penyediaan lingkungan pengembangan lokal terpadu menggunakan docker-compose yang mencakup database, cache, storage, dan stack observability (§4.2, §10, §14.2) dengan kompatibilitas penuh terhadap Podman.
- **Keputusan:**
  1. **Penggantian MinIO dengan LocalStack (S3 Community Edition):**
     - Mengganti service MinIO dengan `localstack/localstack:3.8` (S3 emulator).
     - Mengotomatisasi inisialisasi bucket `s3://nihonpath-packs` dan `s3://nihonpath-audio` melalui lifecycle hook `/etc/localstack/init/ready.d/01-create-buckets.sh` di region `ap-southeast-3` (Jakarta §4.2).
  2. **Database PostgreSQL 16 & Redis:**
     - Menggunakan image `postgres:16-alpine` dengan inisialisasi ekstensi `citext` dan `uuid-ossp` via `docker/postgres/init/01-init.sql`.
     - Menggunakan image `redis:7-alpine` untuk rate limiting dan antrean BullMQ.
  3. **Stack Observability Tiga Pilar (OpenTelemetry):**
     - OTel Collector (`otel/opentelemetry-collector-contrib:0.111.0`) sebagai gerbang sentral penerima OTLP via gRPC (`4317`) dan HTTP (`4318`).
     - Metrik disalurkan ke Prometheus (`prom/prometheus:v2.54.1`).
     - Log disalurkan ke Loki (`grafana/loki:3.1.1`) dengan OTLP HTTP ingestion.
     - Trace disalurkan ke Tempo (`grafana/tempo:2.6.0`).
     - Grafana (`grafana/grafana:11.2.0`) terkonfigurasi dengan datasource saling tertaut (Prometheus, Loki dengan derived field TraceID, dan Tempo dengan tracesToLogs) serta starter dashboard *Service Overview*.
  4. **Kompatibilitas Podman & Named Volumes:**
     - Seluruh persistensi data menggunakan top-level named volumes (`postgres_data`, `redis_data`, `localstack_data`, `prometheus_data`, `loki_data`, `tempo_data`, `grafana_data`) untuk menghindari isu hak akses filesystem host/WSL2 pada mode rootless.
     - Disediakan runner lintas-platform `scripts/docker-runner.mjs` yang secara deterministik mendeteksi `python -m podman_compose`, `podman-compose`, `podman compose`, maupun `docker compose`.
     - Script automasi `npm run docker:up`, `docker:down`, `docker:status`, `docker:logs`, dan `docker:verify` serta `Makefile` siap pakai.
- **Alasan:**
  - MinIO resmi mengarsipkan repositori open source publiknya (read-only) serta menghentikan pembaruan binary & Docker image resmi untuk Community Edition gratis demi fokus ke lini produk komersial berbayar (AIStor).
  - LocalStack Community Edition berlisensi Apache 2.0 yang permisif, aktif dipelihara, dan merupakan standar de facto industri untuk emulasi API AWS S3 lokal.
  - Memenuhi aturan §0 Aturan 1 & 8 dan seluruh kriteria DoD milestone M0-3.

---

## 2026-10-14 — [M0-4a] Terraform Jaringan & Layanan Container Dev

- **Tanggal:** 2026-10-14
- **Konteks:** Penyusunan modul Terraform untuk infrastruktur jaringan (VPC, Subnet multi-AZ) dan runtime container layanan API dan Worker di environment dev (§4.2, §11.2, §14.1, §14.2).
- **Keputusan:**
  1. **Remote State Backend (S3 & DynamoDB Locking):**
     - Menggunakan backend S3 dengan state locking via DynamoDB di region `ap-southeast-3` (Jakarta), enkripsi at-rest aktif (`encrypt = true`), dan pemisahan path state (`dev/terraform.tfstate`).
  2. **Modul Jaringan (`infra/terraform/modules/network`):**
     - VPC dengan DNS support dan hostnames aktif di region Jakarta (`ap-southeast-3`).
     - Subnet public dan private multi-AZ di `ap-southeast-3a`, `ap-southeast-3b`, dan `ap-southeast-3c`.
     - Internet Gateway dan NAT Gateway (konfigurasi single NAT untuk efisiensi biaya dev via `single_nat_gateway`).
     - Security Groups tersegmentasi: ALB SG (inbound 80/443), API SG (hanya menerima traffic port 3000 dari ALB SG), dan Worker SG (tanpa inbound, hanya outbound).
  3. **Modul Compute Layanan Container (`infra/terraform/modules/compute`):**
     - ECS Cluster Fargate dengan Container Insights aktif.
     - Application Load Balancer dengan healthcheck target group ke path `/healthz`.
     - Layanan API NestJS dengan Fargate launch type di private subnet, terhubung ke ALB, dan autoscaling target tracking CPU 60% (§11.2) dengan kapasitas 2–5 container.
     - Layanan Worker BullMQ (1 container) di private subnet.
     - CloudWatch Log Groups terstruktur per service (`/ecs/nihonpath-dev-api` dan `/ecs/nihonpath-dev-worker`).
  4. **IAM Least Privilege (§12.1):**
     - Task execution role terpisah dengan akses khusus ECR dan CloudWatch logs.
     - Task role terpisah untuk API dan Worker tanpa izin administratif berlebih.
  5. **Tooling & Verifikasi CI/CD:**
     - Menyiapkan script terstruktur `scripts/verify-terraform.mjs` yang memvalidasi formatting, inisialisasi modul, dependency resolution, eksekusi plan dev, serta memverifikasi tidak ada kebocoran file secret `.tfvars` atau file `.tfstate`.
     - Menambahkan script `npm run terraform:fmt`, `terraform:fmt:check`, dan `terraform:verify`.
     - Menambahkan test suite `tests/terraform.test.mjs` dan job `terraform-ci` pada `.github/workflows/ci.yml`.
- **Alasan:**
  - Menjamin arsitektur dev reproducible, terisolasi, hemat biaya untuk skala awal, dan siap diskalakan horizontal sesuai tahapan tangga skala §11.2.
  - Sesuai standar DoD milestone M0-4a dan batasan arsitektur §0, §4.2, §11.2, §12.1, dan §14.

---

## 2026-10-16 — [M0-4b] Terraform Data Stores Dev (PostgreSQL & Redis HA, PgBouncer, Cross-Region PITR)

- **Tanggal:** 2026-10-16
- **Konteks:** Penyusunan modul Terraform untuk provisioning database PostgreSQL primary HA multi-AZ dengan replica, connection pooler PgBouncer mode transaction, cross-region continuous PITR ke Singapura, dan Redis ElastiCache HA di environment dev (§4.2, §11.2, §11.3, §11.4, §12.1, §14.1, §14.2).
- **Keputusan:**
  1. **PostgreSQL 16 Multi-AZ Primary + 1 Read Replica (`infra/terraform/modules/database`):**
     - Menggunakan AWS RDS for PostgreSQL engine versi 16.4 dengan konfigurasi `multi_az = true` pada instance primary dan 1 read replica di subnet private lintas AZ Jakarta (`ap-southeast-3`).
     - Storage gp3 dengan kapasitas awal 20 GB dan autoscaling hingga 100 GB, terenkripsi at-rest menggunakan customer-managed KMS key.
     - Parameter group `postgres16` dengan konfigurasi wajib `statement_timeout = 3000` (3 detik) sesuai SLA/timeout §11.3, serta logging koneksi (`log_connections`, `log_disconnections`).
  2. **Connection Pooling PgBouncer Mode Transaction (§11.2):**
     - PgBouncer dijalankan sebagai container service di ECS Fargate (HA `desired_count = 2`) di private subnet di belakang internal Network Load Balancer (NLB) port 6432.
     - Mode pooling ditetapkan ke `transaction` (`POOL_MODE = transaction`, `SERVER_RESET_QUERY = DISCARD ALL`) untuk optimalisasi reuse koneksi transaksional backend NestJS tanpa risiko kebocoran state koneksi.
     - Endpoint NLB PgBouncer diinjeksikan secara otomatis ke compute API dan Worker via environment variable `DATABASE_URL`, sedangkan read replica diekspos melalui `DB_REPLICA_URL`.
  3. **Continuous PITR & Cross-Region Backup Replication ke Singapura (§11.4):**
     - Retensi backup snapshot dan continuous WAL archiving PITR disetel 14 hari pada RDS primary.
     - Mengonfigurasi `aws_db_instance_automated_backups_replication` dengan provider alias `aws.singapore` (`ap-southeast-1`) dan KMS key replikasi terdedikasi di region Singapura dengan retensi 14 hari, memastikan pemenuhan RPO ≤ 5 menit dan RTO ≤ 1 jam.
  4. **Redis ElastiCache HA (Multi-AZ) (§4.2, §11.2):**
     - Menggunakan `aws_elasticache_replication_group` Redis versi 7.1 dengan 2 node multi-AZ dan `automatic_failover_enabled = true`.
     - Parameter group ElastiCache dikonfigurasi dengan `maxmemory-policy = noeviction` untuk menjamin keandalan dan durabilitas antrean job BullMQ.
     - Enkripsi at-rest dan in-transit aktif dengan autentikasi auth token yang aman.
  5. **Integrasi Credential ke Secrets Manager & KMS (§12.1):**
     - Seluruh password dan token digenerate otomatis menggunakan resource Terraform `random_password`.
     - Kredensial dan metadata koneksi database serta Redis disimpan terpusat di AWS Secrets Manager yang dienkripsi oleh KMS key dengan rotasi kunci otomatis aktif (`enable_key_rotation = true`).
  6. **Observability & Cloud Monitoring (§10, §11):**
     - Mengaktifkan Enhanced Monitoring RDS dengan IAM role `AmazonRDSEnhancedMonitoringRole` pada interval 60 detik.
     - Menyiapkan CloudWatch Metric Alarms untuk 4 metrik esensial: CPUUtilization (> 80% selama 15 menit sesuai SLO §11.2), FreeableMemory (< 256 MB), FreeStorageSpace (< 5 GB), dan DatabaseConnections (> 80 koneksi).
  7. **Tooling & Verifikasi Otomatis:**
     - Memperbarui `scripts/verify-terraform.mjs` untuk mendukung validasi modul database dengan alias provider, eksekusi plan dev, serta verifikasi arsitektur konektivitas PgBouncer dan parameter `statement_timeout`.
     - Menambahkan 7 test suite baru di `tests/terraform.test.mjs` yang memvalidasi struktur modul database, parameter group, PgBouncer transaction mode, PITR replikasi Singapura, Redis HA, Secrets Manager, dan simulasi timeout query.
- **Alasan:**
  - Menjamin arsitektur database dev robust, highly available (Multi-AZ), siap menangani beban konkurensi dengan PgBouncer pooling, dan terlindungi dari bencana sesuai standar SLA/RPO/RTO §11.
  - Memenuhi seluruh kriteria Definition of Done (DoD) milestone M0-4b dan batasan arsitektur §0, §4.2, §11.2, §11.3, §11.4, §12.1, dan §14.

---

## 2026-10-16 — [M0-4c] Terraform Storage, CDN & Secret Management Dev

- **Tanggal:** 2026-10-16
- **Konteks:** Penyusunan modul Terraform untuk Object Storage paket konten dan audio pra-render, CDN CloudFront dengan Origin Access Control (OAC), mekanisme presigned URL & CloudFront signed URL, serta Secret Manager & KMS di environment dev (§4.2, §8.2, §8.3, §9.3, §11.4, §12.1, §13, §14.1, §14.2).
- **Keputusan:**
  1. **Object Storage S3 (`infra/terraform/modules/storage`):**
     - Menyediakan dua bucket terdedikasi: `${name_prefix}-${environment}-packs` untuk content packs dan `${name_prefix}-${environment}-audio` untuk audio pra-render.
     - Versioning wajib aktif (`status = "Enabled"`) pada kedua bucket sesuai ketentuan §11.4.
     - Server-side encryption default (AES256) dan pemblokiran total akses publik via `aws_s3_bucket_public_access_block` (`block_public_acls = true`, `block_public_policy = true`, `ignore_public_acls = true`, `restrict_public_buckets = true`) untuk memastikan file privat tidak bisa diakses publik secara langsung (§12.1).
     - Konfigurasi CORS dengan exposure header `Content-Range`, `ETag`, `Content-Length` untuk mendukung resumable download (HTTP Range) sesuai spesifikasi §9.3.
     - Menyediakan IAM policy `presigned_url_access` untuk backend API dalam meng-generate presigned URL unduhan konten premium (§8.2, §12.1).
  2. **CDN AWS CloudFront dengan OAC (`infra/terraform/modules/cdn`):**
     - Menggunakan AWS CloudFront terhubung ke bucket S3 origin via Origin Access Control (OAC - SigV4) tanpa mengekspos bucket S3 ke internet publik.
     - Aturan caching read-mostly: metode HTTP yang diizinkan `GET, HEAD, OPTIONS`, metode yang di-cache `GET, HEAD`, kompresi otomatis (gzip/brotli), dan viewer redirect ke HTTPS (protokol minimum TLS 1.2).
     - Mekanisme signed URL untuk paket premium via `aws_cloudfront_public_key` dan `aws_cloudfront_key_group` yang ditegakkan pada ordered cache behavior path `/premium/*` (§8.2, §12.1).
     - Cache behavior `/audio/*` dengan TTL panjang (default 30 hari) untuk file audio pra-render yang bersifat immutable.
     - Konfigurasi kebijakan bucket S3 (`aws_s3_bucket_policy`) yang membatasi hak akses baca `s3:GetObject` hanya untuk CloudFront distribution ARN melalui OAC.
  3. **Manajemen Kunci KMS & Secrets Manager (`infra/terraform/modules/secrets`):**
     - Customer Managed KMS Key dengan rotasi otomatis aktif (`enable_key_rotation = true`) untuk enkripsi kredensial aplikasi (§12.1).
     - Secret Manager untuk kunci penandatanganan JWT (`jwt_signing_key`): payload JSON terstruktur dengan `kid`, algoritma (ES256), public key, dan private key untuk mendukung rotasi kunci JWT (§8.3).
     - Secret Manager untuk third-party API keys (`third_party_api_keys`): kredensial provider email (SES/Postmark), RevenueCat webhook shared secret (§13), dan Google/Apple OIDC client secret (§8.2).
     - Secret Manager untuk CloudFront private signing key yang dipakai API backend untuk menandatangani URL paket premium.
     - Menyediakan IAM policy `secrets_read_access` untuk ECS task role backend API.
  4. **Observability & Logging CDN (§10, M0-4c):**
     - Dedicated access logs S3 bucket (`${name_prefix}-${environment}-cdn-logs`) dengan versioning, SSE, dan ownership controls untuk logging kode status HTTP CDN.
     - CloudWatch Metric Alarms untuk memantau error rate CDN: `5xxErrorRate` (> 5%) dan `4xxErrorRate` (> 10%) per interval 5 menit.
  5. **Integrasi Lingkungan Dev (`infra/terraform/environments/dev`):**
     - Menghubungkan modul storage, cdn, dan secrets ke dalam dev stack.
     - Menempelkan IAM policy presigned URL dan secrets read access ke API task role.
     - Menginjeksikan environment variables (`STORAGE_PACKS_BUCKET`, `STORAGE_AUDIO_BUCKET`, `CDN_DOMAIN`, `JWT_SECRET_ARN`, `THIRD_PARTY_SECRETS_ARN`) ke compute API dan Worker.
     - Mengekspor seluruh output esensial pada `outputs.tf`.
  6. **Tooling & Verifikasi Otomatis:**
     - Memperbarui `scripts/verify-terraform.mjs` untuk memvalidasi format, modul storage, cdn, secrets, spesifikasi kepatuhan arsitektur, dan eksekusi dev plan (109 resource).
     - Menambahkan 6 test suite baru di `tests/terraform.test.mjs`, termasuk simulasi izin bucket privat yang memverifikasi bahwa akses langsung tanpa CDN/presigned URL ditolak 403 Forbidden sedangkan akses dengan OAC / presigned URL diizinkan 200 OK.
- **Alasan:**
  - Memastikan distribusi konten kurikulum dan audio pra-render optimal, terlindungi dari scraping tidak sah, siap menangani paket premium berbayar, dan kredensial sensitif terisolasi dengan enkripsi KMS berotasi otomatis.
  - Memenuhi seluruh kriteria Definition of Done (DoD) milestone M0-4c dan batasan arsitektur §0, §4.2, §8.2, §8.3, §9.3, §10, §11.4, §12.1, §13, dan §14.

---

## 2026-10-16 — [M0-5] Template Standard Dokumentasi Teknis: Decision Log, ADR, dan Runbook

- **Tanggal:** 2026-10-16
- **Konteks:** Standarisasi dokumentasi teknis, Architecture Decision Record (ADR), dan operational runbook untuk menjamin tata kelola arsitektur, penanganan insiden, dan penelusuran keputusan teknis (§0 Aturan 1 & 8, §10.7, §14.1).
- **Keputusan:**
  1. **Format & Panduan Decision Log (`docs/decision-log.md`):**
     - Membakukan format baku: Tanggal, Konteks, Keputusan, Alasan sesuai mandat §0 Aturan 1.
     - Menegaskan kewajiban pencatatan asumsi dan pemilihan opsi B (§0 Aturan 8) tanpa improvisasi diam-diam.
  2. **Template Architecture Decision Record (`docs/adr/0000-template.md`):**
     - Menyusun template ADR dengan 4 bagian wajib: Konteks, Pilihan Keputusan, Keputusan Terpilih, Konsekuensi (positif, negatif, kompromi) serta metadata status siklus hidup keputusan.
  3. **Template Runbook Operasional (`docs/runbooks/TEMPLATE.md`):**
     - Menyusun template runbook insiden dengan struktur wajib §10.7: Dampak (SLO/SLI, user), Diagnosis 5 langkah terstruktur, Mitigasi darurat, dan Eskalasi/Incident Commander (SEV1–SEV4), dilengkapi pedoman postmortem 5 hari kerja tanpa menyalahkan.
  4. **Automasi Validasi Kepatuhan (`tests/docs-templates.test.mjs` & `scripts/verify-docs.mjs`):**
     - Menambahkan script verifikasi dan unit test untuk memvalidasi keberadaan ketiga file template dan memeriksa kepatuhan struktur format dokumen terhadap aturan §0 dan §10.7.
- **Alasan:**
  - Menghindari silent architectural drift dan ketidaksinkronan arsitektur antar kontributor atau implementer AI.
  - Memberikan panduan diagnosis insiden 5 langkah yang terstruktur untuk menekan MTTR saat alert operasional menyala.
  - Memenuhi seluruh kriteria Definition of Done (DoD) milestone M0-5 dan aturan dokumen §0, §10.7, dan §14.1.

---

## 2026-10-19 — [M1-1] Kerangka Backend NestJS: Config Tervalidasi Zod, Pino Logger Tanpa PII, OpenTelemetry, RFC 9457 Filter, Health Checks & Clock

- **Tanggal:** 2026-10-19
- **Konteks:** Inisialisasi dan penyusunan kerangka backend API NestJS dengan adapter Fastify, konfigurasi tervalidasi Zod, logging JSON Pino tanpa PII, OpenTelemetry tracing dan W3C traceparent context, error filter RFC 9457 application/problem+json, health endpoints (/healthz, /readyz), dan penyediaan provider abstraksi Clock (§0 Aturan 5, §4.2, §8.1, §8.2, §10.2, §10.4, §14.1, M1-1).
- **Keputusan:**
  1. **NestJS dengan Fastify Adapter (`apps/api`):**
     - Menggunakan NestJS dengan Fastify adapter (`@nestjs/platform-fastify` & `fastify`) untuk throughput maksimal dan latensi rendah pada endpoint API backend.
  2. **12-Factor Config dengan Zod Schema (`src/common/config`):**
     - Mengimplementasikan `EnvSchema` dengan Zod untuk validasi ketat env var startup (`NODE_ENV`, `PORT`, `HOST`, `DATABASE_URL`, `REDIS_URL`, `USER_HASH_SECRET`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `CORS_ORIGIN`).
     - Melempar `ConfigValidationError` deskriptif saat konfigurasi wajib hilang atau tidak memenuhi standar keamanan.
  3. **Pino Logger JSON Satu Baris & Penyaring PII Ketat (`src/common/logging`):**
     - Membangun `PinoLoggerService` dan `LoggingInterceptor` yang secara deterministik menghasilkan log JSON satu baris dengan 12 field wajib §10.2: `ts`, `level`, `service`, `env`, `version`, `trace_id`, `span_id`, `route`, `status`, `latency_ms`, `error_code`, `user_hash`.
     - `user_hash` dihasilkan via HMAC-SHA256 dari `user_id` dengan rahasia `USER_HASH_SECRET`.
     - Menerapkan fungsi sanitasi rekursif `sanitizeLogData` dan `sanitizeIp` yang memotong IP ke subnet /24 (IPv4) atau /48 (IPv6) serta mereduksi token, email, password, kode OTP, jawaban bebas/teks, dan meringkas payload sync (`ops`).
  4. **OpenTelemetry SDK & Propagasi W3C Trace Context (`src/common/telemetry`):**
     - Mengintegrasikan NodeSDK dengan auto-instrumentation HTTP, pg, dan ioredis.
     - Menyediakan utilitas parser W3C `traceparent` (`00-{trace_id}-{span_id}-{flags}`) dan resolver trace context terdistribusi yang menyematkan `X-Trace-Id` pada header respon HTTP.
  5. **Global Exception Filter RFC 9457 Problem Details (`src/common/errors`):**
     - Menerapkan `Rfc9457ExceptionFilter` global dengan header `Content-Type: application/problem+json; charset=utf-8`.
     - Memformat seluruh kegagalan (AppException, ZodError validasi, HttpException, error tak terduga) ke schema RFC 9457 dengan ekstensi wajib `code` dan `trace_id`.
  6. **Endpoint Operasional Health Check (`src/modules/health`):**
     - `GET /healthz`: liveness probe cepat mengembalikan 200 OK dan timestamp UTC.
     - `GET /readyz`: readiness probe yang memeriksa koneksi DB (`SELECT 1`) dan Redis (`PING`), mengembalikan 200 OK jika keduanya up dan 503 Service Unavailable jika salah satu down.
  7. **Abstraksi Waktu UTC `Clock` (`src/common/clock`):**
     - Menyediakan interface `Clock` dan provider `SystemClock` untuk seluruh logika bisnis guna mematuhi larangan pemanggilan `Date.now()` langsung (§0 Aturan 5), serta `MockClock` untuk unit testing deterministik.
- **Alasan:**
  - Fastify adapter menawarkan efisiensi I/O tinggi untuk target throughput dan latensi server NihonPath (p95 < 500 ms).
  - Skema error RFC 9457 menjamin integrasi kontrak API yang konsisten dengan klien mobile Flutter dan mempermudah korelasi debugging via `trace_id`.
  - Filter PII ketat mencegah pelanggaran privasi pengguna di seluruh pipeline logging.
  - Memenuhi seluruh kriteria Definition of Done (DoD) milestone M1-1 dan Aturan Dokumen §0, §4.2, §8.1, §8.2, §10.2, §10.4, dan §14.1.

---

## 2026-10-20 — [M1-2] Migrasi 001 (Seluruh Skema §6.3), Partisi review_logs, Kysely Typed, dan Konfigurasi Pool PostgreSQL

- **Tanggal:** 2026-10-20
- **Konteks:** Mengimplementasikan migrasi SQL murni lengkap untuk seluruh skema PostgreSQL (§6.3) beserta partisi rentang `review_logs`, partisi pengaman default `review_logs_default`, tipe TypeScript Kysely typed, migrasi atomik naik-turun, serta connection pool PostgreSQL dengan batasan timeout dan metrik saturasi (§4.2, §6.3, §10.3, §11.3, §12.1, M1-2).
- **Keputusan:**
  1. **Migrasi SQL Murni (`apps/api/src/db/migrations/001_initial_schema.sql`):**
     - Menggunakan `node-pg-migrate` dengan divider `-- Up Migration` dan `-- Down Migration` untuk mengeksekusi DDL SQL murni tanpa abstraksi ORM magic (§4.2).
     - Membuat ekstensi `citext` dan 15 tabel PostgreSQL sesuai spesifikasi persis §6.3: `users`, `auth_identities`, `devices`, `refresh_tokens`, `content_items`, `lessons`, `lesson_items`, `content_packs`, `user_sync_state`, `user_cards`, `review_logs`, `review_logs_default`, `user_settings`, `lesson_progress`, `test_attempts`, dan `subscriptions`.
     - Tabel `review_logs` dipartisi berdasarkan rentang waktu `PARTITION BY RANGE (reviewed_at)` dengan indeks komposit `(user_id, user_seq)` dan `(user_id, card_id, reviewed_at)`.
     - Partisi default `review_logs_default` dibuat sebagai pengaman partisi untuk menangkap entri sebelum partisi bulanan dibuat atau di luar rentang aktif (§6.3).
     - Langkah `down` membersihkan seluruh tabel secara terbalik dan atomik menggunakan `DROP TABLE IF EXISTS ... CASCADE` serta `DROP EXTENSION IF EXISTS citext CASCADE`.
  2. **Type-Safe Query Builder Kysely (`apps/api/src/db/types.ts`):**
     - Mendefinisikan interface TypeScript untuk ke-15 tabel dengan Kysely `Generated` dan `ColumnType` untuk integritas compile-time tanpa mengorbankan performa query murni SQL (§4.2).
  3. **Connection Pool Kysely & Keamanan Runtime (`apps/api/src/db/client.ts`):**
     - Membangun connection pool `pg.Pool` dan instance `Kysely<Database>` dengan penegakan `statement_timeout` 3 detik (3000 ms) via parameter pool dan event hook `SET statement_timeout = 3000` pada setiap koneksi baru (§11.3).
     - Menyediakan opsi penetapan role non-DDL `applicationRole` (`SET ROLE ...`) pada sesi runtime produksi (§12.1).
  4. **Observability & Metrik Saturasi Pool (§10.3):**
     - Mengekspos fungsi `getDbPoolMetrics(pool)` yang menghitung `db_pool_in_use` (`totalCount - idleCount`) dan `db_pool_waiting` (`waitingCount`) untuk pemantauan saturasi koneksi di Prometheus/Grafana.
     - Menyediakan logging eksekusi migrasi rapi berformat standar di `apps/api/src/db/migrator.ts`.
  5. **Pengujian Integration Test Multi-Runtime (`tests/db-migrations.test.mjs`):**
     - Mengimplementasikan integration test suite komprehensif yang memvalidasi migrasi naik, verifikasi seluruh skema dan relkind partisi, verifikasi partition routing data ke `review_logs_default` dan partisi bulanan spesifik, verifikasi pembatalan query akibat `statement_timeout` (SQLSTATE 57014), dan migrasi turun tuntas.
     - Menggunakan Testcontainers PostgreSQL dengan fallback cerdas ke container transient Podman/Docker CLI pada environment lokal tanpa Docker socket proxy, menjamin pengujian 100% lulus di CI maupun lingkungan lokal.
- **Alasan:**
  - Kysely menyediakan query builder type-safe tanpa black-box ORM, sepenuhnya mendukung query kompleks UNION ALL pada modul sync serta skema partisi PostgreSQL native (§4.2).
  - Penegakan `statement_timeout` 3 detik mencegah query runaway memblokir connection pool dan menurunkan ketersediaan layanan (§11.3).
  - Skema partisi rentang menjamin throughput tulis tinggi dan pengarsipan historis mudah pada tabel `review_logs` (§6.3, §11.1).
  - Memenuhi seluruh kriteria Definition of Done (DoD) milestone M1-2 dan batasan arsitektur §0, §4.2, §6.3, §10.3, §11.3, dan §12.1.

