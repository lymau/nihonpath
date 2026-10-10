"""Milestone M3: Flutter Inti (Offline) issues."""

from typing import List
from .common import IssueSpec

def get_m3_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M3-1",
            title="Kerangka app: flavor, Forui preset ajeneb, AppColors, l10n id/en, Clock, IdGenerator, router",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Membangun kerangka dasar aplikasi Flutter feature-first dengan Forui UI (preset ajeneb), go_router, Riverpod, token AppColors, Noto Sans JP, l10n id/en, Clock, IdGenerator, dan 3 flavors.",
            acuan="§4.2 (Pilihan mobile), §5.1 (Struktur feature-first), §5.2 (Paket diizinkan), §5.2.1 (Forui preset ajeneb), §5.5 (Font Noto Sans JP), §5.6 (Aksesibilitas & l10n)",
            input_data="Spesifikasi UI dan arsitektur client di `apps/mobile/`.",
            output_data="Struktur direktori `apps/mobile/lib/`, file `app.dart`, `main.dart`, `lib/theme/`, `lib/core/` (Clock, IdGenerator), dan konfigurasi router.",
            langkah=[
                "Inisialisasi aplikasi Flutter di `apps/mobile/` dengan struktur feature-first persis sesuai §5.1 (`core/`, `data/`, `domain/`, `features/`, `l10n/`, `ui/`, `lib/theme/`).",
                "Jalankan setup UI library Forui (§5.2.1):",
                "  `flutter pub add forui`",
                "  `dart run forui init --preset ajeneb --template=router`",
                "Catat hasil kode warna inti, radius, dan font bawaan preset `ajeneb` di `docs/decision-log.md` beserta tangkapan layar tema terang dan gelap (§5.2.1). (Jika kode ditolak CLI, catat blocker dan fallback ke `FTheme.neutral`).",
                "Konfigurasi `app.dart` menyatukan Forui + `go_router` (`routerProvider`) + Riverpod (`MaterialApp.router` dengan `FTheme`, `FToaster`, `FTooltipGroup`, §5.2.1).",
                "Definisikan `ThemeExtension` `AppColors` di `lib/theme/` untuk token khusus aplikasi: warna rating SRS (`Again`, `Hard`, `Good`, `Easy`), warna furigana, dan status benar/salah, diakses lewat `context.theme.colors.app` (§5.2.1).",
                "Ubah `_display` dan `_body` di `typography.dart` untuk menggunakan font Noto Sans JP hasil subset pyftsubset (§5.5) dengan fallback ke font sistem.",
                "Buat abstraksi `Clock` (interface `Clock { DateTime now(); }`) dan `IdGenerator` (UUIDv7 untuk data pengguna dan UUIDv5 deterministik untuk card_id, §3.4, §5.1, §6.1). Dilarang memakai `DateTime.now()` mentah di logika bisnis!",
                "Setup 3 Flutter flavors (`dev`, `staging`, `prod`) menggunakan `--dart-define` dan lokalisasi ARB untuk bahasa Indonesia (`id`) dan Inggris (`en`) (§5.6)."
            ],
            tes=[
                "Aplikasi Flutter dapat di-build dan berjalan lancar di 3 flavor (dev, staging, prod).",
                "Widget test: tema Forui terang dan gelap ter-render dengan benar beserta token AppColors.",
                "Unit test: verifikasi IdGenerator menghasilkan UUIDv7 valid dan UUIDv5 deterministik untuk card_id.",
                "Unit test: Clock abstraction dapat di-mock untuk simulasi waktu."
            ],
            observability=[
                "Log inisialisasi aplikasi saat startup menampilkan flavor aktif dan status tema."
            ],
            out_of_scope=[
                "Implementasi database Drift (dikerjakan di M3-2).",
                "Implementasi layar fitur spesifik (dikerjakan di M3-6 s/d M3-10)."
            ],
            aturan_ketat=[
                "UI WAJIB menggunakan Forui preset `ajeneb` (§5.2.1).",
                "DILARANG menulis `Color(0x...)`, `fontSize`, atau `BorderRadius` angka mentah di kode fitur; gunakan token tema (§5.2.1).",
                "DILARANG memakai `DateTime.now()` langsung di domain/logika bisnis; gunakan interface `Clock` (§0 Aturan 5, §5.1).",
                "Hanya paket dalam daftar §5.2 yang diizinkan; pin versi di `pubspec.lock`."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-2",
            title="Skema SQLite klien (Drift) + DAO + tes migrasi",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan skema database SQLite klien menggunakan Drift, Data Access Objects (DAO), indeks query performa, dan pengujian migrasi bertingkat.",
            acuan="§4.2 (Drift di atas SQLite), §5.1 (data/), §6.1 (Konvensi ID & status), §6.2 (Skema SQLite klien lengkap)",
            input_data="Tabel skema SQLite klien di §6.2 dokumen teknis.",
            output_data="File database Drift di `apps/mobile/lib/data/db/` (`app_database.dart`, tabel, DAOs, skema migrasi).",
            langkah=[
                "Definisikan tabel Drift lengkap sesuai §6.2:",
                "  - `content_items` (id, external_key UNIQUE, type, jlpt_level, payload_json, content_version)",
                "  - `lessons`, `lesson_items`",
                "  - `user_cards` (card_id PK, item_external_key, facet, state, due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, step, last_review_at, suspended, buried_until, updated_at) dengan INDEKS WAJIB `(state, due)` dan `(item_external_key)` (§5.6, §6.2).",
                "  - `review_logs` (id PK, card_id, rating, state_before, reviewed_at, duration_ms, scheduled_days, elapsed_days, stability_before, difficulty_before, exercise_type) bersifat append-only.",
                "  - `user_settings`, `lesson_progress`, `test_attempts`, `outbox`, `sync_state`, `pack_state`.",
                "Implementasikan virtual table FTS5 `fts_items` pada kolom kana, kanji, romaji, dan arti (§5.5, §6.2).",
                "Implementasikan DAOs terpisah untuk setiap area data dengan query typed dan stream reaktif.",
                "Konfigurasi strategi migrasi Drift (`MigrationStrategy`) dan pastikan PRAGMA foreign_keys aktif."
            ],
            tes=[
                "Unit test: pembuatan skema database baru berhasil tanpa error sintaks SQLite.",
                "Drift migration test: tes migrasi naik secara berantai dari skema v1 ke versi berikutnya menggunakan drift_dev migration verifier.",
                "Unit test: kueri indeks `(state, due)` pada `user_cards` terbukti menggunakan indeks SQLite (EXPLAIN QUERY PLAN)."
            ],
            observability=[
                "Log eksekusi migrasi DB lokal tercatat saat aplikasi dibuka."
            ],
            out_of_scope=[
                "Sinkronisasi outbox ke server (dikerjakan di M4-2).",
                "Ekstraksi zip paket konten (dikerjakan di M3-3)."
            ],
            aturan_ketat=[
                "Skema SQLite WAJIB persis sesuai tabel §6.2.",
                "Indeks `(state, due)` dan `(item_external_key)` pada `user_cards` WAJIB ada (§6.2).",
                "Tabel `review_logs` bersifat append-only; tidak pernah di-update atau di-delete (§6.2).",
                "Semua waktu epoch milidetik UTC (§6.1)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-3a",
            title="Content Pack Downloader (Range Resume & Verifikasi SHA-256)",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan download manager paket konten di Flutter dengan kemampuan resume (HTTP Range), pelacakan progres, dan verifikasi checksum SHA-256.",
            acuan="§5.2 (dio, crypto), §9.3 (Anggaran ukuran dan distribusi), §11.3 (Degradasi CDN)",
            input_data="Endpoint manifest dan download-url dari backend NestJS.",
            output_data="Class `ContentPackDownloader` di `apps/mobile/lib/data/content_pack/`.",
            langkah=[
                "Implementasikan pengunduh file paket zip menggunakan `Dio` dengan dukungan header HTTP Range untuk melanjutkan (resume) unduhan yang terputus (§9.3).",
                "Sediakan stream progres unduhan (persentase, kecepatan, bytes transferred) untuk dihubungkan ke UI.",
                "Sediakan opsi pengaturan pengguna: opsi mengunduh paket audio hanya saat terhubung jaringan Wi-Fi (§9.3).",
                "Implementasikan verifikasi integritas file: hitung hash SHA-256 file zip yang diunduh menggunakan paket `crypto` dan cocokkan dengan hash dari manifest sebelum proses instalasi dimulai (§5.2, §9.3).",
                "Jika checksum tidak cocok, hapus file korup dan kembalikan error verifikasi yang dapat di-retry."
            ],
            tes=[
                "Unit test: verifikasi checksum SHA-256 berhasil mencocokkan hash yang valid dan menolak file korup.",
                "Integration test (mock HTTP): simulasi unduhan terputus di 50% dan berhasil di-resume dengan header Range.",
                "Unit test: flag 'hanya Wi-Fi' mencegah pengunduhan audio pada koneksi seluler."
            ],
            observability=[
                "Metrik event analitik: `pack_download{result, size, duration_ms}` (§10.5).",
                "Logging INFO saat unduhan dimulai, berhasil diverifikasi, atau gagal."
            ],
            out_of_scope=[
                "Ekstraksi zip dan seeding database SQLite (dikerjakan di M3-3b).",
                "UI download tile (dikerjakan di M3-8/M3-10)."
            ],
            aturan_ketat=[
                "Verifikasi SHA-256 WAJIB dilakukan sebelum paket dipasang (§9.3).",
                "Mendukung HTTP Range resume unduhan (§9.3).",
                "Tangani kegagalan unduhan dengan pesan jelas dan tombol coba lagi (§11.3)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M3-3 sesuai arahan §15.",
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-3b",
            title="Content Pack Installer & FTS Seeder",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan ekstraksi zip atomik, impor data paket ke SQLite Drift, populasi indeks pencarian FTS5, dan mekanisme rollback otomatis jika gagal.",
            acuan="§5.2 (archive), §5.5 (Pencarian FTS5), §6.2 (pack_state, fts_items), §9.3 (Distribusi paket)",
            input_data="File zip paket konten yang terverifikasi SHA-256 dari M3-3a.",
            output_data="Class `ContentPackInstaller` di `apps/mobile/lib/data/content_pack/`.",
            langkah=[
                "Implementasikan fungsi ekstraksi file zip menggunakan paket `archive` ke direktori lokal terisolasi.",
                "Buka transaksi database Drift SQLite atomik (§9.3):",
                "  - Baca `items.jsonl` dan `lessons.json` secara streaming/batch.",
                "  - Upsert ke tabel `content_items`, `lessons`, dan `lesson_items`.",
                "  - Ekstrak aset audio (`.opus`) dan SVG goresan (`.svg`) ke storage aplikasi lokal.",
                "  - Populasi virtual table `fts_items` (FTS5) atas kana, kanji, romaji, dan arti untuk pencarian offline (§5.5, §6.2).",
                "  - Catat riwayat instalasi ke tabel `pack_state` (pack_id, kind, level, version, sha256, installed_at).",
                "Implementasikan rollback atomik (§9.3): jika terjadi exception/kegagalan di tengah proses pemasangan, batalkan transaksi database, hapus file parsial, dan kembalikan versi paket aktif ke versi lama.",
                "Pastikan proses ekstraksi dan instalasi berjalan di background isolate agar UI tidak membeku (unresponsive)."
            ],
            tes=[
                "Unit test: ekstraksi dan impor paket uji berhasil mengisi tabel `content_items` dan indeks `fts_items`.",
                "Integration test (fault injection): simulasi file corrupt di tengah instalasi memicu rollback atomik tanpa merusak database lama.",
                "Unit test: pencarian kata pada `fts_items` mengembalikan hasil yang relevan."
            ],
            observability=[
                "Log INFO mencatat durasi instalasi paket, jumlah item diimpor, dan versi paket.",
                "Metrik error jika instalasi mengalami rollback."
            ],
            out_of_scope=[
                "Pembaruan paket delta (ditunda ke fase 3 / M8-4)."
            ],
            aturan_ketat=[
                "Instalasi paket konten WAJIB atomik dalam satu transaksi database; gagal = rollback ke versi lama (§9.3).",
                "Ekstraksi dan parsing data dilarang memblokir UI thread (jalankan di isolate) (§1 NFR)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M3-3 sesuai arahan §15.",
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-4",
            title="Pembungkus Scheduler + FSRS + golden test ≥50 skenario",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan interface domain Scheduler dengan engine FSRS-6 (21 parameter), fuzzing deterministik, dan golden test minimal 50 skenario terhadap referensi ts-fsrs.",
            acuan="§2 (Penjadwalan FSRS-6 & konfigurasi), §5.4 (SRS engine di klien), §16.3 (Determinisme FSRS), §16.4",
            input_data="Vektor uji golden dari implementasi referensi `ts-fsrs`.",
            output_data="Interface `Scheduler` dan implementasi `FsrsScheduler` di `apps/mobile/lib/domain/srs/` beserta test suite.",
            langkah=[
                "Definisikan interface: `abstract class Scheduler { ReviewResult review(CardState card, Rating rating, DateTime now); }` (§5.4).",
                "Implementasikan scheduler menggunakan package Dart `fsrs` resmi dari open-spaced-repetition (WAJIB FSRS-6 dengan 21 parameter) (§2, §5.4). (Catatan: jika paket tidak kompatibel, gunakan Opsi B membungkus `fsrs-rs` Rust via flutter_rust_bridge dan catat di decision log, §5.4).",
                "Terapkan konfigurasi wajib §2:",
                "  - `desired_retention` default 0.90 (pilihan: 0.85 Santai, 0.90 Standar, 0.95 Ketat).",
                "  - `maximum_interval` = 365 hari.",
                "  - `learning_steps` = [1m, 10m], `relearning_steps` = [10m].",
                "  - Fuzzing aktif dengan SEED DETERMINISTIK dari hash(`card_id`, `reps`) agar hasil replay selalu deterministik (§2, §16.3). DILARANG menggunakan random global!",
                "Susun golden test suite komprehensif: import minimal 50 skenario rangkaian rating dari `ts-fsrs` (mencakup kartu baru, learning, review, lapse, easy, hard); bandingkan keluaran state, stability, difficulty, dan due.",
                "Toleransi perbandingan: selisih stability/difficulty maksimal 1e-6, dan interval hari (scheduled_days) HARUS IDENTIK 100% (§5.4)."
            ],
            tes=[
                "Golden test: minimal 50 skenario pengujian FSRS lulus 100% dengan toleransi 1e-6 dan interval hari identik terhadap ts-fsrs.",
                "Unit test: fuzzing deterministik menghasilkan interval yang persis sama pada review berulang dengan input yang identik.",
                "Unit test: penanganan transisi rating (Again=1, Hard=2, Good=3, Easy=4)."
            ],
            observability=[
                "Logging DEBUG terstruktur saat kalkulasi FSRS (hanya saat unit test, bukan produksi)."
            ],
            out_of_scope=[
                "Optimizer personalisasi parameter FSRS di server (ditunda ke fase 3 / M8-1).",
                "Penyimpanan database (dikerjakan di M3-6c)."
            ],
            aturan_ketat=[
                "Wajib implementasi FSRS-6 dengan 21 parameter (§2, §5.4).",
                "Golden test ≥50 skenario WAJIB lulus sebagai gerbang rilis (§5.4).",
                "Fuzz seed WAJIB deterministik dari hash(card_id, reps); DILARANG random global (§2, §16.3).",
                "Dilarang DateTime.now() langsung; gunakan parameter `now` (§0 Aturan 5, §5.4)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-5",
            title="queue_builder (§3.6) + tes",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan algoritma domain queue_builder untuk menyusun antrean harian review, gate kartu baru, interleaving, dan sibling burying.",
            acuan="§3.6 (Rencana harian dan pembentukan antrean), §16.3 (Jebakan pergantian hari jam 04:00)",
            input_data="Data `user_cards` dari Drift DAO, `user_settings`, dan waktu `Clock.now()`.",
            output_data="Class `QueueBuilder` di `apps/mobile/lib/domain/srs/queue_builder.dart` dan test suite.",
            langkah=[
                "Implementasikan fungsi `buildQueue(DateTime now, UserSettings settings)` persis sesuai algoritma §3.6:",
                "  1. Tentukan `dayEnd`: batas akhir hari lokal pengguna dengan pergantian hari pukul 04:00 dini hari (§3.6, §16.3).",
                "  2. Ambil kartu Learning/Relearning dengan `due <= now + 20 menit` (selalu diposisikan pertama di antrean).",
                "  3. Ambil kartu Review dengan `due <= dayEnd`, diurutkan berdasarkan `retrievability` ASC, dibatasi `settings.max_reviews_per_day` (default 200).",
                "  4. Evaluasi `newGate`: kartu baru hanya diperbolehkan jika (jumlah reviews terjatuh tempo) < `settings.new_gate` (default 100).",
                "  5. Hitung kuota kartu baru: `newCards = newGate ? min(settings.new_per_day - introducedToday, sisaKuota) : 0` (default 10, rentang 0..30) diambil dari urutan kurikulum lesson berikutnya.",
                "  6. Interleaving (§3.6): susun dengan rasio 1 kartu baru per 4 review; kartu dari item yang sama berjarak minimal 3 kartu.",
                "  7. Sibling burying (§3.6): jika satu facet dari sebuah item dijawab, facet lain (sibling) dari item yang sama di-bury (ditangguhkan) sampai hari berikutnya.",
                "  8. Leech handler (§3.6): jika lapses kartu mencapai 8 atau lebih, tandai kartu `suspended = true` dan keluarkan dari antrean reguler."
            ],
            tes=[
                "Unit test: batas hari 04:00 diuji pada berbagai zona waktu (UTC+7, UTC-8, dan saat pergantian daylight saving time / DST).",
                "Unit test: newGate memblokir kartu baru jika tumpukan review mencapai ambang batas (>= 100).",
                "Unit test: pola interleave 1 baru per 4 review dan jarak minimal 3 kartu untuk item sama.",
                "Unit test: sibling kartu otomatis di-bury hingga hari berikutnya.",
                "Unit test: kartu dengan lapses >= 8 otomatis ditangguhkan (leech)."
            ],
            observability=[
                "Log INFO ringkasan pembentukan antrean: jumlah learning, review, dan kartu baru yang dijadwalkan."
            ],
            out_of_scope=[
                "Komponen antarmuka visual UI kartu (dikerjakan di M3-6a).",
                "Pengambilan data jaringan sync (dikerjakan di M4-2)."
            ],
            aturan_ketat=[
                "Pergantian hari WAJIB pukul 04:00 zona waktu lokal pengguna (§3.6, §16.3).",
                "Query review WAJIB memakai indeks `(state, due)`, dilarang memuat seluruh tabel ke memori (§5.6, §16.3).",
                "Waktu pengujian wajib menggunakan injeksi `Clock` (§0 Aturan 5)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-6a",
            title="UI ReviewCard, Pilihan Ganda & Flashcard Rating",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Membangun komponen antarmuka ReviewCard di atas Forui widget, komponen pilihan ganda, tombol 4 rating FSRS dengan AppColors, komponen JpText (furigana), dan audio preloading.",
            acuan="§3.4 (Facet MVP), §3.6 (Mapping rating), §5.2.1 (Pemetaan widget Forui), §5.5 (Audio & Furigana JpText)",
            input_data="Token tema Forui preset `ajeneb` dan `AppColors`.",
            output_data="Widget di `apps/mobile/lib/ui/widgets/` (`review_card.dart`, `jp_text.dart`, `audio_button.dart`) dan golden tests.",
            langkah=[
                "Buat komponen kustom `JpText` di `apps/mobile/lib/ui/widgets/jp_text.dart`: menerima segmen `[{t: 漢字, r: かんじ}]` dan me-render furigana di atas kanji secara proporsional (§5.5). Mendukung pengaturan preferensi furigana (selalu / kanji di atas level / tidak).",
                "Buat widget kustom `ReviewCard` membungkus widget Forui `FCard`: menampilkan prompt pertanyaan, audio trigger, contoh kalimat, dan badge tipe soal (`FBadge`) (§5.2.1).",
                "Buat tombol rating review 4 pilihan menggunakan `FButton` (Again, Hard, Good, Easy) dengan pewarnaan dari token `AppColors` (`context.theme.colors.app.ratingAgain`, dsb.) (§5.2.1).",
                "Buat tampilan tipe soal pilihan ganda (MCQ) dengan tombol opsi sentuh Forui yang responsif (target sentuh minimal 48 dp, §5.6).",
                "Integrasikan pemutaran audio (`just_audio` dan `audio_session`): tombol `AudioButton` dan otomatis melakukan preloading audio untuk kartu berikutnya di antrean guna transisi instan (§5.5).",
                "Buat Golden Test terang dan gelap untuk `JpText` dan `ReviewCard` menggunakan `alchemist` (§5.2.1)."
            ],
            tes=[
                "Golden test: `JpText` dan `ReviewCard` lolos uji tampilan mode terang dan gelap.",
                "Widget test: tombol 4 rating memicu callback rating dengan nilai 1, 2, 3, 4 yang benar.",
                "Unit test: audio preloader berhasil memuat asset kartu berikutnya di antrean."
            ],
            observability=[
                "Metrik render transisi kartu review dicatat di Sentry / analitik (§10.5)."
            ],
            out_of_scope=[
                "Penanganan input teks ketik (dikerjakan di M3-6b).",
                "Transaksi penulisan database (dikerjakan di M3-6c)."
            ],
            aturan_ketat=[
                "UI WAJIB dibangun dari widget Forui dan token tema, DILARANG nilai hardcoded (§5.2.1).",
                "`JpText` menerima segmen pra-komputasi; DILARANG menghitung furigana saat runtime (§5.5, §16.3).",
                "Target sentuh tombol minimal 48 dp untuk aksesibilitas (§5.6)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M3-6 sesuai arahan §15.",
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-6b",
            title="Input Jawaban Ketik & Normalisasi Teks Jepang",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan input jawaban ketik dengan FTextField, proteksi komposisi IME, normalisasi Unicode NFKC, konversi katakana/hiragana, dan pencocokan accepted_answers.",
            acuan="§3.4 (Facet recall), §5.2.1 (FTextField), §16.3 (Normalisasi teks Jepang & komposisi IME)",
            input_data="Input keyboard pengguna, field `accepted_answers` pada data item konten.",
            output_data="Widget `JpTextInput` di `apps/mobile/lib/ui/widgets/jp_text_input.dart` dan utilitas normalisasi `text_normalizer.dart`.",
            langkah=[
                "Buat input field jawaban berbasis Forui `FTextField` (§5.2.1).",
                "Penanganan Kritis Komposisi IME (§16.3): deteksi event IME keyboard; DILARANG mengevaluasi jawaban saat status keyboard pengguna masih aktif melakukan composing teks kana/kanji!",
                "Implementasikan normalisasi teks Jepang (§16.3):",
                "  - Normalisasi Unicode NFKC.",
                "  - Hapus seluruh spasi (whitespace / full-width space).",
                "  - Untuk facet pembacaan (reading), konversi katakana ke hiragana sebelum dibandingkan.",
                "  - Tangani karakter vokal panjang (ー) dan kana kecil (っ, ゃ, ゅ, ょ).",
                "Cocokkan hasil normalisasi terhadap daftar `accepted_answers` yang disediakan oleh data item konten (§16.3).",
                "Sediakan visual feedback instan (benar/salah) menggunakan token warna `AppColors` tanpa delay."
            ],
            tes=[
                "Unit test normalisasi: variasi input (full-width vs half-width, katakana vs hiragana, spasi) terverifikasi cocok dengan accepted_answers.",
                "Widget test: penekanan tombol Enter saat IME masih composing TIDAK memicu evaluasi jawaban salah prematur.",
                "Unit test: penanganan vokal panjang dan huruf kecil kana dievaluasi tepat."
            ],
            observability=[
                "Metrik waktu durasi mengetik jawaban per kartu tercatat di log review."
            ],
            out_of_scope=[
                "Pengenalan tulisan tangan kanji (dikerjakan di M3-9 via ML Kit).",
                "Kueri database (dikerjakan di M3-6c)."
            ],
            aturan_ketat=[
                "DILARANG mengevaluasi jawaban saat IME keyboard masih composing (§16.3).",
                "Normalisasi teks WAJIB Unicode NFKC dan pembersihan spasi (§16.3).",
                "Pencocokan jawaban WAJIB menggunakan field `accepted_answers` dari data; dilarang menebak aturan sendiri di UI (§16.3)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M3-6 sesuai arahan §15.",
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-6c",
            title="Controller Sesi Review & Transaksi DB Tunggal",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan ReviewSessionController yang mengorkestrasi antrean review, menjalankan 1 transaksi SQLite atomik per review (log + user_cards + outbox), re-queue kartu learning, dan transisi <100ms.",
            acuan="§1 NFR (Transisi <100ms, data loss 0), §3.6 (Mapping rating), §5.4 (Alur review), §16.3 (Satu review = satu transaksi), Lampiran C.1 (onAnswer pseudocode)",
            input_data="QueueBuilder M3-5, Scheduler FSRS M3-4, Drift DB M3-2.",
            output_data="StateNotifier / Riverpod provider `reviewSessionControllerProvider` di `apps/mobile/lib/features/review/` dan layar `/review`.",
            langkah=[
                "Integrasikan layar rute `/review` menggunakan Forui `FScaffold` (§5.2.1, §5.3).",
                "Ambil antrean kartu aktif dari `queue_builder`.",
                "Implementasikan handler `onAnswer(card, rating, durationMs)` persis sesuai Lampiran C.1:",
                "  `now = clock.now()`",
                "  `result = scheduler.review(card.state, rating, now)`",
                "  `db.transaction: insert review_logs(...) + update user_cards(...) + insert outbox(...)` (SATU TRANSAKSI ATOMIK SQLite!).",
                "Mapping rating (§3.6): salah = Again(1); benar tetapi pakai hint / lambat = Hard(2); benar = Good(3); tombol Mudah = Easy(4).",
                "Re-queue in-memory: jika kartu yang dijawab masih berstatus Learning/Relearning dan jatuh tempo kembali dalam sesi berjalan (due <= now + 20 menit), masukkan ulang kartu ke antrean in-memory (§5.4).",
                "Picu sync tertunda dengan mekanisme debounce 5 detik (§5.4, Lampiran C.1).",
                "Optimasi NFR (§1): pastikan transisi antar kartu selesai dalam waktu < 100 ms dengan 60 fps tanpa jank."
            ],
            tes=[
                "Unit test: eksekusi `onAnswer` terbukti menulis ke 3 tabel (`review_logs`, `user_cards`, `outbox`) dalam 1 transaksi atomik (simulasi rollback membatalkan ketiganya).",
                "Unit test: kartu learning yang belum lulus dimasukkan kembali ke antrean sesi berjalan.",
                "Performance test: pengukuran latensi transisi antar kartu < 100 ms."
            ],
            observability=[
                "Metrik Sentry performa `review_card_render_ms` tercatat (§10.5).",
                "Log INFO saat sesi review dimulai dan diselesaikan (jumlah kartu, akurasi, durasi)."
            ],
            out_of_scope=[
                "Pengiriman request HTTP sync ke server (dikerjakan di M4-2 via SyncClient).",
                "Visualisasi forecast beban (dikerjakan di M3-8)."
            ],
            aturan_ketat=[
                "Satu review WAJIB SATU transaksi atomik SQLite (log + kartu + outbox); DILARANG menulis sebagian (§5.4, §16.3, Lampiran C.1).",
                "Transisi kartu WAJIB kurang dari 100 ms tanpa jank (§1 NFR).",
                "Waktu review wajib diambil dari interface `Clock` (§0 Aturan 5, Lampiran C.1)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M3-6 sesuai arahan §15.",
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-7",
            title="Alur pelajaran (perkenalan, kuis, ringkasan)",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan layar alur pelajaran /lesson/:id yang mencakup tahap perkenalan, kuis retrieval interaktif, pencatatan kartu pertama ke SRS, dan ringkasan hasil.",
            acuan="§2 (Retrieval practice), §3.3 (Hierarki lesson), §3.5 (Alur pelajaran 4 langkah), §5.3 (/lesson/:id)",
            input_data="Data pelajaran dari tabel `lessons` dan `lesson_items`.",
            output_data="Layar `/lesson/:id` di `apps/mobile/lib/features/lesson/` dan lesson coordinator provider.",
            langkah=[
                "Buat layar rute `/lesson/:id` menggunakan `FScaffold` Forui (§5.2.1).",
                "Tahap 1 (Perkenalan): tampilkan 3–5 item baru per layar; sertakan teks kata/kanji, audio otomatis, contoh kalimat dengan furigana, dan ilustrasi/mnemonik singkat. Tombol 'Lanjut' mengarah ke item berikutnya (§3.5).",
                "Tahap 2 (Kuis Langsung / Retrieval): setelah perkenalan, setiap item baru ditanyakan dalam kuis aktif hingga dijawab benar minimal satu kali (tidak ada mode hafalan baca-saja, §2, §3.5).",
                "Tahap 3 (Masuk SRS): setiap jawaban kuis otomatis dicatat sebagai `review_log` pertama; kartu dimasukkan ke `user_cards` dengan status `Learning` (state=1) dan jadwal interval dari FSRS (§3.5).",
                "Tahap 4 (Ringkasan): tampilkan kartu `FCard` ringkasan hasil: daftar item yang dipelajari, akurasi, dan estimasi beban review untuk esok hari (§3.5).",
                "Simpan progres kelulusan pelajaran ke tabel `lesson_progress` (status='completed', best_score) dan masukkan entri ke outbox sync."
            ],
            tes=[
                "Integration test: alur lengkap pelajaran (perkenalan -> kuis -> ringkasan) berhasil diselesaikan.",
                "Unit test: kuis retrieval berulang menanyakan item sampai pengguna menjawab benar.",
                "Unit test: penyelesaian kuis otomatis membuat kartu SRS baru di `user_cards` dengan status Learning dan mencatat review_log perdana.",
                "Unit test: record `lesson_progress` diperbarui dengan benar."
            ],
            observability=[
                "Event analitik produk: `lesson_started` dan `lesson_completed` dipancarkan (§10.6).",
                "Log INFO saat pelajaran selesai."
            ],
            out_of_scope=[
                "Latihan membaca bertingkat (dikerjakan di M6-3).",
                "Sinkronisasi outbox progress ke backend (dikerjakan di M4-2)."
            ],
            aturan_ketat=[
                "DILARANG mode baca-saja untuk hafalan; kuis retrieval WAJIB ada langsung setelah materi (§2).",
                "Setiap item yang lulus kuis WAJIB langsung mencatat review log pertama dan kartu SRS berstatus Learning (§3.5).",
                "Komponen visual wajib menggunakan Forui widgets (`FScaffold`, `FCard`, `FButton`) (§5.2.1)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-8",
            title="Home, progres, forecast beban review",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan layar utama /home dengan rencana harian terurut, layar /progress dengan statistik retensi dan diagram batang ForecastBars, serta pencarian /library FTS5.",
            acuan="§3.6 (Urutan Home & Rencana harian), §5.2.1 (Pemetaan Forui & ForecastBars), §5.3 (/home, /progress, /library), §5.5 (Pencarian FTS5), §5.6 (Performa kueri terindeks)",
            input_data="Data `user_cards`, `review_logs`, dan `user_settings` dari Drift DB.",
            output_data="Layar di `apps/mobile/lib/features/` (`home/`, `progress/`, `library/`) dan widget `ForecastBars`.",
            langkah=[
                "Implementasikan layar `/home`: tampilkan urutan rencana harian persis sesuai §3.6: (1) Tombol Review jatuh tempo dengan counter, (2) Pelajaran baru berikutnya, (3) Latihan baca/dengar, (4) Drill khusus.",
                "Tampilkan kalender streak harian menggunakan `FLineCalendar` atau `FCalendar` (mode tampilan saja, §5.2.1).",
                "Optimasi kueri Home: wajib menggunakan indeks `(state, due)`; DILARANG memuat seluruh tabel kartu ke dalam memori (§5.6, §16.3).",
                "Implementasikan layar `/progress`: tampilkan metrik 'True Retention' (% Good/Easy pada kartu Review), total kartu per status, dan leech count (§10.6).",
                "Buat komponen kustom `ForecastBars`: diagram batang proyeksi beban review 7–30 hari ke depan menggunakan `CustomPainter` murni (DILARANG menambah library grafik baru! §5.2.1).",
                "Implementasikan layar `/library`: telusuri item kosakata/kanji/grammar per level menggunakan virtual table FTS5 `fts_items` dengan input search bar Forui `FTextField` (§5.2.1, §5.5)."
            ],
            tes=[
                "Widget test: layar Home me-render rencana harian dengan urutan prioritas yang benar.",
                "Unit test: kueri review Home terbukti menggunakan indeks dan hanya memuat kartu due.",
                "Widget test: `ForecastBars` me-render proyeksi beban review tanpa error painting.",
                "Integration test: pencarian kata di layar library via FTS5 mengembalikan item yang sesuai."
            ],
            observability=[
                "Event analitik produk: `app_open` dan `daily_goal_met` (§10.6).",
                "Trace performa cold start diukur via Sentry (target < 2.0s sampai Home, §1 NFR)."
            ],
            out_of_scope=[
                "Leaderboard / fitur sosial (eksplisit non-goals MVP sesuai §1).",
                "Grafik statistik pihak ketiga."
            ],
            aturan_ketat=[
                "Urutan Home WAJIB: (1) Review due, (2) Pelajaran baru, (3) Baca/dengar (§3.6).",
                "`ForecastBars` WAJIB dibuat dengan `CustomPainter` murni tanpa library grafik baru (§5.2.1).",
                "Kueri database WAJIB terindeks; DILARANG memuat seluruh tabel kartu ke memori (§5.6, §16.3).",
                "Cold start target < 2,0 s di Android kelas menengah (§1 NFR)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-9",
            title="Kana: tabel, latihan, tulis tangan (ML Kit) + animasi goresan",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan layar /kana yang memuat tabel Hiragana/Katakana interaktif, animasi goresan SVG StrokeOrderPlayer, dan kanvas latihan tulis tangan HandwritingCanvas dengan ML Kit Digital Ink Recognition.",
            acuan="§3.1 (Level 0 Kana), §3.4 (Facet kana), §5.2 (google_mlkit_digital_ink_recognition, flutter_svg), §5.2.1, §5.3 (/kana), §5.5 (Tulisan tangan)",
            input_data="Aset konten Level 0 (audio mora, SVG KanjiVG, model ML Kit bahasa Jepang 'ja').",
            output_data="Layar `/kana` di `apps/mobile/lib/features/kana/`, komponen `StrokeOrderPlayer`, dan `HandwritingCanvas`.",
            langkah=[
                "Buat antarmuka tabel kana interaktif (Hiragana & Katakana) dengan tata letak grid sentuh menggunakan Forui (§5.2.1).",
                "Mengetuk karakter kana memutar audio pelafalan mora menggunakan `just_audio`.",
                "Buat komponen kustom `StrokeOrderPlayer`: menganimasikan urutan goresan pena dari file SVG KanjiVG menggunakan `flutter_svg` dan timer goresan (§5.5).",
                "Buat komponen kustom `HandwritingCanvas`: kanvas interaktif berbasis `CustomPainter` untuk menangkap goresan tangan pengguna.",
                "Integrasikan Google ML Kit Digital Ink Recognition (`google_mlkit_digital_ink_recognition`):",
                "  - Unduh model bahasa Jepang (`ja`) sekali saat pertama kali fitur dibuka, lalu simpan di disk lokal.",
                "  - Eksekusi pengenalan goresan tangan 100% on-device (bekerja tanpa internet) (§5.5).",
                "Bandingkan karakter hasil pengenalan goresan tangan dengan karakter target kana; berikan feedback visual instan."
            ],
            tes=[
                "Widget test: tabel kana dapat beralih antara Hiragana dan Katakana dengan audio player terhubung.",
                "Widget test: `StrokeOrderPlayer` me-render path SVG dan menjalankan animasi goresan berurutan.",
                "Integration test (on-device): `HandwritingCanvas` berhasil mengenali karakter kana yang digambar tangan secara offline menggunakan model ML Kit."
            ],
            observability=[
                "Log INFO saat model ML Kit bahasa Jepang berhasil diunduh dan diinisialisasi."
            ],
            out_of_scope=[
                "Latihan tulisan tangan untuk kanji kompleks N5-N1 (ditunda ke fase 2 / M7-3).",
                "Penilaian tulisan tangan berbasis server."
            ],
            aturan_ketat=[
                "Tulisan tangan WAJIB menggunakan ML Kit Digital Ink Recognition on-device (100% offline) (§5.5).",
                "Animasi goresan WAJIB bersumber dari SVG KanjiVG (§5.5).",
                "DILARANG mengirim data gambar/goresan tangan ke server (privasi §12.1)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M3-10",
            title="Onboarding, pengaturan, notifikasi lokal harian",
            milestone="M3 — Flutter Inti (Offline)",
            milestone_num=4,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan alur layar /onboarding (guest mode langsung), layar /settings lengkap dengan dialog privasi/penghapusan akun, serta notifikasi pengingat harian flutter_local_notifications.",
            acuan="§1 (Guest mode), §5.2 (flutter_local_notifications), §5.3 (/onboarding, /settings), §10.6, §12.2 (Persetujuan privasi & tombol hapus akun)",
            input_data="Settings DAO Drift DB, package `flutter_local_notifications`.",
            output_data="Layar `/onboarding` dan `/settings` di `apps/mobile/lib/features/`, dan notification service di `lib/core/`.",
            langkah=[
                "Implementasikan layar `/onboarding`: pilihan target level (N5..N1), target kuota harian kartu baru, dan banner dialog persetujuan analitik privasi (UU PDP & GDPR, §12.2).",
                "Aktifkan Guest Mode langsung tanpa mewajibkan registrasi atau input email (§1, §5.3).",
                "Implementasikan layar `/settings` menggunakan `FItemGroup` dan `FItem` Forui (§5.2.1):",
                "  - Konfigurasi target retensi FSRS (0.85 Santai, 0.90 Standar, 0.95 Ketat) (§2).",
                "  - Konfigurasi kuota kartu baru harian (rentang 0..30) (§3.6).",
                "  - Opsi tampilan furigana (selalu / di atas level / tidak) (§5.5).",
                "  - Pengaturan bahasa UI (Indonesia / English) via locale switcher.",
                "  - Tombol 'Hapus Akun' dengan konfirmasi eksplisit (WAJIB ADA sesuai kebijakan toko Apple & Google, §5.3, §12.2, §16.3).",
                "  - Tautan permintaan 'Ekspor Data' (§12.2).",
                "Konfigurasi `flutter_local_notifications`: jadwalkan notifikasi pengingat belajar harian lokal berdasarkan zona waktu lokal pengguna (§5.2, §15)."
            ],
            tes=[
                "Integration test: pengguna baru dapat menyelesaikan onboarding langsung dalam guest mode tanpa form login.",
                "Unit test: perubahan preferensi di settings tersimpan ke database `user_settings` dan memicu update outbox sync.",
                "Unit test: notifikasi lokal dijadwalkan tepat pada jam yang ditentukan sesuai zona waktu lokal."
            ],
            observability=[
                "Event analitik produk: `onboarding_completed` dan `settings_changed` dipancarkan (§10.6).",
                "Log INFO saat jadwal notifikasi lokal diperbarui."
            ],
            out_of_scope=[
                "Push notification jarak jauh dari server via FCM/APNs (hanya notifikasi lokal terjadwal di MVP).",
                "Paywall langganan (dikerjakan di M6-1)."
            ],
            aturan_ketat=[
                "Guest mode WAJIB tersedia tanpa memaksa pendaftaran akun (§1, §5.3).",
                "Tombol 'Hapus Akun' WAJIB tersedia di aplikasi (kebijakan mutlak toko aplikasi) (§5.3, §12.2, §16.3).",
                "Persetujuan analitik wajib eksplisit diminta saat onboarding (§10.5, §12.2)."
            ],
            labels=["M3: Flutter Inti", "size:M", "area:mobile"]
        )
    ]
