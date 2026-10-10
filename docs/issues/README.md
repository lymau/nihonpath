# NihonPath — Daftar GitHub Issues & Task Breakdown

Dokumen ini memuat daftar lengkap seluruh GitHub Issue yang dipartisi secara ketat berdasarkan spesifikasi teknis `NihonPath — Rancangan Teknis Aplikasi Belajar Bahasa Jepang N5–N1.md`.

**Total Issue:** 72 tasks  
**Aturan Eksekusi:** Satu issue = Satu PR kecil (< ±400 baris diff) sesuai Definition of Done (DoD) §0.

---


## M0 — Fondasi

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M0-1` | Monorepo, linter, formatter, CI kerangka | `infra` | `M` | §0 Aturan 3 & 4, §14.1 (Struktur monorepo), §14.3 (Pipeline CI/CD) | [M0-1.md](./M0-1.md) |
| `M0-2` | openapi.yaml v0 (auth, config, manifest, sync) + JSON Schema konten + generator klien Dart/TS | `backend` | `M` | §0 Aturan 2 (Contract-first), §8.1, §8.2, §9.1 tahap 5, §14.1, §14.3 | [M0-2.md](./M0-2.md) |
| `M0-3` | docker-compose lokal (Postgres, Redis, MinIO, OTel Collector, Grafana) | `infra` | `M` | §4.2 (Pilihan teknologi), §10.2, §10.3, §10.4, §14.2 (Lingkungan lokal) | [M0-3.md](./M0-3.md) |
| `M0-4a` | Terraform Jaringan & Layanan Container Dev | `infra` | `M` | §4.2 (Pilihan teknologi), §11.2 (Tangga skala tahap 1), §14.1, §14.2 | [M0-4a.md](./M0-4a.md) |
| `M0-4b` | Terraform Data Stores Dev (PostgreSQL & Redis HA) | `infra` | `M` | §4.2 (Postgres 16+, Redis), §11.2 (Tangga skala 1), §11.4 (Backup & PITR) | [M0-4b.md](./M0-4b.md) |
| `M0-4c` | Terraform Storage, CDN & Secret Management Dev | `infra` | `M` | §4.2 (Object storage & CDN), §9.3 (Distribusi paket), §12.1 (Keamanan kredensial) | [M0-4c.md](./M0-4c.md) |
| `M0-5` | Template decision log, ADR, runbook | `infra` | `S` | §0 Aturan 1 & 8, §10.7 (Runbook), §14.1 (Struktur docs) | [M0-5.md](./M0-5.md) |

## M1 — Backend Inti

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M1-1` | Kerangka NestJS: config tervalidasi, pino, OTel, /healthz /readyz, filter error RFC 9457, Clock | `backend` | `M` | §4.2 (Pilihan teknologi), §8.1 (Aturan umum API), §10.2 (Logging), §10.4 (Tracing), §14.1 (Struktur monorepo), §0 Aturan 5 | [M1-1.md](./M1-1.md) |
| `M1-2` | Migrasi 001 (seluruh skema §6.3) + Kysely typed | `backend` | `M` | §4.2 (Kysely + node-pg-migrate), §6.3 (Skema PostgreSQL lengkap), §11.3 (Migrasi) | [M1-2.md](./M1-2.md) |
| `M1-3` | Auth: guest, refresh rotation + reuse detection, JWKS | `backend` | `M` | §4.2 (Auth tanpa lock-in), §6.3 (users, auth_identities, devices, refresh_tokens), §8.2, §8.3 (Autentikasi), §12.1 (Pencegahan token theft) | [M1-3.md](./M1-3.md) |
| `M1-4` | Auth: OIDC Google/Apple, OTP email | `backend` | `M` | §4.2 (OIDC Google/Apple, email OTP), §6.3, §7.4 (Guest -> akun), §8.2, §8.3, §12.1 (Anti brute-force & anti-enumerasi) | [M1-4.md](./M1-4.md) |
| `M1-5` | /me, /config, job penghapusan dan ekspor akun | `backend` | `M` | §6.3 (users), §8.2 (Endpoint Akun & Config), §11.3 (Circuit breaker), §12.2 (Privasi & Penghapusan akun) | [M1-5.md](./M1-5.md) |
| `M1-6` | Modul content: manifest (ETag) + download-url bertanda tangan | `backend` | `M` | §6.3 (content_packs), §8.2 (Konten), §9.3 (Anggaran ukuran dan distribusi), §12.1 (Proteksi konten), §13 (Entitlement) | [M1-6.md](./M1-6.md) |
| `M1-7a` | Sync Push (POST /v1/sync/push) & Serialisasi Transaksi | `backend` | `M` | §6.3 (user_sync_state, user_cards, review_logs), §7.1, §7.2, §7.3 (Aturan merge), Lampiran C.2 (Handler push server) | [M1-7a.md](./M1-7a.md) |
| `M1-7b` | Sync Pull (GET /v1/sync/pull) & Cursor Pagination | `backend` | `M` | §6.3 (user_cards, review_logs, user_settings, lesson_progress, test_attempts), §7.2 (GET /v1/sync/pull), Lampiran C.3 (Handler pull server) | [M1-7b.md](./M1-7b.md) |
| `M1-7c` | Testing Modul Sync: Property Tests, Paralelisme & Keamanan IDOR | `backend` | `M` | §7.3 (Aturan merge), §11.5 (Chaos & concurrency test), §12.1 (Pencegahan IDOR), §14.4 (Strategi pengujian backend) | [M1-7c.md](./M1-7c.md) |
| `M1-8` | Rate limiting Redis + metrik §10.3 + dashboard awal | `backend` | `M` | §8.1 (Rate limit), §10.3 (Metrik penamaan Prometheus), §10.7 (Dashboard awal), §11.3 (Degradasi fail-open Redis) | [M1-8.md](./M1-8.md) |
| `M1-9` | Job pembuat partisi + alert partisi DEFAULT | `backend` | `S` | §6.3 (Manajemen partisi), §10.3 (partition_default_rows), §10.7 (Alerting) | [M1-9.md](./M1-9.md) |

