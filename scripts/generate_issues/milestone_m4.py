"""Milestone M4: Auth dan Sync Klien issues."""

from typing import List
from .common import IssueSpec

def get_m4_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M4-1",
            title="Klien API ter-generate + alur auth + secure storage + refresh otomatis",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengintegrasikan klien API Dio hasil generate openapi, penyimpanan token aman di flutter_secure_storage, dan interceptor auto-refresh token singleton.",
            acuan="§4.2 (flutter_secure_storage, dio), §8.1 (Header & Error), §8.3 (Autentikasi & Rotasi token), §12.1 (Pencegahan token theft)",
            input_data="Klien Dio ter-generate dari M0-2, endpoint auth dari M1-3 & M1-4.",
            output_data="Auth repository di `apps/mobile/lib/data/auth/`, Dio interceptor di `lib/data/api/`, dan secure token storage service.",
            langkah=[
                "Integrasikan klien `Dio` hasil generasi otomatis dari kontrak `openapi.yaml` (dilarang menulis model klien API manual! §0 Aturan 2, §8.1).",
                "Implementasikan `TokenStorage` menggunakan `flutter_secure_storage` untuk menyimpan JWT access token, refresh token, dan `device_id` (UUIDv7) secara terenkripsi di Keychain (iOS) dan EncryptedSharedPreferences (Android).",
                "Buat Dio Interceptor untuk menyematkan header wajib di setiap request outgoing (§8.1):",
                "  - `Authorization: Bearer <jwt>`",
                "  - `X-Device-Id: <device_id>`",
                "  - `X-App-Version: <version>`",
                "  - `traceparent`: header W3C Trace Context yang digenerate oleh klien agar trace tersambung end-to-end ke backend (§8.1, §10.4).",
                "Implementasikan Interceptor penanganan token kedaluwarsa (HTTP 401):",
                "  - Kunci request (singleton lock / queue) agar ketika ada banyak request paralel yang menerima 401, pemanggilan rotasi `POST /v1/auth/refresh` HANYA DILAKUKAN SEKALI (§15, M4-1).",
                "  - Simpan pasangan token baru yang dirotasi ke secure storage dan ulangi request yang tertunda.",
                "  - Jika server merespons error refresh (misal `AUTH_REFRESH_REUSED` atau token expired), hapus seluruh token dari storage dan arahkan pengguna ke login kembali."
            ],
            tes=[
                "Unit test: request otomatis menyertakan header Authorization, X-Device-Id, X-App-Version, dan traceparent.",
                "Integration test (mock server): simulasi 5 request simultan menerima 401 terbukti hanya memicu TEPAT SATU pemanggilan endpoint `/auth/refresh`.",
                "Unit test: secure storage menyimpan dan membaca token dengan aman."
            ],
            observability=[
                "Log DEBUG saat token di-refresh (DILARANG mencatat token string mentah ke log! §10.2).",
                "Traceparent span ID diteruskan ke setiap HTTP request."
            ],
            out_of_scope=[
                "Sinkronisasi data outbox (dikerjakan di M4-2).",
                "UI login sosial Apple/Google (dikerjakan di M4-5)."
            ],
            aturan_ketat=[
                "Token WAJIB disimpan di `flutter_secure_storage`, DILARANG di SharedPreferences biasa (§4.2, §12.1).",
                "Refresh token WAJIB dieksekusi secara singleton saat request paralel terjadi (§15, M4-1).",
                "DILARANG mencatat access token atau refresh token ke konsol/log (§10.2).",
                "Header `traceparent` W3C wajib dikirim di setiap request (§8.1)."
            ],
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-2a",
            title="Outbox DAO & Queue Manager Klien",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan Outbox DAO lokal Drift, queue manager mutasi data pengguna, debouncing sinkronisasi 5 detik, dan isolasi batch maksimal 200 op.",
            acuan="§4.3 (Prinsip outbox), §6.2 (Tabel outbox), §7.1 (Push berbasis outbox), §7.2 (Batas batch), Lampiran C.1 (requestSync debounce)",
            input_data="Tabel Drift `outbox` dari M3-2.",
            output_data="Class `OutboxDao` dan `OutboxManager` di `apps/mobile/lib/data/sync/`.",
            langkah=[
                "Implementasikan `OutboxDao` untuk menyimpan mutasi data pengguna ke tabel `outbox`:",
                "  Kolom: `op_id` (UUIDv7 PK), `type` (`review_log`, `card_state`, `settings`, `lesson_progress`, `test_attempt`), `payload_json`, `created_at`, `attempts`, `next_attempt_at`, `last_error` (§6.2).",
                "Setiap perubahan lokal (review, perubahan pengaturan, progres) wajib menulis entri `outbox` dalam TRANSAKSI YANG SAMA dengan mutasi tabel data terkait (§7.1, Lampiran C.1).",
                "Implementasikan debouncing: picu notifikasi sinkronisasi dengan debounce 5 detik saat review/belajar sedang berlangsung (§5.4, §7.4, Lampiran C.1).",
                "Implementasikan fungsi pembacaan antrean: ambil entri outbox dengan kondisi `WHERE next_attempt_at <= now ORDER BY created_at ASC LIMIT 200` (§7.2, §7.4).",
                "Pastikan total payload batch tidak melebihi batas 512 KB (§7.2)."
            ],
            tes=[
                "Unit test: penulisan data review otomatis menyisipkan record ke tabel `outbox` dalam transaksi atomik.",
                "Unit test: batch builder membatasi maksimal 200 operasi dan tidak melebihi 512 KB.",
                "Unit test: mekanisme debounce 5 detik berhasil menunda pemanggilan sync saat operasi berturut-turut masuk."
            ],
            observability=[
                "Metrik sisi klien `outbox_depth` dicatat saat sesi belajar selesai (§10.5)."
            ],
            out_of_scope=[
                "Eksekusi request HTTP push/pull ke server (dikerjakan di M4-2b).",
                "Merge data masuk dari pull (dikerjakan di M4-2c)."
            ],
            aturan_ketat=[
                "Penulisan outbox WAJIB dalam transaksi yang sama dengan penulisan data (§7.1).",
                "Batas batch outbox WAJIB maksimal 200 op dan 512 KB (§7.2).",
                "ID operasi WAJIB menggunakan UUIDv7 (§6.1)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M4-2 sesuai arahan §15.",
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-2b",
            title="SyncClient Loop Push & Pull",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan algoritma loop sinkronisasi Push & Pull sesuai §7.4, penanganan status accepted/duplicate/rejected, sinkronisasi clock offset, dan dead letter queue.",
            acuan="§1 NFR (Latensi sync & nol data loss), §7.2 (Endpoint sync), §7.4 (Algoritma klien lengkap), §16.3 (Validasi jam perangkat salah)",
            input_data="OutboxManager M4-2a, Klien API Dio M4-1, Drift DB.",
            output_data="Class `SyncClient` di `apps/mobile/lib/data/sync/sync_client.dart`.",
            langkah=[
                "Implementasikan fungsi `sync()` persis sesuai algoritma §7.4:",
                "  1. Kunci eksekusi: jika proses sync sedang berjalan, segera return (cegah race condition).",
                "  2. LOOP PUSH: ambil ops dari outbox (`ORDER BY created_at LIMIT 200`). Jika kosong, keluar loop push.",
                "  3. Kirim request: `POST /v1/sync/push` membawa payload ops dan device_id.",
                "  4. Evaluasi respon server per-op:",
                "     - `accepted` atau `duplicate` -> hapus operasi dari tabel outbox (§7.4).",
                "     - `rejected` (error 4xx permanen):",
                "       * Jika kode `SYNC_CLOCK_INVALID` (§6.3, §16.3), JANGAN hapus outbox! Tampilkan banner ke pengguna 'Periksa jam perangkat Anda'.",
                "       * Untuk rejected permanen lain: pindahkan ke tabel `dead_letter`, log error, dan increment metrik `sync_op_rejected_total` (§7.4).",
                "     - Error jaringan / 5xx / 429: naikkan `attempts++`, hitung `next_attempt_at = now + min(2^attempts * 2s, 15 menit) + jitter(0..30%)`, dan hentikan loop push sementara (§7.4).",
                "  5. LOOP PULL: panggil `GET /v1/sync/pull?cursor=<cursor>&limit=500` berulang kali sampai `has_more == false` (§7.4).",
                "  6. Untuk setiap respons pull, delegasikan perubahan ke Merge Engine (M4-2c) dalam satu transaksi lokal, lalu perbarui `pull_cursor` di tabel `sync_state` (§7.4).",
                "  7. Sinkronisasi waktu: simpan `clock_offset_ms = server_time - now()` di tabel `sync_state` (§7.4)."
            ],
            tes=[
                "Integration test (mock server): alur push berhasil menghapus op yang accepted dan duplicate dari outbox.",
                "Unit test: op dengan error SYNC_CLOCK_INVALID tidak dihapus dari outbox dan memicu notifikasi peringatan.",
                "Unit test: penanganan error jaringan menghitung backoff eksponensial dengan jitter acak.",
                "Integration test: pull loop terus menarik batch sampai has_more bernilai false dan memperbarui cursor."
            ],
            observability=[
                "Metrik sisi klien: `sync_attempt{result='success|error', duration_ms}` dicatat (§10.5).",
                "Logging INFO durasi total sync, jumlah op terkirim, dan jumlah perubahan diterima."
            ],
            out_of_scope=[
                "Algoritma merge spesifik antar entitas (dikerjakan di M4-2c).",
                "Background periodic runner WorkManager (dikerjakan di M4-3)."
            ],
            aturan_ketat=[
                "Algoritma sync WAJIB persis sesuai pseudocode §7.4.",
                "Jika jam perangkat salah (`SYNC_CLOCK_INVALID`), DILARANG menghapus outbox (§16.3).",
                "Pencegahan kehilangan data: tidak ada data yang dihapus dari outbox sebelum ada konfirmasi accepted/duplicate (§1 NFR)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M4-2 sesuai arahan §15.",
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-2c",
            title="Client Merge Engine",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan mesin penggabungan data (merge engine) sisi klien sesuai tabel aturan resolusi konflik §7.3 dalam transaksi lokal atomik.",
            acuan="§6.2 (Skema lokal), §7.3 (Aturan merge tabel lengkap), §7.4",
            input_data="Payload perubahan dari respons `GET /v1/sync/pull` M4-2b, Drift DB.",
            output_data="Class `SyncMergeEngine` di `apps/mobile/lib/data/sync/merge_engine.dart`.",
            langkah=[
                "Implementasikan merge handler dalam satu transaksi lokal atomik per batch perubahan pull:",
                "1. Entitas `review_log` (§7.3): Union murni. Tidak pernah ditimpa! Jika ID log review sudah ada di SQLite lokal, abaikan (duplicate).",
                "2. Entitas `card_state` (§7.3): Last-Write-Wins (LWW) dengan aturan tie-breaker ketat:",
                "   - Bandingkan dengan record lokal yang memiliki `card_id` sama.",
                "   - Snapshot dengan `last_review_at` lebih besar menang;",
                "   - Jika `last_review_at` sama, record dengan `reps` lebih besar menang;",
                "   - Jika masih sama, record dengan `updated_at` lebih besar menang.",
                "   - Terapkan snapshot pemenang ke `user_cards` (seluruh log review tetap utuh tanpa diubah).",
                "3. Entitas `settings` (§7.3): LWW berdasarkan `updated_at` yang lebih besar; field `version` meningkat.",
                "4. Entitas `lesson_progress` (§7.3): Status bersifat maju-saja (`not_started` < `in_progress` < `completed`); nilai `best_score` = nilai maksimum antara lokal dan remote.",
                "5. Entitas `test_attempt` (§7.3): Union berdasarkan ID percobaan."
            ],
            tes=[
                "Unit test: review_log lokal tidak pernah ditimpa oleh data pull.",
                "Unit test: card_state LWW menguji seluruh kondisi tie-breaker (last_review_at, reps, updated_at).",
                "Unit test: status lesson_progress tidak pernah mundur (completed tidak bisa kembali ke in_progress).",
                "Unit test: best_score pada lesson_progress mengambil nilai tertinggi."
            ],
            observability=[
                "Log DEBUG mencatat jumlah baris yang digabungkan per tipe entitas."
            ],
            out_of_scope=[
                "Fitur 'Bangun Ulang Kartu dari Log' (ditunda ke fase 2 sesuai §7.3)."
            ],
            aturan_ketat=[
                "Aturan merge WAJIB persis mematuhi tabel §7.3 tanpa improvisasi.",
                "Log review TIDAK PERNAH ditimpa atau dihapus (§7.3).",
                "Lesson progress hanya boleh maju, dilarang mundur (§7.3)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M4-2 sesuai arahan §15.",
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-3",
            title="Pemicu sync + workmanager + backoff berjitter",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengintegrasikan seluruh pemicu sinkronisasi klien: selesai sesi, aplikasi foreground, jaringan pulih (connectivity_plus), dan background periodic sync 15 menit via workmanager.",
            acuan="§5.2 (workmanager, connectivity_plus), §7.4 (Pemicu sync & backoff berjitter)",
            input_data="SyncClient M4-2b, package `workmanager`, package `connectivity_plus`.",
            output_data="Class `SyncTriggerCoordinator` di `apps/mobile/lib/data/sync/sync_coordinator.dart` dan background worker callback.",
            langkah=[
                "Daftarkan pemicu sinkronisasi aplikasi sesuai §7.4:",
                "  1. Selesai sesi: pemicu otomatis saat sesi review atau pelajaran diselesaikan.",
                "  2. App Foreground: integrasikan `WidgetsBindingObserver` / `AppLifecycleListener` untuk memicu sync saat aplikasi kembali dibuka dari background.",
                "  3. Jaringan pulih: dengarkan stream `connectivity_plus`; picu sync seketika saat koneksi internet pulih dari offline.",
                "  4. Pasca-login: picu sync langsung setelah login atau taut akun berhasil.",
                "  5. Periodik latar belakang: konfigurasikan `workmanager` untuk menjalankan sync setiap 15 menit saat perangkat idle/terhubung internet.",
                "Terapkan proteksi debouncing 5 detik pada seluruh event pemicu untuk mencegah badai request (request storms) (§7.4).",
                "Pastikan penanganan concurrency lock aktif sehingga tidak ada dua proses sync yang dieksekusi bersamaan."
            ],
            tes=[
                "Integration test: perubahan lifecycle aplikasi ke resumed memicu fungsi sync.",
                "Integration test: simulasi event connectivity berubah dari none ke wifi memicu sync.",
                "Unit test: eksekusi 5 pemicu bersamaan dalam waktu 1 detik hanya menghasilkan 1 kali pemanggilan sync karena debouncing."
            ],
            observability=[
                "Log INFO mencatat event yang memicu sinkronisasi (lifecycle, network, timer, user)."
            ],
            out_of_scope=[
                "Sinkronisasi real-time via WebSocket (tidak ada WebSocket di arsitektur MVP)."
            ],
            aturan_ketat=[
                "Pemicu sync wajib mencakup: sesi selesai, foreground, jaringan pulih, periodik 15 menit, dan pasca-login (§7.4).",
                "Debounce 5 detik WAJIB aktif untuk mencegah badai request (§5.4, §7.4)."
            ],
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-4",
            title="Fault injection sync (putus, 500, lambat, 429)",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Menguji ketahanan modul sinkronisasi klien terhadap berbagai skenario kegagalan jaringan dan server untuk memverifikasi garansi nol kehilangan data.",
            acuan="§1 NFR (Nol kehilangan data review, offline-first), §5.7 (Fault injection), §7.4 (Backoff eksponensial)",
            input_data="SyncClient dan Outbox, mock HTTP server.",
            output_data="Integration test suite di `apps/mobile/integration_test/sync_fault_test.dart`.",
            langkah=[
                "Susun skenario fault injection komprehensif:",
                "  1. Simulasi putus koneksi di tengah pengiriman request push (koneksi drop mendadak): verifikasi outbox tidak hilang dan berhasil dikirim ulang saat jaringan pulih.",
                "  2. Simulasi server merespons HTTP 500 Internal Server Error acak: verifikasi antrean outbox bertahan dan menerapkan backoff eksponensial dengan jitter.",
                "  3. Simulasi server merespons HTTP 429 Too Many Requests dengan header `Retry-After: 30`: verifikasi klien mematuhi penundaan retry.",
                "  4. Simulasi respon server sangat lambat (timeout 15 detik, §11.3): verifikasi klien membatalkan request tepat waktu tanpa freeze UI.",
                "  5. Simulasi mode pesawat: pengguna melakukan 50 review saat offline penuh, lalu beralih ke online -> verifikasi seluruh 50 review log terkirim ke server secara utuh tanpa ada satu pun data yang hilang (§1 NFR)."
            ],
            tes=[
                "Integration test: skenario putus koneksi lulus tanpa data outbox hilang.",
                "Integration test: penanganan respon 429 dan 500 lulus dengan retry backoff yang benar.",
                "Integration test: skenario offline pesawat -> online sinkronisasi membuktikan nol kehilangan data."
            ],
            observability=[
                "Log Sentry dan metrik failure reporting diverifikasi aktif saat error terjadi."
            ],
            out_of_scope=[
                "Chaos test pada infrastruktur database staging (dikerjakan di M5-3)."
            ],
            aturan_ketat=[
                "Kehilangan data review HARUS 0 (nol data loss) (§1 NFR).",
                "UI aplikasi harus tetap dapat digunakan belajar penuh saat backend offline/error (§4.3, §11.3)."
            ],
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M4-5",
            title="Tautkan guest, hapus akun, ekspor data (UI)",
            milestone="M4 — Auth dan Sync Klien",
            milestone_num=5,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan antarmuka UI di Flutter untuk menautkan akun guest ke akun permanen (Google/Apple/Email), dialog konfirmasi hapus akun, dan permintaan ekspor data.",
            acuan="§5.3 (/settings, tautan akun), §7.4 (Guest -> akun), §8.2, §12.2 (Penghapusan akun & ekspor data UI)",
            input_data="Endpoint `/v1/auth/link`, `DELETE /v1/me`, `POST /v1/me/export` dari M1-4 dan M1-5.",
            output_data="Widget antarmuka di `apps/mobile/lib/features/settings/` (`account_settings.dart`, `link_account_dialog.dart`, `delete_account_dialog.dart`).",
            langkah=[
                "Implementasikan UI Tautkan Akun di Pengaturan:",
                "  - Tombol tautkan akun dengan Google Sign-In, Sign in with Apple, dan Email OTP.",
                "  - Panggil endpoint `POST /v1/auth/link` (§7.4, §8.2).",
                "  - Jika identitas sudah dimiliki akun lain (terjadi konflik), tampilkan dialog peringatan eksplisit kepada pengguna untuk memilih akun yang dipertahankan (MVP tidak melakukan auto-merge data, §7.4).",
                "Implementasikan UI Hapus Akun (§12.2):",
                "  - Tombol 'Hapus Akun' dengan dialog konfirmasi ganda yang menjelaskan konsekuensi penghapusan permanen.",
                "  - Panggil endpoint `DELETE /v1/me`; setelah sukses, bersihkan seluruh secure storage token, reset database SQLite lokal, dan arahkan pengguna kembali ke onboarding.",
                "Implementasikan UI Ekspor Data (§12.2):",
                "  - Tombol 'Ekspor Data Belajar' di menu pengaturan; panggil `POST /v1/me/export`.",
                "  - Tampilkan notifikasi dengan tautan unduh bertanda tangan setelah file siap diunduh."
            ],
            tes=[
                "Widget test: dialog konfirmasi penghapusan akun tampil dengan peringatan yang jelas.",
                "Integration test (staging): alur tautkan akun guest ke Google/Apple berhasil memperbarui identitas tanpa kehilangan progres belajar.",
                "Integration test: penghapusan akun berhasil memanggil API dan membersihkan storage lokal."
            ],
            observability=[
                "Event analitik produk: `settings_changed` dicatat.",
                "Log INFO saat alur penautan akun atau penghapusan akun dipicu."
            ],
            out_of_scope=[
                "Fitur merge otomatis antar 2 akun berbeda (di luar lingkup MVP sesuai §7.4)."
            ],
            aturan_ketat=[
                "Tombol Hapus Akun WAJIB ada di dalam aplikasi (aturan wajib App Store & Google Play, §5.3, §12.2, §16.3).",
                "Jika tautan akun konflik, DILARANG merge data diam-diam tanpa persetujuan eksplisit pengguna (§7.4)."
            ],
            labels=["M4: Auth & Sync", "size:M", "area:mobile"]
        )
    ]
