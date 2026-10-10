"""Milestone M5: Observability, Hardening, Beta Tertutup issues."""

from typing import List
from .common import IssueSpec

def get_m5_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M5-1",
            title="Sentry, metrik klien, analitik dengan consent",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="M",
            area="mobile",
            tujuan="Mengintegrasikan Sentry Flutter dengan scrubbing PII ketat, metrik performa kustom klien, dan pelacakan taksonomi analitik PostHog berbasis izin pengguna (consent).",
            acuan="§5.2 (sentry_flutter), §10.5 (Observability sisi klien), §10.6 (Analitik produk), §12.2 (Persetujuan privasi UU PDP & GDPR)",
            input_data="Konfigurasi DSN Sentry dan API Key PostHog, taksonomi event §10.6.",
            output_data="Module telemetri di `apps/mobile/lib/core/telemetry/` dan integrasi di `main.dart`.",
            langkah=[
                "Integrasikan SDK Sentry Flutter (`sentry_flutter`) di `main.dart`:",
                "  - Tangkap crash, ANR, unhandled exception, dan flutter error dengan breadcrumb navigasi.",
                "  - Aktifkan release health tracking untuk mengukur crash-free sessions.",
                "  - Pasang trace performa: cold start aplikasi, latensi transisi review card, dan durasi sync.",
                "  - Scrubbing PII ketat: WAJIB set `sendDefaultPii = false` dan filter URL/teks sebelum dikirim (§10.5).",
                "Implementasikan pengiriman metrik kustom sisi klien (sampling 100%) sebagai event analitik (§10.5):",
                "  `sync_attempt{result, duration_ms}`, `outbox_depth` (di akhir sesi), `pack_download{result, size, duration_ms}`, `db_migration{result, from, to}`, `review_card_render_ms` (p50/p95).",
                "Integrasikan analitik PostHog dengan manajemen consent privasi (§10.5, §12.2):",
                "  - Analitik HANYA aktif jika pengguna telah memberikan persetujuan eksplisit di layar onboarding.",
                "  - Terapkan taksonomi event ketat berformat snake_case tanpa teks bebas (§10.6): `app_open`, `onboarding_completed`, `lesson_started`, `lesson_completed`, `review_session_started`, `review_session_completed {cards, accuracy, duration_s}`, `daily_goal_met`, `streak_extended`, `pack_downloaded`, `paywall_viewed`, `subscription_started`, `mocktest_completed`, `settings_changed`."
            ],
            tes=[
                "Unit test: verifikasi Sentry interceptor menghapus data PII (email, input bebas) dari breadcrumb dan exception payload.",
                "Widget test: pelacakan analitik diblokir sepenuhnya jika consent pengguna bernilai false.",
                "Integration test: penyelesaian sesi review memancarkan event `review_session_completed` dengan metrik cards, accuracy, dan duration_s."
            ],
            observability=[
                "Dashboard Sentry menerima error crash uji coba dan release health.",
                "Dashboard PostHog menerima taksonomi event sesuai spesifikasi."
            ],
            out_of_scope=[
                "Alerting Prometheus di backend (dikerjakan di M5-2).",
                "A/B testing fitur tingkat lanjut."
            ],
            aturan_ketat=[
                "`sendDefaultPii = false` pada Sentry; DILARANG merekam PII ke crash report (§10.5).",
                "Analitik produk WAJIB menghormati persetujuan pengguna (UU PDP & GDPR) (§10.5, §12.2).",
                "DILARANG menyertakan teks bebas buatan pengguna dalam event analitik (§10.6)."
            ],
            labels=["M5: Observability & Hardening", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M5-2",
            title="Dashboard, alert burn-rate, runbook (§10.7)",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="M",
            area="security-ops",
            tujuan="Mengonfigurasi dashboard Grafana lengkap, sistem alerting berbasis multi-window multi-burn-rate pada Alertmanager, serta menyusun dokumen runbook operasional.",
            acuan="§10.3 (Metrik penamaan Prometheus), §10.7 (SLO, alert, dashboard, runbook), §11.3",
            input_data="Metrik Prometheus backend dan server OTel Collector.",
            output_data="Konfigurasi Prometheus alert rules, dashboard Grafana JSON di `infra/grafana/`, dan dokumen runbook di `docs/runbooks/*.md`.",
            langkah=[
                "Buat 7 Dashboard Grafana wajib sesuai spesifikasi §10.7:",
                "  1. Service Overview (RED metrics: Rate, Errors, Duration per route).",
                "  2. Sync Health (push ops, batch size, pull latency, rejection, clock anomalies).",
                "  3. Database Health (koneksi, pool in use/waiting, slow queries, partisi).",
                "  4. Queue & Worker (BullMQ queue depth, job duration, failed jobs).",
                "  5. Authentication (login rate per provider, refresh reuse detection spike).",
                "  6. Learning Outcomes (true retention, leech rate, due backlog median).",
                "  7. Client Release Health (crash-free rate, client sync success rate).",
                "Konfigurasi aturan alert Alertmanager berbasis multi-window multi-burn-rate (§10.7):",
                "  - Alert PAGE (kritis): konsumsi error budget 14,4x pada window 1 jam dan 5 menit (anggaran error habis dalam 2 hari).",
                "  - Alert TICKET (peringatan): konsumsi error budget 6x pada window 6 jam dan 30 menit.",
                "  - Alert Infrastruktur: CPU DB > 80% (15 menit), koneksi DB > 80%, replication lag > 30s, disk > 80%, queue depth tinggi selama 10 menit, `partition_default_rows > 0`, lonjakan reuse token, backup gagal, sertifikat kedaluwarsa < 14 hari, 5xx rate > 2% selama 5 menit.",
                "Tulis dokumen runbook di `docs/runbooks/<nama_alert>.md` untuk setiap alert: wajib memuat Dampak, Diagnosis 5 langkah, Mitigasi, dan Eskalasi (§10.7).",
                "Uji coba pemicuan alert secara sengaja (fire drill) untuk membuktikan alert dan runbook berfungsi."
            ],
            tes=[
                "Uji simulasi Prometheus alert rules menggunakan `promtool test rules` lulus 100%.",
                "Uji coba sengaja (misal menyuntikkan 5xx atau menahan koneksi DB) memicu alert PAGE/TICKET dengan tautan runbook yang tepat.",
                "Verifikasi setiap file runbook memiliki 4 seksi wajib (§10.7)."
            ],
            observability=[
                "Seluruh metrik dan visualisasi dashboard tampil stabil di Grafana.",
                "Notifikasi alert terkirim ke kanal notifikasi on-call (Slack/PagerDuty/Email)."
            ],
            out_of_scope=[
                "Load testing generator trafik (dikerjakan di M5-3 via k6)."
            ],
            aturan_ketat=[
                "Alert harus berbasis burn rate multi-window multi-burn-rate (§10.7).",
                "Setiap alert WAJIB menunjuk ke runbook spesifik dengan format diagnosis 5 langkah (§10.7).",
                "Label metrik DILARANG memuat user_id, device_id, atau URL penuh (§10.3)."
            ],
            labels=["M5: Observability & Hardening", "size:M", "area:security-ops"]
        ),
        IssueSpec(
            id="M5-3",
            title="Load/soak/chaos test (§11.5)",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="M",
            area="qa",
            tujuan="Mengeksekusi load test, soak test, dan chaos test menggunakan skrip k6 di lingkungan staging untuk memvalidasi kepatuhan target SLO dan keandalan sistem.",
            acuan="§1 NFR (SLO ketersediaan 99,9%, latensi sync p95 < 500 ms), §11.1 (Model kapasitas), §11.5 (Skenario k6 lengkap)",
            input_data="Lingkungan staging yang menyerupai produksi, skrip pengujian beban k6.",
            output_data="Skrip pengujian di `tests/k6/` dan laporan hasil uji beban di `docs/reports/load-test-report.md`.",
            langkah=[
                "Tulis dan eksekusi skrip pengujian beban k6 untuk 6 skenario wajib §11.5:",
                "  1. Skenario 1 (Push Stabil): 500 req/s push sync selama 30 menit -> verifikasi SLO p95 < 500 ms, p99 < 1,5 s terpenuhi (§1 NFR, §10.7).",
                "  2. Skenario 2 (Lonjakan Trafik): lonjakan beban 10x lipat (traffic spike) selama 5 menit -> verifikasi autoscaling dan load shedding (503 + Retry-After) jika diperlukan.",
                "  3. Skenario 3 (Soak Test): pengujian beban stabil nonstop selama 8 jam -> verifikasi tidak ada kebocoran memori (memory leak) di Node.js, pool leak di Postgres, atau saturasi memori Redis.",
                "  4. Skenario 4 (Pull Berat): simulasi pull dengan cursor jauh tertinggal dari ribuan client -> verifikasi latensi query UNION ALL tetap efisien dan tidak mengunci database.",
                "  5. Skenario 5 (Push Paralel): eksekusi request push paralel untuk pengguna yang sama -> verifikasi `user_seq` tetap gapless tanpa deadlock.",
                "  6. Skenario 6 (Chaos Test): simulasi failover master database PostgreSQL dan crash kontainer Redis saat beban aktif -> verifikasi degradasi anggun sesuai matriks §11.3.",
                "Dokumentasikan hasil pengukuran latensi, throughput, dan error rate pada laporan resmi."
            ],
            tes=[
                "k6 test run: seluruh skenario 1 s/d 6 lolos dengan tingkat keberhasilan memenuhi SLO (SLO error rate < 0,1%).",
                "Verifikasi p95 latensi sync push < 500 ms di bawah beban 500 req/s.",
                "Verifikasi integritas sequence data: nol duplikasi dan nol gap pada `user_seq` pasca-tes."
            ],
            observability=[
                "Dashboard Grafana memantau metrik latensi, CPU, memori, dan pool DB secara real-time selama pengujian beban berlangsung."
            ],
            out_of_scope=[
                "Pengujian beban aplikasi mobile di perangkat fisik (hanya pengujian sisi server backend/API)."
            ],
            aturan_ketat=[
                "Target kelulusan adalah SLO terpenuhi: ketersediaan 99,9%, push p95 < 500 ms (§10.7, §11.5).",
                "Pengujian beban WAJIB dijalankan di lingkungan staging terisolasi (§11.5, §14.2)."
            ],
            labels=["M5: Observability & Hardening", "size:M", "area:qa"]
        ),
        IssueSpec(
            id="M5-4",
            title="Checklist MASVS L1 + tinjauan keamanan",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="M",
            area="security-ops",
            tujuan="Melakukan audit keamanan menyeluruh sesuai OWASP Mobile Application Security Verification Standard (MASVS) L1, pemindaian dependensi, SAST, dan secret scanning.",
            acuan="§12.1 (Ancaman utama dan kontrol lengkap), §14.3 (CI security scanning)",
            input_data="Codebase backend dan mobile, tool pemindaian (CodeQL, Semgrep, Trivy, Gitleaks, OSV-Scanner).",
            output_data="Dokumen hasil audit di `docs/security/masvs-l1-checklist.md` dan pipeline security scanning di CI.",
            langkah=[
                "Jalankan checklist OWASP MASVS L1 (Level 1) pada aplikasi Flutter (§12.1):",
                "  - Konfigurasi code obfuscation dan R8 pada build rilis Android.",
                "  - Verifikasi seluruh token disimpan di Keychain / EncryptedSharedPreferences (bukan file plain text).",
                "  - Verifikasi tidak ada logging data sensitif atau PII saat build mode release aktif.",
                "  - Verifikasi seluruh komunikasi jaringan dipaksa menggunakan TLS 1.2+ (diutamakan 1.3) dan HSTS.",
                "Konfigurasi security scanning otomatis di pipeline CI (.github/workflows/security.yml):",
                "  - Secret scanning dengan Gitleaks untuk mencegah commit kunci rahasia.",
                "  - Software Supply Chain audit: lockfile verification, Dependabot, OSV-Scanner, dan `npm audit` (§12.1).",
                "  - Static Application Security Testing (SAST) menggunakan CodeQL atau Semgrep.",
                "  - Pemindaian kontainer docker menggunakan Trivy.",
                "Pastikan kriteria terpenuhi: TEMUAN LEVEL TINGGI / KRITIS (HIGH/CRITICAL) HARUS 0 (§15, M5-4)."
            ],
            tes=[
                "Eksekusi pipeline CI security scan lulus dengan 0 temuan berstatus Critical dan High.",
                "Verifikasi file APK/IPA release terbukti diobfuskasi (analisis dekompilasi).",
                "Verifikasi header HSTS dan penolakan koneksi TLS di bawah versi 1.2 pada server."
            ],
            observability=[
                "Laporan security scan terbit pada tab GitHub Security / Actions."
            ],
            out_of_scope=[
                "Certificate Pinning (eksplisit TIDAK dipakai di MVP karena risiko operasional sesuai §12.1).",
                "MASVS L2 / hardware-backed keystore biometrik."
            ],
            aturan_ketat=[
                "Temuan keamanan High/Critical WAJIB 0 (§15, M5-4).",
                "Certificate pinning TIDAK DIPAKAI di MVP (§12.1).",
                "Role database aplikasi dilarang memiliki hak DDL (§12.1)."
            ],
            labels=["M5: Observability & Hardening", "size:M", "area:security-ops"]
        ),
        IssueSpec(
            id="M5-5",
            title="Latihan restore backup",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="S",
            area="security-ops",
            tujuan="Melakukan latihan simulasi pemulihan bencana (disaster recovery drill) dari backup database PostgreSQL PITR dan mendokumentasikan pencapaian target RPO/RTO.",
            acuan="§11.4 (Backup dan pemulihan bencana), §15 (M5-5), Lampiran B (Checklist pra-rilis)",
            input_data="Arsip WAL kontinu PostgreSQL dan snapshot mingguan di environment staging.",
            output_data="Laporan hasil latihan pemulihan bencana di `docs/runbooks/dr-recovery-report.md`.",
            langkah=[
                "Lakukan latihan restorasi database (DR drill) secara langsung di environment staging (§11.4):",
                "  - Simulasikan insiden kehilangan data pada waktu T.",
                "  - Eksekusi Point-In-Time Recovery (PITR) dari arsip WAL kontinu ke instance database pengujian baru.",
                "Ukur dan catat metrik pemulihan riil:",
                "  - Ukur RPO (Recovery Point Objective): verifikasi kehilangan data kurang dari 5 menit (§11.4).",
                "  - Ukur RTO (Recovery Time Objective): verifikasi waktu dari insiden hingga database pulih dan dapat melayani query kurang dari 1 jam (§11.4).",
                "Verifikasi integritas data hasil restore: lakukan query konsistensi tabel `users`, `user_sync_state`, `user_cards`, dan partisi `review_logs`.",
                "Tulis laporan resmi hasil simulasi pemulihan di `docs/runbooks/dr-recovery-report.md` (Catatan §11.4: backup yang belum pernah diuji dianggap tidak ada)."
            ],
            tes=[
                "Integritas database hasil restorasi terbukti identik dengan titik waktu pemulihan (PITR).",
                "RPO terukur ≤ 5 menit dan RTO terukur ≤ 1 jam memenuhi standar §11.4."
            ],
            observability=[
                "Log dan metrik waktu proses restore tercatat dalam laporan."
            ],
            out_of_scope=[
                "Simulasi failover multi-region otomatis (MVP menggunakan arsitektur single-region multi-AZ dengan salinan backup ke Singapura sesuai §11.4)."
            ],
            aturan_ketat=[
                "Target pemulihan WAJIB RPO ≤ 5 menit dan RTO ≤ 1 jam (§11.4).",
                "Latihan restore backup WAJIB terdokumentasi; backup yang tidak diuji dianggap tidak ada (§11.4)."
            ],
            labels=["M5: Observability & Hardening", "size:S", "area:security-ops"]
        ),
        IssueSpec(
            id="M5-6",
            title="Beta tertutup (TestFlight, Play Internal)",
            milestone="M5 — Observability, Hardening, Beta Tertutup",
            milestone_num=6,
            size="M",
            area="qa",
            tujuan="Mendistribusikan build rilis beta tertutup ke TestFlight dan Google Play Internal Sharing serta memantau kestabilan aplikasi selama minimal 2 minggu.",
            acuan="§1 NFR (Crash-free sessions > 99,5%), §10.7 (Client release health), §11.6 (Strategi rilis mobile), §14.3 (Fastlane), §15 (M5-6)",
            input_data="Build rilis Flutter flavor staging/prod, pipeline Fastlane.",
            output_data="Build aplikasi di Apple TestFlight dan Google Play Console Internal Track serta laporan metrik rilis.",
            langkah=[
                "Konfigurasi Fastlane di `apps/mobile/` untuk otomasi build dan distribusi ke Apple TestFlight dan Google Play Internal Sharing Track (§14.3).",
                "Distribusikan build aplikasi beta tertutup kepada grup penguji (tester internal dan terpilih).",
                "Pantau dashboard Sentry Release Health dan analitik PostHog secara kontinu selama periode 2 minggu pengujian (§15, M5-6):",
                "  - Pantau tingkat sesi bebas crash (Crash-free sessions): target WAJIB DI ATAS 99,5% (§1 NFR, §10.7, §15).",
                "  - Pantau tingkat keberhasilan sinkronisasi (Sync success rate): target WAJIB DI ATAS 99,5% (§10.7).",
                "  - Kumpulkan feedback kegagalan review, isu input IME, atau anomali transisi kartu.",
                "Perbaiki setiap bug regresi berstatus blocker sebelum melangkah ke milestone rilis publik (M6)."
            ],
            tes=[
                "Aplikasi berjalan stabil pada berbagai perangkat fisik Android dan iOS penguji.",
                "Metrik Sentry membuktikan Crash-free sessions bertahan di atas 99,5% selama minimal 2 minggu pemantauan."
            ],
            observability=[
                "Dashboard Sentry Release Health dan dashboard Client Release Health Grafana aktif memantau metrik crash dan error."
            ],
            out_of_scope=[
                "Rilis publik terbuka 100% ke store (dikerjakan di M6-5)."
            ],
            aturan_ketat=[
                "Crash-free sessions WAJIB di atas 99,5% selama 2 minggu sebagai kriteria selesai (§1 NFR, §15, M5-6).",
                "Jika crash-free rate turun di bawah 99,5%, rilis WAJIB dihentikan/ditunda (§11.6)."
            ],
            labels=["M5: Observability & Hardening", "size:M", "area:qa"]
        )
    ]
