# Decision Log — NihonPath

Dokumen pencatatan keputusan teknis dan arsitektural proyek NihonPath (format: tanggal, konteks, keputusan, alasan) sesuai standar §0 Aturan 1.

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
