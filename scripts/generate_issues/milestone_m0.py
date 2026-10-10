"""Milestone M0: Fondasi issues."""

from typing import List
from .common import IssueSpec

def get_m0_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M0-1",
            title="Monorepo, linter, formatter, CI kerangka",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="infra",
            tujuan="Menginisialisasi struktur monorepo sesuai standar §14.1 beserta tooling linting, formatting, dan kerangka pipeline CI GitHub Actions.",
            acuan="§0 Aturan 3 & 4, §14.1 (Struktur monorepo), §14.3 (Pipeline CI/CD)",
            input_data="Dokumen teknis §14.1 dan §14.3",
            output_data="Struktur direktori monorepo di root repo, konfigurasi linter/formatter, dan workflow `.github/workflows/ci.yml`.",
            langkah=[
                "Buat struktur folder monorepo persis sesuai §14.1: `apps/mobile/`, `apps/api/`, `packages/contracts/`, `content/` (`_pool`), `tools/content-cli/`, `infra/terraform/`, `docs/` (`runbooks/`, `adr/`), `.github/workflows/`.",
                "Konfigurasi root tooling: pnpm workspace atau npm workspaces untuk TypeScript packages.",
                "Setup ESLint dan Prettier dengan aturan strict untuk Node.js/TypeScript.",
                "Setup `analysis_options.yaml` untuk Dart/Flutter dengan aturan linting ketat.",
                "Konfigurasi Git hooks / lint-staged (jika relevan) dan validasi Conventional Commits.",
                "Buat GitHub Actions workflow `.github/workflows/ci.yml` yang menjalankan linting dan formatting check untuk seluruh workspace pada setiap PR."
            ],
            tes=[
                "CI GitHub Actions berjalan dan berstatus hijau (green) pada PR kosong.",
                "Linter mendeteksi dan memblokir pelanggaran formatting / syntax error pada kode TypeScript dan Dart."
            ],
            observability=[
                "Log output GitHub Actions jelas dan rapi menampilkan langkah linting serta formatting."
            ],
            out_of_scope=[
                "Implementasi kode fitur aplikasi mobile atau endpoint API bisnis.",
                "Penyusunan pipeline deployment produksi/staging."
            ],
            aturan_ketat=[
                "Struktur monorepo wajib mengikuti §14.1 tanpa memindahkan atau mengubah nama folder inti.",
                "Trunk-based development dengan branch pendek dan conventional commits (§14.3).",
                "Dilarang menambahkan dependensi yang tidak relevan dengan fondasi linter/formatter."
            ],
            labels=["M0: Fondasi", "size:M", "area:infra"]
        ),
        IssueSpec(
            id="M0-2",
            title="openapi.yaml v0 (auth, config, manifest, sync) + JSON Schema konten + generator klien Dart/TS",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="backend",
            tujuan="Menyusun kontrak API openapi.yaml v0, JSON Schema untuk konten, serta generator otomatis klien Dart dan tipe TypeScript (Contract-First).",
            acuan="§0 Aturan 2 (Contract-first), §8.1, §8.2, §9.1 tahap 5, §14.1, §14.3",
            input_data="Spesifikasi endpoint §8.2, tipe error §8.1, dan struktur data konten §9.2.",
            output_data="`packages/contracts/openapi.yaml`, file schema di `packages/contracts/json-schema/`, script generator, klien Dart ter-generate di `apps/mobile/lib/data/api/`, dan tipe TypeScript di `apps/api/src/`.",
            langkah=[
                "Definisikan kontrak `packages/contracts/openapi.yaml` v0 untuk endpoint dasar: `/auth/guest`, `/config`, `/content/manifest`, `/sync/push`, `/sync/pull` dengan format error RFC 9457.",
                "Definisikan JSON Schema untuk item konten (`vocab`, `kanji`, `grammar`, `kana`) di `packages/contracts/json-schema/`.",
                "Konfigurasi tooling code generation: `openapi-generator-cli` dengan target `dart-dio` untuk Flutter, dan `openapi-typescript` untuk backend NestJS.",
                "Buat npm/pnpm script `generate:contracts` untuk menjalankan generasi kode secara deterministik.",
                "Tambahkan langkah verifikasi di CI (`.github/workflows/ci.yml`) menggunakan `oasdiff` dan git diff check untuk memastikan klien hasil generate tidak basi / out-of-sync."
            ],
            tes=[
                "Unit test: eksekusi script generasi kode menghasilkan klien Dart dan tipe TypeScript yang valid tanpa error kompilasi.",
                "CI test: verifikasi CI gagal jika ada perubahan manual pada file hasil generate atau `openapi.yaml` dimodifikasi tanpa meng-generate ulang klien."
            ],
            observability=[
                "Logging detail pada generator script dan CI validation check."
            ],
            out_of_scope=[
                "Implementasi endpoint handler NestJS di backend.",
                "Implementasi repository data Drift di Flutter."
            ],
            aturan_ketat=[
                "Contract-first WAJIB (§0 Aturan 2): Klien Dart dan tipe TypeScript HARUS dihasilkan dari kontrak OpenAPI, BUKAN ditulis tangan.",
                "Format error harus sesuai RFC 9457 `application/problem+json` dengan field tambahan `code` dan `trace_id` (§8.1).",
                "Perubahan API hanya boleh bersifat aditif (§8.1)."
            ],
            labels=["M0: Fondasi", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M0-3",
            title="docker-compose lokal (Postgres, Redis, MinIO, OTel Collector, Grafana)",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="infra",
            tujuan="Menyediakan lingkungan pengembangan lokal terpadu menggunakan docker-compose yang mencakup database, cache, storage, dan stack observability.",
            acuan="§4.2 (Pilihan teknologi), §10.2, §10.3, §10.4, §14.2 (Lingkungan lokal)",
            input_data="Kebutuhan stack teknologi §4.2 dan §14.2.",
            output_data="File `docker-compose.yml`, direktori konfigurasi `docker/`, dan script `make up` / `npm run docker:up`.",
            langkah=[
                "Buat `docker-compose.yml` yang menjalankan service: PostgreSQL 16 (dengan ekstensi `citext`), Redis (Alpine), MinIO (S3-compatible object storage), OpenTelemetry Collector, Prometheus, Loki, Tempo, dan Grafana.",
                "Konfigurasi bucket MinIO awal (`nihonpath-packs`, `nihonpath-audio`) secara otomatis saat kontainer start.",
                "Konfigurasi OTel Collector pipeline untuk menerima OTLP via gRPC/HTTP dan meneruskan metrik ke Prometheus, log ke Loki, dan trace ke Tempo.",
                "Konfigurasi datasource Grafana siap pakai (Prometheus, Loki, Tempo).",
                "Sediakan script automasi (misal `make up` atau npm script) dan data seed kecil untuk verifikasi."
            ],
            tes=[
                "Jalankan `docker-compose up -d`: semua kontainer berstatus healthy.",
                "Verifikasi pengiriman contoh span trace dummy ke OTel Collector dan pastikan trace muncul di antarmuka Grafana."
            ],
            observability=[
                "Healthcheck aktif untuk setiap service di docker-compose.",
                "Log kontainer teragregasi rapi."
            ],
            out_of_scope=[
                "Deployment ke server cloud staging/produksi.",
                "Isi data kurikulum lengkap (hanya dummy seed kecil)."
            ],
            aturan_ketat=[
                "PostgreSQL minimal versi 16 (§4.2).",
                "Stack observability harus memakai standar terbuka OpenTelemetry (§4.2).",
                "Dilarang membocorkan password atau kredensial produksi ke file docker-compose lokal."
            ],
            labels=["M0: Fondasi", "size:M", "area:infra"]
        ),
        IssueSpec(
            id="M0-4a",
            title="Terraform Jaringan & Layanan Container Dev",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="infra",
            tujuan="Menyusun modul Terraform untuk jaringan (VPC, Subnet multi-AZ) dan runtime container layanan API dan Worker di environment dev.",
            acuan="§4.2 (Pilihan teknologi), §11.2 (Tangga skala tahap 1), §14.1, §14.2",
            input_data="Arsitektur cloud dev di Region Jakarta (AWS ap-southeast-3 / GCP asia-southeast2).",
            output_data="Modul Terraform di `infra/terraform/modules/network` dan `infra/terraform/modules/compute` beserta environment dev `infra/terraform/environments/dev`.",
            langkah=[
                "Konfigurasi remote state backend Terraform (S3/GCS bucket dengan state locking).",
                "Tulis modul Terraform untuk VPC, private subnet multi-AZ, public subnet, NAT Gateway, dan Security Groups di Region Jakarta.",
                "Tulis modul Terraform untuk layanan compute container (Cloud Run / AWS ECS Fargate / K8s terkelola) untuk API (autoscale CPU 60%) dan 1 worker BullMQ.",
                "Setup IAM role dengan prinsip Least Privilege untuk service container.",
                "Konfigurasi variable dan environment dev di `infra/terraform/environments/dev`."
            ],
            tes=[
                "Eksekusi `terraform validate` dan `terraform fmt -check` berhasil di CI.",
                "Eksekusi `terraform plan` di lingkungan dev berhasil tanpa error resolusi dependensi."
            ],
            observability=[
                "Logging Terraform plan dan apply terstruktur."
            ],
            out_of_scope=[
                "Provisioning database PostgreSQL dan Redis (dikerjakan di M0-4b).",
                "Provisioning bucket storage dan CDN (dikerjakan di M0-4c)."
            ],
            aturan_ketat=[
                "Lokasi Region WAJIB Jakarta (AWS ap-southeast-3 atau GCP asia-southeast2) (§4.2).",
                "IAM menerapkan prinsip least privilege (§12.1).",
                "Dilarang commit file secret `.tfvars` atau state Terraform ke repositori Git (§0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M0-4 sesuai arahan §15.",
            labels=["M0: Fondasi", "size:M", "area:infra"]
        ),
        IssueSpec(
            id="M0-4b",
            title="Terraform Data Stores Dev (PostgreSQL & Redis HA)",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="infra",
            tujuan="Menyusun modul Terraform untuk provisioning database PostgreSQL primary HA multi-AZ dengan replica dan Redis HA di environment dev.",
            acuan="§4.2 (Postgres 16+, Redis), §11.2 (Tangga skala 1), §11.4 (Backup & PITR)",
            input_data="Modul jaringan dari M0-4a.",
            output_data="Modul Terraform di `infra/terraform/modules/database` dan integrasinya di `infra/terraform/environments/dev`.",
            langkah=[
                "Tulis modul Terraform untuk PostgreSQL terkelola HA multi-AZ (versi minimal 16) dengan 1 read replica.",
                "Konfigurasi PgBouncer dalam mode transaction untuk connection pooling (§11.2).",
                "Konfigurasi backup otomatis: Point-In-Time Recovery (PITR) kontinu, retensi 14 hari, dan replikasi backup snapshot lintas region ke Singapura (§11.4).",
                "Tulis modul Terraform untuk Redis terkelola HA (multi-AZ) untuk cache, rate limit, dan BullMQ.",
                "Integrasikan credential database dan Redis ke Secret Manager / KMS terkelola."
            ],
            tes=[
                "Eksekusi `terraform validate` dan `terraform plan` untuk modul database sukses.",
                "Uji konektivitas PgBouncer dan verifikasi parameter `statement_timeout` 3 detik (§11.3)."
            ],
            observability=[
                "Metrik CPU, memori, disk, dan koneksi DB diekspor ke cloud monitoring."
            ],
            out_of_scope=[
                "Eksekusi migrasi skema tabel (dikerjakan di M1-2).",
                "Konfigurasi compute container (dikerjakan di M0-4a)."
            ],
            aturan_ketat=[
                "PostgreSQL wajib primary HA multi-AZ + 1 replica (§11.2).",
                "PITR kontinu dengan retensi 14 hari dan salinan lintas region Singapura wajib dikonfigurasi (§11.4).",
                "RPO target ≤ 5 menit, RTO ≤ 1 jam (§11.4)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M0-4 sesuai arahan §15.",
            labels=["M0: Fondasi", "size:M", "area:infra"]
        ),
        IssueSpec(
            id="M0-4c",
            title="Terraform Storage, CDN & Secret Management Dev",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="M",
            area="infra",
            tujuan="Menyusun modul Terraform untuk Object Storage paket konten/audio, CDN, dan Secret Manager di environment dev.",
            acuan="§4.2 (Object storage & CDN), §9.3 (Distribusi paket), §12.1 (Keamanan kredensial)",
            input_data="Kebutuhan distribusi paket konten §9.3 dan kebutuhan secret backend §12.1.",
            output_data="Modul Terraform di `infra/terraform/modules/storage` dan `infra/terraform/modules/cdn`.",
            langkah=[
                "Tulis modul Terraform untuk S3-compatible Object Storage bucket dengan versioning aktif untuk content packs dan audio pra-render.",
                "Tulis modul CDN (Cloudflare atau AWS CloudFront) yang mengarah ke Object Storage dengan aturan caching read-mostly.",
                "Konfigurasi signed URL / presigned URL mechanism untuk bucket storage paket premium (§8.2, §12.1).",
                "Tulis modul KMS / Secret Manager untuk rotasi kunci penandatanganan JWT (ES256/EdDSA) dan API keys pihak ketiga.",
                "Integrasikan modul storage dan CDN ke `infra/terraform/environments/dev`."
            ],
            tes=[
                "Eksekusi `terraform validate` dan `terraform plan` sukses.",
                "Verifikasi permission bucket privat: akses langsung tanpa CDN / presigned URL ditolak (403 Forbidden)."
            ],
            observability=[
                "Metrik akses CDN dan HTTP status code logging."
            ],
            out_of_scope=[
                "Unggah file paket konten riil (dikerjakan di M2-3).",
                "Implementasi endpoint billing verifikasi (dikerjakan di M6-1)."
            ],
            aturan_ketat=[
                "Object storage WAJIB mengaktifkan versioning (§11.4).",
                "Bucket konten tidak boleh dibuat public-read untuk file premium (§12.1).",
                "Dilarang menyimpan hardcoded secrets di script Terraform."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M0-4 sesuai arahan §15.",
            labels=["M0: Fondasi", "size:M", "area:infra"]
        ),
        IssueSpec(
            id="M0-5",
            title="Template decision log, ADR, runbook",
            milestone="M0 — Fondasi",
            milestone_num=1,
            size="S",
            area="infra",
            tujuan="Menyiapkan template standar dokumentasi teknis: decision-log.md, ADR, dan runbook operasional.",
            acuan="§0 Aturan 1 & 8, §10.7 (Runbook), §14.1 (Struktur docs)",
            input_data="Format decision log §0 Aturan 1 dan struktur runbook §10.7.",
            output_data="File `docs/decision-log.md`, `docs/adr/0000-template.md`, dan `docs/runbooks/TEMPLATE.md`.",
            langkah=[
                "Buat `docs/decision-log.md` dengan format baku: Tanggal, Konteks, Keputusan, Alasan (§0 Aturan 1) dan sertakan contoh entri.",
                "Buat template ADR di `docs/adr/0000-template.md` (Konteks, Pilihan Keputusan, Keputusan Terpilih, Konsekuensi).",
                "Buat template runbook di `docs/runbooks/TEMPLATE.md` yang memuat struktur wajib §10.7: Dampak, Diagnosis 5 langkah, Mitigasi, Eskalasi.",
                "Sertakan panduan bagi implementer bahwa setiap asumsi atau pemilihan opsi B wajib dicatat di decision log."
            ],
            tes=[
                "Verifikasi keberadaan ketiga file template dan pastikan format sesuai aturan dokumen §0 dan §10.7."
            ],
            observability=[
                "Ketersediaan dokumentasi terverifikasi di repository."
            ],
            out_of_scope=[
                "Penulisan runbook alert spesifik (dikerjakan bersamaan dengan alert di M5-2)."
            ],
            aturan_ketat=[
                "Format decision log harus persis: tanggal, konteks, keputusan, alasan (§0 Aturan 1).",
                "Runbook wajib memuat struktur diagnosis 5 langkah (§10.7)."
            ],
            labels=["M0: Fondasi", "size:S", "area:infra"]
        )
    ]
