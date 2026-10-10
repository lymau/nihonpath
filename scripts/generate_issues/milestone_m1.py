"""Milestone M1: Backend Inti issues."""

from typing import List
from .common import IssueSpec

def get_m1_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M1-1",
            title="Kerangka NestJS: config tervalidasi, pino, OTel, /healthz /readyz, filter error RFC 9457, Clock",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Membangun kerangka backend NestJS (Fastify adapter) dengan konfigurasi tervalidasi Zod, logging Pino tanpa PII, OpenTelemetry tracing, error filter RFC 9457, health checks, dan abstraksi Clock.",
            acuan="§4.2 (Pilihan teknologi), §8.1 (Aturan umum API), §10.2 (Logging), §10.4 (Tracing), §14.1 (Struktur monorepo), §0 Aturan 5",
            input_data="Spesifikasi teknis backend di `apps/api/`.",
            output_data="Aplikasi NestJS di `apps/api/` dengan Fastify, `AppModule`, `common/` modules, filter error global, health endpoints, dan provider `Clock`.",
            langkah=[
                "Inisialisasi aplikasi NestJS menggunakan adapter Fastify dan TypeScript strict mode di `apps/api/`.",
                "Implementasikan modul config 12-factor berbasis env var dengan validasi schema Zod saat aplikasi startup.",
                "Integrasikan logger Pino JSON satu baris dengan field wajib (§10.2): `ts`, `level`, `service`, `env`, `version`, `trace_id`, `span_id`, `route`, `status`, `latency_ms`, `error_code`, `user_hash` (HMAC-SHA256 dari `user_id`).",
                "Pasang filter/interceptor penyaring PII ketat: DILARANG mencatat email, token, kode OTP, isi jawaban bebas, IP mentah (hanya simpan /24 yang dipotong atau hash), atau payload sync penuh (§10.2).",
                "Integrasikan OpenTelemetry SDK dengan auto-instrumentation HTTP, pg, dan ioredis serta propagasi W3C `traceparent` (§10.4).",
                "Buat Exception Filter global yang memformat seluruh error ke RFC 9457 `application/problem+json` dengan field tambahan `code` dan `trace_id` (§8.1).",
                "Buat endpoint operasional: `GET /healthz` (liveness) dan `GET /readyz` (readiness yang mengecek koneksi DB dan Redis) (§8.2).",
                "Buat interface dan provider `Clock` untuk menyuplai waktu UTC ke seluruh logika bisnis (§0 Aturan 5, Dilarang `Date.now()` langsung)."
            ],
            tes=[
                "Unit test: validasi config melempar error saat env var wajib hilang.",
                "Unit test: exception filter memformat error ke schema RFC 9457 problem+json.",
                "Unit test: logger pino menyertakan trace_id dan tidak membocorkan field terlarang (PII).",
                "Integration test: endpoint `/healthz` mengembalikan 200 OK dan `/readyz` mengembalikan status kesiapan DB/Redis."
            ],
            observability=[
                "Log Pino format JSON terstruktur memuat trace_id dan span_id di setiap request.",
                "Tracing span otomatis terinisialisasi untuk incoming request."
            ],
            out_of_scope=[
                "Implementasi modul auth, sync, atau content (dikerjakan di task berikutnya).",
                "Skema database Kysely (dikerjakan di M1-2)."
            ],
            aturan_ketat=[
                "WAJIB NestJS dengan adapter Fastify dan TypeScript strict (§4.2).",
                "DILARANG memanggil `Date.now()` mentah di logika bisnis; gunakan abstraksi `Clock` (§0 Aturan 5).",
                "Format error WAJIB RFC 9457 problem+json dengan field `code` dan `trace_id` (§8.1).",
                "DILARANG mencatat PII ke log (§10.2)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-2",
            title="Migrasi 001 (seluruh skema §6.3) + Kysely typed",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan migrasi SQL murni lengkap untuk seluruh skema PostgreSQL (§6.3) beserta partisi review_logs dan tipe Kysely.",
            acuan="§4.2 (Kysely + node-pg-migrate), §6.3 (Skema PostgreSQL lengkap), §11.3 (Migrasi)",
            input_data="Skema DDL PostgreSQL di §6.3 dokumen teknis.",
            output_data="File migrasi SQL murni di `apps/api/src/db/migrations/`, tipe Kysely di `apps/api/src/db/types.ts`, dan instance Kysely pool di `apps/api/src/db/client.ts`.",
            langkah=[
                "Tulis file migrasi SQL murni `001_initial_schema.sql` (menggunakan node-pg-migrate):",
                "  - Ekstensi `citext`.",
                "  - Tabel `users`, `auth_identities`, `devices`, `refresh_tokens` (dengan index `user_id, family_id`).",
                "  - Tabel `content_items` (index `jlpt_level, type`), `lessons`, `lesson_items`, `content_packs`.",
                "  - Tabel `user_sync_state`, `user_cards` (index `user_id, user_seq`), `user_settings`, `lesson_progress`, `test_attempts`, `subscriptions`.",
                "  - Tabel `review_logs` yang terpartisi: `PARTITION BY RANGE (reviewed_at)` dengan indeks `(user_id, user_seq)` dan `(user_id, card_id, reviewed_at)`.",
                "  - Buat partisi default awal `review_logs_default` sebagai pengaman partisi.",
                "Tulis langkah migrasi turun (`down`) yang membersihkan seluruh tabel secara atomik.",
                "Generate tipe TypeScript Kysely dari skema database.",
                "Konfigurasi connection pool Kysely ke PostgreSQL dengan `statement_timeout` 3 detik (§11.3) dan role aplikasi tanpa hak DDL (§12.1)."
            ],
            tes=[
                "Integration test menggunakan Testcontainers PostgreSQL: migrasi naik (`up`) berhasil membuat seluruh skema §6.3.",
                "Testcontainers: migrasi turun (`down`) membersihkan seluruh skema tanpa error.",
                "Testcontainers: uji penulisan data ke partisi `review_logs` dan verifikasi partition routing."
            ],
            observability=[
                "Log eksekusi migrasi tercatat rapi.",
                "Metrik saturasi pool database `db_pool_in_use` dan `db_pool_waiting` terekspos (§10.3)."
            ],
            out_of_scope=[
                "Job otomatisasi pembuatan partisi bulanan masa depan (dikerjakan di M1-9).",
                "Query controller/service fitur."
            ],
            aturan_ketat=[
                "Skema DDL WAJIB persis sesuai §6.3 dokumen; dilarang mengubah nama kolom, tipe data, atau constraint tanpa izin.",
                "Tabel `review_logs` WAJIB terpartisi rentang `reviewed_at` (§6.3).",
                "Gunakan Kysely dan SQL murni, BUKAN ORM dengan magic (§4.2).",
                "Role DB aplikasi dilarang memiliki hak DDL saat runtime produksi (§12.1)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-3",
            title="Auth: guest, refresh rotation + reuse detection, JWKS",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint autentikasi guest, rotasi refresh token dengan deteksi reuse pencurian token, endpoint logout, serta publikasi JWKS.",
            acuan="§4.2 (Auth tanpa lock-in), §6.3 (users, auth_identities, devices, refresh_tokens), §8.2, §8.3 (Autentikasi), §12.1 (Pencegahan token theft)",
            input_data="Kontrak OpenAPI endpoint auth, skema tabel DB M1-2.",
            output_data="Module auth di `apps/api/src/modules/auth/`, controller, service, dan endpoint `/v1/auth/guest`, `/v1/auth/refresh`, `/v1/auth/logout`, `/.well-known/jwks.json`.",
            langkah=[
                "Implementasikan pembuatan JWT access token berumur 15 menit menggunakan penandatanganan ES256/EdDSA dengan header `kid` pendukung rotasi key (§8.3).",
                "Sediakan endpoint publik `/.well-known/jwks.json` yang mengekspos public keys (§8.3).",
                "Endpoint `POST /v1/auth/guest`: buat entri di tabel `users` dengan `is_guest = true`, catat `devices`, buat `family_id` dan hash SHA-256 refresh token (256-bit entropy, TTL 30 hari), kembalikan JWT dan refresh token.",
                "Endpoint `POST /v1/auth/refresh`: verifikasi hash refresh token di database. Jalankan rotasi wajib: terbitkan refresh token baru dan perbarui `replaced_by`.",
                "Deteksi Reuse Token: jika token yang sudah digunakan / dicabut dipanggil kembali, deteksi sebagai pencurian token -> segera cabut SELURUH refresh token dalam `family_id` yang sama, catat audit log, dan increment metrik `auth_refresh_reuse_detected_total` (§8.3, §10.3, §12.1).",
                "Endpoint `POST /v1/auth/logout`: cabut seluruh family token perangkat peminta."
            ],
            tes=[
                "Unit test: pembuatan JWT dengan klaim yang benar dan verifikasi JWKS publik.",
                "Integration test: alur `POST /v1/auth/guest` berhasil membuat akun guest dan mengembalikan pasangan token.",
                "Integration test: alur refresh token menghasilkan token baru dan membatalkan token lama.",
                "Security test: simulasi pemanggilan ulang token lama (reuse) membatalkan seluruh token dalam satu `family_id` dan menolak request berikutnya."
            ],
            observability=[
                "Metrik `auth_login_total{provider='guest', result='success|failure'}` (§10.3).",
                "Metrik `auth_refresh_reuse_detected_total` saat deteksi pencurian token (§10.3).",
                "Log audit INFO untuk kejadian pembuatan akun dan deteksi reuse."
            ],
            out_of_scope=[
                "Login OIDC Google/Apple dan OTP Email (dikerjakan di M1-4).",
                "Penyimpanan token di klien mobile Flutter (dikerjakan di M4-1)."
            ],
            aturan_ketat=[
                "Access token JWT WAJIB berumur 15 menit, ditandatangani ES256 atau EdDSA (§8.3).",
                "Refresh token WAJIB 256-bit acak, disimpan sebagai HASH SHA-256 (jangan simpan token mentah) (§8.3).",
                "Deteksi pemakaian ulang refresh token WAJIB mencabut seluruh `family_id` (§8.3, §12.1).",
                "DILARANG mencatat token mentah ke dalam log (§10.2)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-4",
            title="Auth: OIDC Google/Apple, OTP email",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint autentikasi OIDC Google & Apple Sign-In, verifikasi OTP email via transactional email provider, serta endpoint tautkan akun.",
            acuan="§4.2 (OIDC Google/Apple, email OTP), §6.3, §7.4 (Guest -> akun), §8.2, §8.3, §12.1 (Anti brute-force & anti-enumerasi)",
            input_data="Public keys OIDC Google/Apple, konfigurasi SES/Postmark, kontrak OpenAPI.",
            output_data="Endpoint `/v1/auth/oidc`, `/v1/auth/email/start`, `/v1/auth/email/verify`, dan `/v1/auth/link` di module auth.",
            langkah=[
                "Endpoint `POST /v1/auth/oidc`: validasi id_token Google dan Apple Sign-In terhadap public keys resmi; cari atau buat user di `users` dan `auth_identities` (provider `google` / `apple`).",
                "Endpoint `POST /v1/auth/email/start`: generate 6-digit OTP acak (TTL 10 menit, batas 5 percobaan), simpan HASH OTP di Redis; kirim kode via provider email transaksional (SES/Postmark).",
                "Terapkan perlindungan anti-enumerasi: respons harus seragam tanpa memberitahukan apakah email sudah terdaftar (§8.3).",
                "Endpoint `POST /v1/auth/email/verify`: verifikasi hash OTP dari Redis. Jika valid, buat/ambil user dan link ke `auth_identities` (provider `email`).",
                "Endpoint `POST /v1/auth/link`: tautkan identitas Google/Apple/Email baru ke `user_id` guest yang sedang aktif. Jika identitas sudah dimiliki akun lain, kembalikan konflik (MVP tidak melakukan auto-merge diam-diam, §7.4).",
                "Terapkan rate limiting Redis sliding window: 30 request/menit per IP untuk endpoint auth (§8.1)."
            ],
            tes=[
                "Unit test: verifikasi mock OIDC token Google dan Apple.",
                "Integration test: alur email OTP start dan verify (kode valid -> sukses, kode salah > 5 kali -> diblokir, kode expired -> ditolak).",
                "Security test: endpoint start email tidak membocorkan status eksistensi email.",
                "Integration test: linking identitas ke guest berhasil; identitas ganda memicu konflik."
            ],
            observability=[
                "Metrik `auth_login_total{provider='google|apple|email', result='success|failure'}` (§10.3).",
                "Log audit INFO untuk registrasi dan login baru (email wajib di-hash/scrubbed, §10.2)."
            ],
            out_of_scope=[
                "SDK UI Apple Sign-In dan Google Sign-In di Flutter (dikerjakan di M4-1).",
                "Email template marketing (hanya email transaksional OTP)."
            ],
            aturan_ketat=[
                "OTP email WAJIB 6 digit, TTL 10 menit, maksimal 5 percobaan, disimpan sebagai HASH di Redis (§8.2, §8.3).",
                "DILARANG membocorkan keberadaan email pengguna (anti-enumerasi) (§8.3).",
                "Rate limit auth WAJIB 30 req/menit/IP (§8.1).",
                "DILARANG mencatat alamat email mentah atau kode OTP ke dalam log (§10.2)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-5",
            title="/me, /config, job penghapusan dan ekspor akun",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint profil /me, remote config /config, serta job async BullMQ untuk penghapusan permanen akun (UU PDP/GDPR) dan ekspor data.",
            acuan="§6.3 (users), §8.2 (Endpoint Akun & Config), §11.3 (Circuit breaker), §12.2 (Privasi & Penghapusan akun)",
            input_data="Autentikasi JWT guard, BullMQ queue, S3 presigned URL generator.",
            output_data="Module user & config di `apps/api/src/modules/users/`, `apps/api/src/modules/config/`, serta background workers di `apps/api/src/jobs/`.",
            langkah=[
                "Endpoint `GET /v1/me` dan `PATCH /v1/me`: ambil dan perbarui data pengguna (`display_name`, `locale` 'id'/'en', `timezone`, `target_level`). Ambil `user_id` strictly dari token JWT (§12.1).",
                "Endpoint `GET /v1/config`: kembalikan remote configuration (feature flags, parameter remote, dan `min_app_version` untuk memicu layar paksa perbarui aplikasi, §8.1).",
                "Endpoint `DELETE /v1/me`: inisiasi penghapusan akun; segera cabut seluruh refresh token dan set `deleted_at = now()`. Masukkan job async BullMQ untuk menghapus permanen seluruh data user (cascade delete tabel pengguna) dalam batas 30 hari serta trigger penghapusan data analitik via API PostHog (§12.2).",
                "Endpoint `POST /v1/me/export`: inisiasi ekspor data; buat job async BullMQ untuk menghimpun data pengguna (kartu, review log, pengaturan, progres) ke format JSON, unggah ke S3, dan kembalikan tautan unduh bertanda tangan dengan TTL 24 jam (§8.2, §12.2)."
            ],
            tes=[
                "Integration test: `PATCH /v1/me` memperbarui preferensi user dan memvalidasi enum locale.",
                "Integration test: `GET /v1/config` mengembalikan schema config dan versi min app.",
                "Integration test: `DELETE /v1/me` menonaktifkan akun, token tidak dapat dipakai lagi, dan job BullMQ berhasil mengeksekusi penghapusan cascade.",
                "Integration test: `POST /v1/me/export` menghasilkan file JSON data pengguna lengkap dan URL bertanda tangan berumur 24 jam."
            ],
            observability=[
                "Metrik BullMQ: `bullmq_queue_depth`, `bullmq_job_duration_seconds`, `bullmq_job_failed_total` (§10.3).",
                "Log audit INFO saat akun diminta dihapus atau diekspor."
            ],
            out_of_scope=[
                "Layar antarmuka Flutter untuk hapus akun (dikerjakan di M4-5).",
                "Pembayaran billing (dikerjakan di M6-1)."
            ],
            aturan_ketat=[
                "`user_id` SELALU diambil dari JWT; DILARANG mengambil dari path/body request (anti-IDOR) (§12.1).",
                "Penghapusan akun WAJIB menghapus permanen data dalam 30 hari dan memicu API PostHog (§12.2).",
                "Tautan unduh ekspor data WAJIB bertanda tangan dengan batas umur maksimal 24 jam (§12.2)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-6",
            title="Modul content: manifest (ETag) + download-url bertanda tangan",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint manifest paket konten dengan dukungan ETag caching serta endpoint download-url bertanda tangan dengan verifikasi entitlement paket premium.",
            acuan="§6.3 (content_packs), §8.2 (Konten), §9.3 (Anggaran ukuran dan distribusi), §12.1 (Proteksi konten), §13 (Entitlement)",
            input_data="Tabel `content_packs`, service S3 presigned URL, service entitlement billing.",
            output_data="Module content di `apps/api/src/modules/content/` dengan endpoint `GET /v1/content/manifest` dan `GET /v1/content/packs/:id/download-url`.",
            langkah=[
                "Endpoint `GET /v1/content/manifest?level={0..5}`: query paket konten aktif dari tabel `content_packs` (id, level, kind, version, sha256, size_bytes, is_premium).",
                "Hitung ETag berdasarkan hash representasi manifest; jika request mengirim header `If-None-Match` yang cocok, kembalikan HTTP 304 Not Modified (§8.2).",
                "Endpoint `GET /v1/content/packs/:id/download-url`: ambil record paket konten. Jika `is_premium == true`, periksa entitlement aktif pengguna.",
                "Jika paket premium dan pengguna tidak memiliki langganan aktif, kembalikan error RFC 9457 dengan code `ENTITLEMENT_REQUIRED` (§8.4, §13).",
                "Jika diizinkan (atau paket gratis), buat presigned download URL S3/CDN berumur pendek (misal 15 menit) dan kembalikan ke klien."
            ],
            tes=[
                "Integration test: `GET /v1/content/manifest` mengembalikan header ETag, dan request ulang dengan `If-None-Match` mengembalikan status 304.",
                "Security test: akses `download-url` paket gratis berhasil mengembalikan URL bertanda tangan.",
                "Security test: akses `download-url` paket premium tanpa entitlement mengembalikan 403 Forbidden dengan kode `ENTITLEMENT_REQUIRED`."
            ],
            observability=[
                "Logging INFO untuk setiap permintaan download URL (mencatat user_hash dan pack_id).",
                "Metrik Prometheus HTTP duration untuk endpoint konten."
            ],
            out_of_scope=[
                "Pipeline builder paket konten zip (dikerjakan di M2-3).",
                "Integrasi webhook store RevenueCat (dikerjakan di M6-1)."
            ],
            aturan_ketat=[
                "Paket premium WAJIB dilindungi presigned URL berumur pendek dan verifikasi entitlement (§8.2, §12.1).",
                "Endpoint manifest WAJIB mendukung header ETag (§8.2).",
                "DILARANG membuat public-read direct link ke object storage untuk paket berbayar."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-7a",
            title="Sync Push (POST /v1/sync/push) & Serialisasi Transaksi",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint push sinkronisasi dengan validasi payload, serialisasi row-lock user_sync_state, evaluasi aturan merge LWW, dan penomoran user_seq gapless.",
            acuan="§6.3 (user_sync_state, user_cards, review_logs), §7.1, §7.2, §7.3 (Aturan merge), Lampiran C.2 (Handler push server)",
            input_data="Payload push batch dari klien (max 200 ops, max 512 KB), koneksi PostgreSQL Kysely.",
            output_data="Endpoint `POST /v1/sync/push` di `apps/api/src/modules/sync/` dan service push sinkronisasi.",
            langkah=[
                "Validasi ukuran request: jika ops > 200 atau body > 512 KB, segera tolak dengan status 413 Payload Too Large (§7.2, Lampiran C.2).",
                "Buka transaksi DB: jalankan serialisasi per pengguna persis sesuai Lampiran C.2:",
                "  `INSERT INTO user_sync_state(user_id) VALUES (userId) ON CONFLICT DO NOTHING;`",
                "  `SELECT last_seq FROM user_sync_state WHERE user_id = userId FOR UPDATE;`",
                "Validasi waktu `reviewed_at` pada op `review_log`: harus dalam rentang [now - 400 hari, now + 1 hari]. Jika melanggar, tandai op sebagai rejected dengan code `SYNC_CLOCK_INVALID` (§6.3, §8.4).",
                "Evaluasi keputusan op tanpa langsung menulis: `review_log` (duplicate bila ID sudah ada, applied bila baru); `card_state` (aturan LWW §7.3: menang jika `last_review_at` lebih baru; seri -> `reps` lebih besar; seri -> `updated_at` lebih baru; applied bila menang, duplicate bila kalah/identik); `settings`, `lesson_progress`, `test_attempt` sesuai §7.3.",
                "Hitung n = jumlah op yang applied. Nomor seq = last_seq + 1 .. last_seq + n (berurutan tanpa celah).",
                "Tulis seluruh op applied dengan nomor `user_seq` tersebut ke database dalam transaksi yang sama.",
                "Update `user_sync_state SET last_seq = last_seq + n WHERE user_id = userId;`",
                "Commit transaksi dan kembalikan `{ results: [{op_id, status: accepted|duplicate|rejected, code?}], next_cursor, server_time }`."
            ],
            tes=[
                "Unit test: validasi batas batch (tolak jika > 200 op atau > 512 KB).",
                "Unit test: tolak `reviewed_at` yang berada di luar rentang valid dengan `SYNC_CLOCK_INVALID`.",
                "Integration test: op review_log yang sama dikirim ulang menghasilkan status `duplicate` secara idempoten.",
                "Integration test: evaluasi LWW pada card_state (snapshot lebih baru mengalahkan snapshot lama)."
            ],
            observability=[
                "Span manual OpenTelemetry: `sync.push.validate` dan `sync.push.persist` (§10.4).",
                "Metrik `sync_push_ops_total{type, status}` dan `sync_push_batch_size` (histogram) (§10.3).",
                "Metrik `sync_clock_invalid_total` saat anomali jam terdeteksi (§10.3)."
            ],
            out_of_scope=[
                "Endpoint sync pull (dikerjakan di M1-7b).",
                "Property test dan pengujian konkurensi (dikerjakan di M1-7c)."
            ],
            aturan_ketat=[
                "Serialisasi per pengguna WAJIB menggunakan `FOR UPDATE` pada `user_sync_state` untuk menjamin `user_seq` gapless (§7.1, Lampiran C.2).",
                "Batas request WAJIB maksimal 200 op dan 512 KB (§7.2).",
                "Validasi rentang `reviewed_at` wajib [now - 400 hari, now + 1 hari] (§6.3).",
                "DILARANG mencatat payload data sync atau jawaban pengguna ke log (§10.2, §16.3)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M1-7 sesuai arahan §15.",
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-7b",
            title="Sync Pull (GET /v1/sync/pull) & Cursor Pagination",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint pull sinkronisasi dengan kueri UNION ALL terurut user_seq, filter origin device, dan paginasi cursor gapless.",
            acuan="§6.3 (user_cards, review_logs, user_settings, lesson_progress, test_attempts), §7.2 (GET /v1/sync/pull), Lampiran C.3 (Handler pull server)",
            input_data="Query parameters `cursor`, `limit` (max 500), `entities`, header `X-Device-Id`, Kysely pool.",
            output_data="Endpoint `GET /v1/sync/pull` di `apps/api/src/modules/sync/`.",
            langkah=[
                "Ambil parameter request: `cursor` (integer), `limit` (default/max 500), dan `entities` (filter daftar entitas).",
                "Bentuk kueri database UNION ALL dari tabel: `user_cards`, `review_logs`, `user_settings`, `lesson_progress`, `test_attempts` dengan kondisi:",
                "  `WHERE user_id = $1 AND user_seq > cursor AND (origin_device_id/device_id != $deviceId) AND entitas_dipilih`",
                "  `ORDER BY user_seq ASC LIMIT limit + 1` (§7.2, Lampiran C.3).",
                "Evaluasi: `has_more = rows.length > limit`; potong baris ke batas `limit`.",
                "Hitung `next_cursor`: jika `has_more == true`, next_cursor = seq baris terakhir yang dikembalikan; jika tidak, next_cursor = max(cursor, last_seq milik pengguna) (§7.2, Lampiran C.3).",
                "Penting (§7.2, Lampiran C.3): jika baris terfilter milik perangkat peminta memenuhi seluruh halaman, query harus terus berlanjut hingga terkumpul `limit` baris atau data habis, sehingga cursor tetap maju dan klien tidak menerima halaman kosong berulang.",
                "Kembalikan response: `{ changes: [{seq, entity, data}], next_cursor, has_more, server_time }`."
            ],
            tes=[
                "Integration test: pull mengembalikan perubahan dengan `user_seq > cursor` secara terurut menaik.",
                "Integration test: perubahan yang berasal dari `device_id` yang sama difilter keluar (tidak dikirim balik ke pembuatnya).",
                "Integration test: verifikasi cursor tetap maju meskipun seluruh baris pada rentang tersebut berasal dari device peminta.",
                "Integration test: verifikasi flag `has_more` dan paginasi cursor bertahap."
            ],
            observability=[
                "Span manual OpenTelemetry: `sync.pull.query` (§10.4).",
                "Metrik `sync_pull_changes_returned` (histogram) (§10.3).",
                "Latency SLO: p95 < 400 ms (§10.7)."
            ],
            out_of_scope=[
                "Sinkronisasi klien di Flutter (dikerjakan di M4-2).",
                "Ekstraksi log review historis jangka panjang (ditunda ke fase 2)."
            ],
            aturan_ketat=[
                "Paginasi WAJIB berbasis `user_seq` gapless, bukan timestamp (§7.1, §7.2).",
                "Cursor WAJIB tetap maju meskipun seluruh baris terfilter (§7.2, Lampiran C.3).",
                "Query pull WAJIB aman terhadap replica lag jika diarahkan ke read replica (§11.2)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M1-7 sesuai arahan §15.",
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-7c",
            title="Testing Modul Sync: Property Tests, Paralelisme & Keamanan IDOR",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Menyusun rangkaian pengujian komprehensif untuk modul sync: property-based tests aturan merge, pengujian beban push paralel bebas deadlock, dan verifikasi IDOR.",
            acuan="§7.3 (Aturan merge), §11.5 (Chaos & concurrency test), §12.1 (Pencegahan IDOR), §14.4 (Strategi pengujian backend)",
            input_data="Implementasi endpoint push (M1-7a) dan pull (M1-7b).",
            output_data="Test suite di `apps/api/test/sync/` (property tests, concurrency tests, security IDOR tests).",
            langkah=[
                "Tulis property-based tests (menggunakan `fast-check` atau setara) untuk memverifikasi kebenaran dan determinisme aturan merge (§7.3) dalam ribuan kombinasi variasi urutan kedatangan op.",
                "Tulis tes konkurensi push paralel: jalankan minimal 10 request push simultan untuk `user_id` yang sama, verifikasi bahwa transaksi diserialisasi dengan aman tanpa deadlock dan urutan `user_seq` yang dihasilkan strictly monotonic dan gapless (§11.5, §14.4).",
                "Tulis tes keamanan otomatis IDOR: verifikasi bahwa pengguna A tidak dapat mem-push data untuk pengguna B, dan pengguna A tidak dapat mem-pull data milik pengguna B (semua kueri sync terbukti mengunci `user_id` dari token JWT, §12.1).",
                "Target cakupan baris kode (line coverage) modul `sync` di atas 90% (§14.4)."
            ],
            tes=[
                "Property test: aturan merge memenuhi sifat idempoten dan deterministik.",
                "Concurrency test: 10 worker paralel menghasilkan seq gapless tanpa error deadlock.",
                "Security IDOR test: manipulasi user_id pada payload atau header selalu ditolak / diabaikan dan mengembalikan data pengguna token saja."
            ],
            observability=[
                "Laporan coverage test menunjukkan cakupan modul sync > 90%."
            ],
            out_of_scope=[
                "Load test staging skala besar 500 req/s (dikerjakan di M5-3 menggunakan k6)."
            ],
            aturan_ketat=[
                "`user_id` SELALU diambil dari JWT; tes IDOR wajib membuktikan tidak ada celah (§12.1).",
                "Target coverage modul sync WAJIB > 90% (§14.4)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M1-7 sesuai arahan §15.",
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-8",
            title="Rate limiting Redis + metrik §10.3 + dashboard awal",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="M",
            area="backend",
            tujuan="Mengintegrasikan rate limiter sliding-window berbasis Redis, mengekspos metrik Prometheus sesuai spesifikasi §10.3, dan menyiapkan dashboard Grafana awal.",
            acuan="§8.1 (Rate limit), §10.3 (Metrik penamaan Prometheus), §10.7 (Dashboard awal), §11.3 (Degradasi fail-open Redis)",
            input_data="Redis client ioredis, Prometheus client prom-client, NestJS interceptors.",
            output_data="Rate limiter guard di `apps/api/src/common/guards/rate-limit.guard.ts`, metrics service di `apps/api/src/common/telemetry/`, endpoint `/metrics`, dan file dashboard Grafana `infra/grafana/dashboards/`.",
            langkah=[
                "Implementasikan Redis sliding-window rate limiter guard dengan ambang batas sesuai §8.1:",
                "  - Endpoint auth: 30 request/menit per IP.",
                "  - Sync push: 30 request/menit per user.",
                "  - Endpoint lainnya: 120 request/menit per user.",
                "  - Respons pelanggaran: status 429 Too Many Requests dengan header `Retry-After` (§8.1).",
                "  - Matriks degradasi (§11.3): jika Redis mengalami gangguan, rate limit fail-open dengan batas lokal memori per pod agar layanan tidak lumpuh.",
                "Ekspos metrik Prometheus lengkap pada endpoint internal `/metrics` sesuai tabel §10.3:",
                "  `http_server_request_duration_seconds`, `sync_push_ops_total`, `sync_push_batch_size`, `sync_pull_changes_returned`, `sync_clock_invalid_total`, `review_logs_ingested_total`, `db_query_duration_seconds`, `db_pool_in_use`, `db_pool_waiting`, `bullmq_queue_depth`, `bullmq_job_duration_seconds`, `bullmq_job_failed_total`, `auth_login_total`, `auth_refresh_reuse_detected_total`, `partition_default_rows`.",
                "Terapkan aturan kardinalitas ketat (§10.3): label TIDAK BOLEH berisi `user_id`, `device_id`, atau URL penuh.",
                "Buat dashboard Grafana JSON awal untuk Service Overview (RED metrics) dan Sync Health."
            ],
            tes=[
                "Unit test: request melebihi ambang batas menerima HTTP 429 beserta header `Retry-After`.",
                "Unit test: verifikasi kardinalitas label pada prom-client (tidak memuat user_id).",
                "Integration test: endpoint `/metrics` menghasilkan format eksposisi Prometheus yang valid."
            ],
            observability=[
                "Seluruh metrik §10.3 terbit dan dapat ditarik oleh Prometheus scraper.",
                "Visualisasi metrik tampil pada dashboard Grafana."
            ],
            out_of_scope=[
                "Alerting multi-window burn rate (dikerjakan di M5-2).",
                "Metrik sisi klien Flutter (dikerjakan di M5-1)."
            ],
            aturan_ketat=[
                "Ambang rate limit wajib persis sesuai §8.1.",
                "Kardinalitas label: DILARANG menyertakan `user_id`, `device_id`, atau URL penuh (§10.3).",
                "Jika Redis down, wajib fail-open degradasi anggun (§11.3)."
            ],
            labels=["M1: Backend Inti", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M1-9",
            title="Job pembuat partisi + alert partisi DEFAULT",
            milestone="M1 — Backend Inti",
            milestone_num=2,
            size="S",
            area="backend",
            tujuan="Mengimplementasikan job terjadwal otomatisasi pembuatan partisi bulanan review_logs dan sistem alert jika partisi default terisi.",
            acuan="§6.3 (Manajemen partisi), §10.3 (partition_default_rows), §10.7 (Alerting)",
            input_data="Tabel terpartisi `review_logs`, worker BullMQ / scheduler.",
            output_data="Job BullMQ di `apps/api/src/jobs/partition.job.ts` dan aturan alert Prometheus.",
            langkah=[
                "Implementasikan job terjadwal bulanan menggunakan BullMQ / cron internal:",
                "  - Query memeriksa partisi tabel `review_logs` yang ada.",
                "  - Otomatis buat tabel partisi bulanan `review_logs_YYYY_MM` untuk rentang 3 bulan ke depan (§6.3) menggunakan DDL SQL `CREATE TABLE IF NOT EXISTS review_logs_YYYY_MM PARTITION OF review_logs FOR VALUES FROM (...) TO (...)`.",
                "Buat mekanisme query berkala yang menghitung jumlah baris di partisi pengaman `review_logs_default`.",
                "Perbarui gauge Prometheus `partition_default_rows` dengan jumlah baris tersebut (§10.3).",
                "Buat alert Prometheus rule: picu alert dengan tingkat keparahan tinggi jika `partition_default_rows > 0` (§10.7)."
            ],
            tes=[
                "Integration test di Testcontainers: job dieksekusi dan berhasil membuat partisi untuk 3 bulan ke depan.",
                "Integration test: baris yang masuk di luar partisi terbuat dialihkan ke partisi default dan nilai `partition_default_rows` bertambah."
            ],
            observability=[
                "Gauge `partition_default_rows` terpantau di Prometheus.",
                "Alert terpicu jika baris masuk ke partisi default."
            ],
            out_of_scope=[
                "Pengarsipan partisi lama (> 18 bulan) ke Parquet (fase lanjutan sesuai §6.3)."
            ],
            aturan_ketat=[
                "Partisi bulanan wajib selalu tersedia minimal 3 bulan ke depan (§6.3).",
                "Alert WAJIB menyala jika ada baris yang masuk ke partisi DEFAULT (§6.3, §10.7)."
            ],
            labels=["M1: Backend Inti", "size:S", "area:backend"]
        )
    ]