## M2 — Content Pipeline dan Konten Awal

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M2-1a` | CLI Ingest JMdict & KANJIDIC2 | `content` | `M` | §3.2 (Sumber data dan lisensi), §9.1 tahap 1 (Ingest), §14.1 (tools/content-cli) | [M2-1a.md](./M2-1a.md) |
| `M2-1b` | CLI Ingest KanjiVG & Tatoeba | `content` | `M` | §3.2 (Sumber data dan lisensi), §9.1 tahap 1 (Ingest), §14.1 (tools/content-cli) | [M2-1b.md](./M2-1b.md) |
| `M2-1c` | CLI Pool Manager & Pemetaan Level JLPT Komunitas | `content` | `M` | §2 (Frekuensi dan lexical coverage), §3.1 (Cakupan per level), §3.2 (Lisensi komunitas), §9.1 tahap 2 (Kurasi) | [M2-1c.md](./M2-1c.md) |
| `M2-2` | Validator konten (§9.1 tahap 5) + laporan cakupan | `content` | `M` | §3.2 (Aturan LLM & lisensi), §3.3 (Prinsip kanji-in-context), §9.1 tahap 4 & 5 (Validasi), §9.2 (Schema konten) | [M2-2.md](./M2-2.md) |
| `M2-3` | Builder paket + publish + rollback manifest | `content` | `M` | §4.2 (Storage & CDN), §6.3 (content_packs), §9.1 tahap 6 & 7 (Build & Publish), §9.3 (Anggaran ukuran dan distribusi) | [M2-3.md](./M2-3.md) |
| `M2-4` | Pipeline audio TTS (multi-suara, Opus) | `content` | `M` | §2 (Pelatihan fonetik variabilitas tinggi), §3.2 (Lisensi ToS TTS), §5.5 (Audio pra-render), §9.1 tahap 3 (Enrichment), §9.3 (Anggaran audio) | [M2-4.md](./M2-4.md) |
| `M2-5` | Konten Level 0 (kana): audio, goresan | `content` | `M` | §3.1 (Level 0 Kana), §3.3 (Hierarki konten), §3.4 (Facet kana), §9.1, §9.2 | [M2-5.md](./M2-5.md) |
| `M2-6a` | Kurasi Silabus N5 & Penyusunan Struktur Unit/Lesson | `content` | `M` | §3.1 (Target N5), §3.3 (Hierarki konten: Unit -> Lesson), §3.4 (Tipe item & facet) | [M2-6a.md](./M2-6a.md) |
| `M2-6b` | Enrichment Konten N5 (Contoh, Tokenisasi, Furigana & Audio) | `content` | `M` | §3.2 (Sudachi/UniDic), §5.5 (Furigana segmentasi), §9.1 tahap 3 (Enrichment), §9.2 (Contoh item YAML sumber) | [M2-6b.md](./M2-6b.md) |
| `M2-6c` | Tinjauan Manusia Konten N5 (Human Review) | `content` | `M` | §3.2 (Aturan review manusia), §9.1 tahap 4 & 5 (Review & Validasi), §15 (M2-6) | [M2-6c.md](./M2-6c.md) |

## M3 — Flutter Inti (Offline)

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M3-1` | Kerangka app: flavor, Forui preset ajeneb, AppColors, l10n id/en, Clock, IdGenerator, router | `mobile` | `M` | §4.2 (Pilihan mobile), §5.1 (Struktur feature-first), §5.2 (Paket diizinkan), §5.2.1 (Forui preset ajeneb), §5.5 (Font Noto Sans JP), §5.6 (Aksesibilitas & l10n) | [M3-1.md](./M3-1.md) |
| `M3-2` | Skema SQLite klien (Drift) + DAO + tes migrasi | `mobile` | `M` | §4.2 (Drift di atas SQLite), §5.1 (data/), §6.1 (Konvensi ID & status), §6.2 (Skema SQLite klien lengkap) | [M3-2.md](./M3-2.md) |
| `M3-3a` | Content Pack Downloader (Range Resume & Verifikasi SHA-256) | `mobile` | `M` | §5.2 (dio, crypto), §9.3 (Anggaran ukuran dan distribusi), §11.3 (Degradasi CDN) | [M3-3a.md](./M3-3a.md) |
| `M3-3b` | Content Pack Installer & FTS Seeder | `mobile` | `M` | §5.2 (archive), §5.5 (Pencarian FTS5), §6.2 (pack_state, fts_items), §9.3 (Distribusi paket) | [M3-3b.md](./M3-3b.md) |
| `M3-4` | Pembungkus Scheduler + FSRS + golden test ≥50 skenario | `mobile` | `M` | §2 (Penjadwalan FSRS-6 & konfigurasi), §5.4 (SRS engine di klien), §16.3 (Determinisme FSRS), §16.4 | [M3-4.md](./M3-4.md) |
| `M3-5` | queue_builder (§3.6) + tes | `mobile` | `M` | §3.6 (Rencana harian dan pembentukan antrean), §16.3 (Jebakan pergantian hari jam 04:00) | [M3-5.md](./M3-5.md) |
| `M3-6a` | UI ReviewCard, Pilihan Ganda & Flashcard Rating | `mobile` | `M` | §3.4 (Facet MVP), §3.6 (Mapping rating), §5.2.1 (Pemetaan widget Forui), §5.5 (Audio & Furigana JpText) | [M3-6a.md](./M3-6a.md) |
| `M3-6b` | Input Jawaban Ketik & Normalisasi Teks Jepang | `mobile` | `M` | §3.4 (Facet recall), §5.2.1 (FTextField), §16.3 (Normalisasi teks Jepang & komposisi IME) | [M3-6b.md](./M3-6b.md) |
| `M3-6c` | Controller Sesi Review & Transaksi DB Tunggal | `mobile` | `M` | §1 NFR (Transisi <100ms, data loss 0), §3.6 (Mapping rating), §5.4 (Alur review), §16.3 (Satu review = satu transaksi), Lampiran C.1 (onAnswer pseudocode) | [M3-6c.md](./M3-6c.md) |
| `M3-7` | Alur pelajaran (perkenalan, kuis, ringkasan) | `mobile` | `M` | §2 (Retrieval practice), §3.3 (Hierarki lesson), §3.5 (Alur pelajaran 4 langkah), §5.3 (/lesson/:id) | [M3-7.md](./M3-7.md) |
| `M3-8` | Home, progres, forecast beban review | `mobile` | `M` | §3.6 (Urutan Home & Rencana harian), §5.2.1 (Pemetaan Forui & ForecastBars), §5.3 (/home, /progress, /library), §5.5 (Pencarian FTS5), §5.6 (Performa kueri terindeks) | [M3-8.md](./M3-8.md) |
| `M3-9` | Kana: tabel, latihan, tulis tangan (ML Kit) + animasi goresan | `mobile` | `M` | §3.1 (Level 0 Kana), §3.4 (Facet kana), §5.2 (google_mlkit_digital_ink_recognition, flutter_svg), §5.2.1, §5.3 (/kana), §5.5 (Tulisan tangan) | [M3-9.md](./M3-9.md) |
| `M3-10` | Onboarding, pengaturan, notifikasi lokal harian | `mobile` | `M` | §1 (Guest mode), §5.2 (flutter_local_notifications), §5.3 (/onboarding, /settings), §10.6, §12.2 (Persetujuan privasi & tombol hapus akun) | [M3-10.md](./M3-10.md) |

