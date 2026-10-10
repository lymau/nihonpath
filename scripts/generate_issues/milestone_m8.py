"""Milestone M8: Fase 3 (Opsional, Berdasarkan Data) issues."""

from typing import List
from .common import IssueSpec

def get_m8_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M8-1",
            title="Optimizer Server FSRS untuk Personalisasi Parameter",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan job batch di backend untuk mengoptimasi 21 parameter FSRS per pengguna berdasarkan minimal 1.000 review log dan menyinkronkan parameter hasil optimasi ke user_settings.",
            acuan="§5.4 (Personalisasi optimizer server), §6.3 (user_settings), §15 (M8 Fase 3)",
            input_data="Partisi `review_logs` historis pengguna di PostgreSQL / storage Parquet, optimizer FSRS (Python / Rust bindings).",
            output_data="Job BullMQ di `apps/api/src/jobs/fsrs_optimizer.job.ts` dan pembaruan field `user_settings.fsrs_params`.",
            langkah=[
                "Buat service batch job optimizer FSRS di backend NestJS/Worker.",
                "Seleksi pengguna yang memiliki minimal 1.000 riwayat entri `review_logs` valid (§15, M8).",
                "Eksekusi algoritma optimasi FSRS (menjalankan optimasi 21 parameter FSRS berbasis loss function log loss / RMSE pada memori retensi pengguna).",
                "Validasi bahwa parameter hasil optimasi berada dalam batas konvergen yang wajar.",
                "Perbarui field `fsrs_params` pada tabel `user_settings` pengguna dengan menaikkan field `version` dan `user_seq` (§6.3, §7.3).",
                "Parameter personalisasi otomatis terkirim ke klien mobile saat sesi pull berikutnya dan diterapkan oleh Scheduler lokal klien."
            ],
            tes=[
                "Unit test: optimizer menolak menjalankan optimasi jika review log < 1.000 entri.",
                "Integration test: eksekusi job berhasil menghitung 21 parameter FSRS baru dan memperbarui `user_settings`.",
                "Unit test: verifikasi parameter hasil optimasi diserialisasi dengan benar dalam format JSONB."
            ],
            observability=[
                "Metrik BullMQ durasi eksekusi optimizer job.",
                "Log INFO mencatat pengguna yang menerima parameter terpersonalisasi beserta nilai loss."
            ],
            out_of_scope=[
                "Optimasi parameter lokal on-device (beban komputasi terlalu berat untuk perangkat mobile, wajib di server sesuai §5.4, §15)."
            ],
            aturan_ketat=[
                "Minimal 1.000 review log per pengguna sebelum optimasi diizinkan berjalan (§15).",
                "Pembaruan user_settings wajib menaikkan seq dan version sesuai protokol sync (§6.3, §7.3)."
            ],
            labels=["M8: Fase 3", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M8-2",
            title="Latihan Shadowing dengan Rekaman Suara",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan fitur latihan shadowing audio: memutar audio referensi penutur asli dan merekam suara pengguna untuk perbandingan mandiri tanpa skoring otomatis.",
            acuan="§2 (Pelatihan fonetik variabilitas tinggi & shadowing), §15 (M8 Fase 3)",
            input_data="Audio referensi kalimat/kata dari paket passages/audio, mikrofon perangkat mobile.",
            output_data="Widget `ShadowingPlayer` di `apps/mobile/lib/ui/widgets/shadowing_player.dart` dan layar latihan shadowing.",
            langkah=[
                "Rancang antarmuka latihan shadowing:",
                "  - Memutar cuplikan audio kalimat/dialog penutur asli (§2);",
                "  - Mengaktifkan rekaman suara pengguna lokal secara sinkron atau bertahap;",
                "  - Memutar ulang rekaman pengguna berdampingan dengan audio penutur asli untuk evaluasi mandiri (self-assessment).",
                "Kebijakan Tanpa Skoring Otomatis (§15, M8): TANPA penilaian ucapan real-time atau skoring algoritmik (menghindari kebohongan akurasi speech scoring).",
                "Kebijakan Privasi (§12.1): file rekaman suara pengguna HANYA disimpan sementara di disk lokal perangkat dan DILARANG diunggah ke server."
            ],
            tes=[
                "Widget test: audio player memutar referensi dan kontrol perekam audio berfungsi.",
                "Integration test: file rekaman suara sementara dapat diputar ulang secara lokal.",
                "Security check: rekaman audio terbukti tidak pernah dikirim ke jaringan server backend."
            ],
            observability=[
                "Event analitik produk saat pengguna menyelesaikan latihan shadowing."
            ],
            out_of_scope=[
                "Speech-to-text atau penilaian pelafalan otomatis AI (eksplisit dilarang sesuai §1 Non-goals & §15 M8)."
            ],
            aturan_ketat=[
                "TANPA SKORING OTOMATIS pada runtime (§15 M8).",
                "DILARANG mengunggah audio rekaman pengguna ke server (privasi §12.1, §15)."
            ],
            labels=["M8: Fase 3", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M8-3",
            title="Backfill Riwayat Log Sinkronisasi di Latar Belakang",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan mekanisme penarikan riwayat review logs masa lalu secara malas (lazy backfill) di latar belakang pada perangkat baru untuk visualisasi riwayat jangka panjang.",
            acuan="§7.4 (Perangkat baru bootstrap & backfill lazy), §15 (M8 Fase 3)",
            input_data="Endpoint `GET /v1/sync/pull` dengan entitas `logs` dari backend.",
            output_data="Service `LogHistoryBackfillService` di `apps/mobile/lib/data/sync/`.",
            langkah=[
                "Pada perangkat baru (bootstrap), klien awalnya hanya menarik `cards, settings, progress` (tanpa log) untuk mempercepat onboarding (§7.4).",
                "Implementasikan service latar belakang untuk menarik riwayat `review_logs` terdahulu secara bertahap (chunking berbatas) saat perangkat terhubung Wi-Fi dan idle (§7.4, §15).",
                "Simpan log review historis yang ditarik ke dalam tabel lokal `review_logs` menggunakan aturan merge union (§7.3).",
                "Pastikan proses backfill tidak mengganggu prioritas antrean sync outbox atau transaksi review aktif pengguna."
            ],
            tes=[
                "Integration test: bootstrap awal tidak menarik tabel log, lalu service backfill menarik log secara bertahap.",
                "Unit test: penulisan log historis tidak menduplikasi ID yang sudah ada (idempoten)."
            ],
            observability=[
                "Log DEBUG mencatat progres jumlah log historis yang berhasil di-backfill."
            ],
            out_of_scope=[
                "Penghapusan log di server (log di server disimpan permanen/terpartisi)."
            ],
            aturan_ketat=[
                "Bootstrap perangkat baru wajib ringan; backfill log WAJIB lazy di latar belakang (§7.4).",
                "Penggabungan log wajib mematuhi aturan union tanpa menimpa (§7.3)."
            ],
            labels=["M8: Fase 3", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M8-4",
            title="Update Paket Konten Delta",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="content",
            tujuan="Mengembangkan mekanisme pembuatan dan distribusi pembaruan paket konten berbasis delta (diff) guna meminimalkan konsumsi kuota pengguna.",
            acuan="§9.3 (Distribusi paket & update delta fase 2/3), §15 (M8 Fase 3)",
            input_data="Versi paket konten lama `v{n}` dan versi baru `v{n+1}`.",
            output_data="CLI command `nihon-content delta build`, format paket `pack-{level}-{kind}-v{n}-to-v{n+1}.delta.zip`, dan patch installer di klien.",
            langkah=[
                "Implementasikan generator paket delta di `tools/content-cli/`:",
                "  - Bandingkan file `items.jsonl` dan aset antar dua versi paket berurutan;",
                "  - Hasilkan file patch biner / arsip zip delta yang hanya berisi item yang ditambah atau diubah;",
                "  - Hitung SHA-256 dan daftarkan ke tabel `content_packs` dengan metadata tipe delta.",
                "Implementasikan Delta Applicator di klien mobile Flutter:",
                "  - Klien mendeteksi ketersediaan paket delta untuk versi yang sedang terpasang;",
                "  - Unduh file delta berukuran kecil, terapkan patch ke SQLite dan penyimpanan asset lokal dalam transaksi atomik;",
                "  - Jika patching delta gagal, otomatis beralih (fallback) mengunduh paket penuh secara utuh (§9.3)."
            ],
            tes=[
                "Unit test: penerapan paket delta pada database lokal menghasilkan state data yang persis identik dengan instalasi paket penuh.",
                "Unit test: simulasi korupsi patch delta memicu fallback otomatis ke unduhan paket penuh."
            ],
            observability=[
                "Metrik perbandingan penghematan bandwidth (bytes delta vs bytes full package)."
            ],
            out_of_scope=[
                "Delta patching untuk audio stream terenkripsi."
            ],
            aturan_ketat=[
                "Penerapan patch delta WAJIB atomik dalam satu transaksi SQLite (§9.3).",
                "Fallback ke paket penuh wajib tersedia jika delta gagal (§9.3)."
            ],
            labels=["M8: Fase 3", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M8-5",
            title="Adaptasi Layout Tablet dan Widget Layar Utama",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="mobile",
            tujuan="Mengembangkan antarmuka responsif adaptif untuk perangkat tablet/iPad dan widget layar utama (Home Screen Widgets) untuk Android dan iOS.",
            acuan="§5.6 (Aksesibilitas & tata letak), §15 (M8 Fase 3)",
            input_data="Desain antarmuka Forui tablet, sistem widget OS (Android AppWidget & iOS WidgetKit).",
            output_data="Layout adaptif tablet di `apps/mobile/` dan native widgets di `android/` & `ios/`.",
            langkah=[
                "Implementasikan tata letak adaptif (adaptive two-pane / split view layout) untuk layar tablet (lebar layar > 600 dp) pada menu Library, Pelajaran, dan Pengaturan (§15).",
                "Kembangkan Home Screen Widget untuk Android (Glance / RemoteViews) dan iOS (WidgetKit):",
                "  - Menampilkan jumlah review yang jatuh tempo hari ini secara sekilas;",
                "  - Menampilkan streak belajar aktif pengguna;",
                "  - Tombol aksi cepat untuk langsung membuka sesi review di aplikasi.",
                "Sinkronisasikan data widget dari database SQLite lokal Drift melalui shared container / background service."
            ],
            tes=[
                "Widget test: antarmuka beralih mulus antara single-pane di ponsel dan two-pane di tablet.",
                "Platform test: widget Android dan iOS menampilkan angka review due yang akurat sesuai database lokal."
            ],
            observability=[
                "Log INFO saat data widget diperbarui oleh background task."
            ],
            out_of_scope=[
                "Aplikasi web desktop (eksplisit non-goals MVP/v1 sesuai §1)."
            ],
            aturan_ketat=[
                "Desain tablet tetap wajib mengikuti token desain Forui (§5.2.1).",
                "Widget dilarang mengakses jaringan secara independen (wajib membaca dari data lokal Drift) (§4.3)."
            ],
            labels=["M8: Fase 3", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M8-6",
            title="Partner Percakapan Berbasis LLM dengan Guardrail & Batasan Biaya",
            milestone="M8 — Fase 3",
            milestone_num=9,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan fitur partner percakapan interaktif berbasis LLM dengan kontrol biaya ketat, guardrail topik pembelajaran bahasa Jepang, dan evaluasi kepatuhan privasi tersendiri.",
            acuan="§1 Non-goals MVP (tanpa LLM runtime di MVP), §3.2 (Aturan LLM), §15 (M8 Fase 3 LLM conversation partner)",
            input_data="API LLM cloud aman, prompt guardrail pedagogis, konfigurasi kuota percakapan.",
            output_data="Module AI conversation di backend NestJS dan layar percakapan di Flutter.",
            langkah=[
                "Catatan Fase (§1, §15): Fitur ini secara tegas berada pada Fase 3 pasca-v1 setelah validasi produk inti.",
                "Rancang backend proxy AI percakapan dengan pembatasan biaya ketat:",
                "  - Kuota batas pesan harian per pengguna premium untuk mencegah pembengkakan biaya API (§15);",
                "  - Penegakan circuit breaker jika latency atau biaya LLM melewati batas (§11.3).",
                "Implementasikan Guardrail Sistem:",
                "  - Prompt sistem membatasi percakapan HANYA pada konteks latihan bahasa Jepang tingkat yang sesuai (N5 s/d N1);",
                "  - Koreksi tata bahasa dan saran ungkapan natural yang sopan;",
                "  - Filter keamanan konten dan pencegahan jailbreak.",
                "Evaluasi Kepatuhan Privasi Tersendiri (§12.2, §15):",
                "  - Minta persetujuan eksplisit pengguna sebelum mengaktifkan fitur percakapan LLM;",
                "  - Dilarang mengirimkan data pribadi (PII), email, atau identitas pengguna ke penyedia model LLM eksternal."
            ],
            tes=[
                "Security & Guardrail test: prompt injeksi atau permintaan di luar topik belajar bahasa Jepang ditolak dengan sopan.",
                "Integration test: kuota pesan harian ditegakkan secara akurat; request melebihi kuota menerima 429 / kuota habis.",
                "Privacy audit: payload yang dikirim ke LLM terbukti bebas dari data PII pengguna."
            ],
            observability=[
                "Metrik Prometheus pemantauan jumlah token LLM terpakai, biaya per sesi, dan latency respons.",
                "Log audit transaksi AI tanpa mencatat isi teks bebas pengguna (§10.2)."
            ],
            out_of_scope=[
                "Penggunaan LLM untuk generasi konten kurikulum utama tanpa review manusia (dilarang keras sesuai §3.2, §9.1)."
            ],
            aturan_ketat=[
                "DILARANG LLM saat runtime pada MVP/v1; fitur ini hanya untuk Fase 3 (§1 Non-goals, §15 M8).",
                "Wajib kontrol biaya dan kuota pesan ketat (§15).",
                "DILARANG mengirimkan data identitas atau PII pengguna ke API LLM (§10.2, §12.2)."
            ],
            labels=["M8: Fase 3", "size:M", "area:backend"]
        )
    ]
