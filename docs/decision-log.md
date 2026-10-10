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