## M4 — Auth dan Sync Klien

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M4-1` | Klien API ter-generate + alur auth + secure storage + refresh otomatis | `mobile` | `M` | §4.2 (flutter_secure_storage, dio), §8.1 (Header & Error), §8.3 (Autentikasi & Rotasi token), §12.1 (Pencegahan token theft) | [M4-1.md](./M4-1.md) |
| `M4-2a` | Outbox DAO & Queue Manager Klien | `mobile` | `M` | §4.3 (Prinsip outbox), §6.2 (Tabel outbox), §7.1 (Push berbasis outbox), §7.2 (Batas batch), Lampiran C.1 (requestSync debounce) | [M4-2a.md](./M4-2a.md) |
| `M4-2b` | SyncClient Loop Push & Pull | `mobile` | `M` | §1 NFR (Latensi sync & nol data loss), §7.2 (Endpoint sync), §7.4 (Algoritma klien lengkap), §16.3 (Validasi jam perangkat salah) | [M4-2b.md](./M4-2b.md) |
| `M4-2c` | Client Merge Engine | `mobile` | `M` | §6.2 (Skema lokal), §7.3 (Aturan merge tabel lengkap), §7.4 | [M4-2c.md](./M4-2c.md) |
| `M4-3` | Pemicu sync + workmanager + backoff berjitter | `mobile` | `M` | §5.2 (workmanager, connectivity_plus), §7.4 (Pemicu sync & backoff berjitter) | [M4-3.md](./M4-3.md) |
| `M4-4` | Fault injection sync (putus, 500, lambat, 429) | `mobile` | `M` | §1 NFR (Nol kehilangan data review, offline-first), §5.7 (Fault injection), §7.4 (Backoff eksponensial) | [M4-4.md](./M4-4.md) |
| `M4-5` | Tautkan guest, hapus akun, ekspor data (UI) | `mobile` | `M` | §5.3 (/settings, tautan akun), §7.4 (Guest -> akun), §8.2, §12.2 (Penghapusan akun & ekspor data UI) | [M4-5.md](./M4-5.md) |

## M5 — Observability, Hardening, Beta Tertutup

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M5-1` | Sentry, metrik klien, analitik dengan consent | `mobile` | `M` | §5.2 (sentry_flutter), §10.5 (Observability sisi klien), §10.6 (Analitik produk), §12.2 (Persetujuan privasi UU PDP & GDPR) | [M5-1.md](./M5-1.md) |
| `M5-2` | Dashboard, alert burn-rate, runbook (§10.7) | `security-ops` | `M` | §10.3 (Metrik penamaan Prometheus), §10.7 (SLO, alert, dashboard, runbook), §11.3 | [M5-2.md](./M5-2.md) |
| `M5-3` | Load/soak/chaos test (§11.5) | `qa` | `M` | §1 NFR (SLO ketersediaan 99,9%, latensi sync p95 < 500 ms), §11.1 (Model kapasitas), §11.5 (Skenario k6 lengkap) | [M5-3.md](./M5-3.md) |
| `M5-4` | Checklist MASVS L1 + tinjauan keamanan | `security-ops` | `M` | §12.1 (Ancaman utama dan kontrol lengkap), §14.3 (CI security scanning) | [M5-4.md](./M5-4.md) |
| `M5-5` | Latihan restore backup | `security-ops` | `S` | §11.4 (Backup dan pemulihan bencana), §15 (M5-5), Lampiran B (Checklist pra-rilis) | [M5-5.md](./M5-5.md) |
| `M5-6` | Beta tertutup (TestFlight, Play Internal) | `qa` | `M` | §1 NFR (Crash-free sessions > 99,5%), §10.7 (Client release health), §11.6 (Strategi rilis mobile), §14.3 (Fastlane), §15 (M5-6) | [M5-6.md](./M5-6.md) |

## M6 — Rilis v1

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M6-1a` | Integrasi SDK RevenueCat & Layar Paywall Klien | `mobile` | `M` | §5.2 (purchases_flutter), §5.3 (/paywall), §11.3 (Degradasi RevenueCat), §13 (Monetisasi & Billing) | [M6-1a.md](./M6-1a.md) |
| `M6-1b` | Backend Webhook Handler RevenueCat | `backend` | `M` | §6.3 (Tabel subscriptions), §8.2 (Billing), §10.3 (billing_verify_total), §13 (Monetisasi & Billing) | [M6-1b.md](./M6-1b.md) |
| `M6-1c` | Penegakan Entitlement Server pada Paket Konten Premium | `backend` | `M` | §6.3 (content_packs.is_premium), §8.2 (download-url), §12.1 (Proteksi konten premium), §13 (Freemium: N5 gratis, N4-N1 premium) | [M6-1c.md](./M6-1c.md) |
| `M6-2a` | Silabus, Kurasi & Enrichment Konten Level N4 | `content` | `M` | §3.1 (Target N4), §3.2 (Lisensi & LLM), §3.3 (Hierarki), §9.1 (Pipeline konten), §9.2 | [M6-2a.md](./M6-2a.md) |
| `M6-2b` | Silabus, Kurasi & Enrichment Konten Level N3 | `content` | `M` | §3.1 (Target N3), §3.2 (Lisensi & LLM), §3.3, §9.1 (Pipeline konten), §9.2 | [M6-2b.md](./M6-2b.md) |
| `M6-3a` | Content Pipeline Reading Bertingkat & Listening | `content` | `M` | §2 (Extensive reading 95-98% coverage), §3.7 (Reading & Listening), §9.1, §9.3 (Anggaran passages) | [M6-3a.md](./M6-3a.md) |
| `M6-3b` | UI Layar Reading (/reading/:id) & Listening (/listening/:id) | `mobile` | `M` | §3.7 (Skill lain: Reading & Listening), §5.2.1, §5.3 (/reading/:id, /listening/:id) | [M6-3b.md](./M6-3b.md) |
| `M6-4` | Aset Toko, Privasi, Atribusi Lisensi, Kebijakan Penghapusan Akun | `security-ops` | `M` | §3.2 (Atribusi lisensi terbuka), §12.2 (Privasi, UU PDP, GDPR, Hapus akun), §16.3 (Kebijakan toko & batasan merek JLPT) | [M6-4.md](./M6-4.md) |
| `M6-5` | Staged Rollout Produksi v1 dengan Gerbang §11.6 | `security-ops` | `S` | §1 NFR, §10.7 (SLO ketersediaan & crash-free), §11.6 (Strategi rilis bertahap mobile & backend), Lampiran B (Checklist pra-rilis) | [M6-5.md](./M6-5.md) |

## M7 — N2–N1 dan Mock Test

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M7-1` | Engine Mock Test bergaya JLPT | `mobile` | `M` | §3.7 (Mock test bergaya JLPT), §5.3 (/mocktest/:id), §6.2 (Tabel test_attempts), §16.3 (Disclaimer skor & batasan resmi) | [M7-1.md](./M7-1.md) |
| `M7-2` | Konten N2 dan N1 | `content` | `L` | §3.1 (Target N2 & N1), §3.2 (Lisensi & LLM), §3.3, §9.1, §9.3 | [M7-2.md](./M7-2.md) |
| `M7-3` | Penambahan Facet Lanjutan SRS (Listening, Kanji Writing, Grammar Production) | `mobile` | `M` | §2 (Pelatihan fonetik & Output Swain), §3.4 (Facet ditunda ke fase 2), §5.5 (Tulisan tangan kanji) | [M7-3.md](./M7-3.md) |

## M8 — Fase 3

| ID | Judul | Area | Ukuran | Acuan | File |
| --- | --- | --- | --- | --- | --- |
| `M8-1` | Optimizer Server FSRS untuk Personalisasi Parameter | `backend` | `M` | §5.4 (Personalisasi optimizer server), §6.3 (user_settings), §15 (M8 Fase 3) | [M8-1.md](./M8-1.md) |
| `M8-2` | Latihan Shadowing dengan Rekaman Suara | `mobile` | `M` | §2 (Pelatihan fonetik variabilitas tinggi & shadowing), §15 (M8 Fase 3) | [M8-2.md](./M8-2.md) |
| `M8-3` | Backfill Riwayat Log Sinkronisasi di Latar Belakang | `mobile` | `M` | §7.4 (Perangkat baru bootstrap & backfill lazy), §15 (M8 Fase 3) | [M8-3.md](./M8-3.md) |
| `M8-4` | Update Paket Konten Delta | `content` | `M` | §9.3 (Distribusi paket & update delta fase 2/3), §15 (M8 Fase 3) | [M8-4.md](./M8-4.md) |
| `M8-5` | Adaptasi Layout Tablet dan Widget Layar Utama | `mobile` | `M` | §5.6 (Aksesibilitas & tata letak), §15 (M8 Fase 3) | [M8-5.md](./M8-5.md) |
| `M8-6` | Partner Percakapan Berbasis LLM dengan Guardrail & Batasan Biaya | `backend` | `M` | §1 Non-goals MVP (tanpa LLM runtime di MVP), §3.2 (Aturan LLM), §15 (M8 Fase 3 LLM conversation partner) | [M8-6.md](./M8-6.md) |