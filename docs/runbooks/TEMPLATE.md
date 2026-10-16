# Runbook: [Nama Alert / Tipe Insiden Operasional]

Dokumen panduan operasional insiden NihonPath sesuai standar §10.7.

---

## Metadata Alert & Insiden

- **Alert Name:** `[NamaAlertPrometheusAtauCloudWatch]` (contoh: `SyncPushErrorRateHigh`, `DatabaseCpuAbove80Percent`)
- **Service / Komponen:** `[apps/api | apps/mobile | infra/database | infra/cdn | worker]`
- **Severity Level:** `[SEV1 | SEV2 | SEV3 | SEV4]`
  - `SEV1`: Insiden Kritis — Outage total, risiko kehilangan data review (§1 NFR), atau kegagalan API global.
  - `SEV2`: Insiden Mayor — Fitur inti terdegradasi (sync lambat/gagal, burn rate 14,4x pada jendela 1h & 5m).
  - `SEV3`: Insiden Minor — Degradasi parsial non-kritis (burn rate 6x pada jendela 6h, worker delay, cache miss melonjak).
  - `SEV4`: Peringatan / Warning — Anomali kecil yang belum mengancam SLO (disk > 80%, cert expires < 14 hari).
- **Target SLO / SLI Terdampak (§10.7):**
  - Ketersediaan API (target: 99,9% per bulan / error budget ~43 menit)
  - Latensi Sync Push Server (target: p95 < 500 ms, p99 < 1,5 s)
  - Latensi Sync Pull Server (target: p95 < 400 ms)
  - Sync Success Klien (target: >= 99,5%)
  - Crash-Free Sessions / Users (target: >= 99,5% / >= 99,0%)
  - Ketersediaan CDN Konten (target: 99,9%)
- **Dashboard Terkait (§10.7):**
  - Grafana Service Overview (RED)
  - Grafana Sync Health / Database / Queue Worker
- **Pemicu Alert (PromQL / CloudWatch Metric):**
  - `[Contoh: sum(rate(http_server_request_duration_seconds_count{status_class="5xx"}[5m])) / sum(rate(http_server_request_duration_seconds_count[5m])) > 0.02]`

---

## 1. Dampak

Jelaskan konsekuensi insiden terhadap pengguna, sistem, dan SLA layanan:

- **Dampak Pengguna Akhir (User Impact):**
  - Apakah pengguna dapat belajar dan melakukan review secara offline? (Ingat: SRS offline harus tetap berfungsi).
  - Apakah sinkronisasi data review gagal atau tertunda?
  - Apakah pengguna menerima respon error (HTTP 5xx, 429, atau timeout)?
- **Dampak Sistem & Infrastruktur (System Impact):**
  - Apakah antrean pesan BullMQ menumpuk (*queue backlog* meningkat)?
  - Apakah connection pool PgBouncer jenuh (`db_pool_waiting` melonjak)?
  - Apakah CPU container Fargate atau instance RDS melampaui ambang 80%?
- **Dampak SLO & Error Budget:**
  - Estimasi konsumsi error budget per jam (misal: burn rate 14,4x menghabiskan ~2% error budget bulanan per jam).

---

## 2. Diagnosis 5 Langkah

Ikuti urutan 5 langkah diagnosis terstruktur berikut untuk mengidentifikasi penyebab masalah secara cepat dan terukur:

### Langkah 1: Verifikasi Gejala & Status Firing Alert
- Periksa status alert di Prometheus Alertmanager atau AWS CloudWatch Alarms.
- Buka dashboard Grafana *Service Overview (RED)* untuk memverifikasi lonjakan request rate, error rate 5xx, atau latensi p95/p99.
- Pastikan apakah alert bersifat fluktuasi sesaat (*spike*) atau anomali persisten.

### Langkah 2: Identifikasi Cakupan & Severity Dampak
- Tentukan severity insiden berdasarkan dampak aktual (`SEV1`–`SEV4`).
- Cek segmentasi rute API yang bermasalah menggunakan label Prometheus `http_server_request_duration_seconds` (`route`, `method`, `status_class`).
- Dapatkan sampel payload error RFC 9457 untuk mengekstrak `code` (misal: `SYNC_OP_REJECTED`, `RATE_LIMITED`, `INTERNAL`) dan `trace_id`.

### Langkah 3: Analisis Log & Error Trace (OTel, Pino, Loki, Tempo)
- Buka Grafana Loki dan lakukan filter log berdasarkan service dan status:
  ```logql
  {service="api", env="prod"} |= "error" | json
  ```
- *Peringatan Keras (§10.2):* Pastikan tidak ada data PII (email, token, jawaban bebas) yang diekspos di log.
- Gunakan `trace_id` sampel pada Grafana Tempo untuk melihat span trace lengkap dari mobile, API gateway, handler service, hingga query database:
  - Cek durasi span manual: `sync.push.validate`, `sync.push.persist`, atau `sync.pull.query`.

### Langkah 4: Pemeriksaan Komponen Dependensi & Infrastruktur
- **Database (PostgreSQL / PgBouncer):**
  - Cek metrik `db_pool_in_use` dan `db_pool_waiting`. Jika pool habis, cek slow query via `db_query_duration_seconds`.
  - Cek CPU utilization dan replikasi lag RDS (`replication lag > 30s`).
- **Antrean & Cache (Redis / BullMQ):**
  - Cek metrik `bullmq_queue_depth` dan memory usage Redis ElastiCache.
- **Storage & CDN (S3 / CloudFront):**
  - Cek error rate 5xx CloudFront dan ketersediaan bucket S3 (`nihonpath-packs`, `nihonpath-audio`).
- **Container Runtime (ECS Fargate):**
  - Cek status health check container ALB di endpoint `/healthz` dan memory saturation.

### Langkah 5: Penentuan Akar Masalah (Root Cause Identification)
- Simpulkan kategori akar masalah:
  1. *Kode / Rilis Terbaru:* Bug pada rilis aplikasi terbaru atau migrasi skema database yang belum diindeks.
  2. *Infrastruktur Dependensi:* Kegagalan node RDS, jaringan AWS degraded, atau saturasi koneksi.
  3. *Lonjakan Beban:* Lonjakan traffic tak terduga (*thundering herd*) melampaui kapasitas autoscale.
  4. *Dependensi Eksternal:* Gangguan pada third-party OIDC provider (Google/Apple) atau App Store billing.

---

## 3. Mitigasi

Tindakan darurat segera untuk memulihkan ketersediaan sistem (*stop the bleeding*):

- **Opsi A: Rollback Rilis Kode (Jika dipicu oleh deployment terbaru)**
  - Revert commit pada branch utama atau jalankan rollback ECS Task Definition ke versi image sebelumnya yang stabil:
    ```bash
    aws ecs update-service --cluster nihonpath-<env> --service nihonpath-<env>-api --task-definition <previous-task-def>
    ```
- **Opsi B: Peningkatan Kapasitas Darurat (Scale-Out)**
  - Naikkan desired count container Fargate secara manual jika autoscaling terlambat merespons lonjakan beban:
    ```bash
    aws ecs update-service --cluster nihonpath-<env> --service nihonpath-<env>-api --desired-count <target-count>
    ```
- **Opsi C: Isolasi & Graceful Degradation**
  - Jika database kelebihan beban, aktifkan circuit breaker / pengetatan rate limiter untuk melindungi ketersediaan operasi baca.
  - Untuk sync push: kembalikan respons HTTP 429 atau 503 dengan header `Retry-After`. Klien mobile akan menyimpan log di outbox lokal dan mencoba ulang secara aman.
- **Opsi D: Failover Database / Restart Pooler**
  - Jika primary database hang atau mengalami hardware failure, lakukan reboot with failover via RDS Console atau CLI.
  - Restart container PgBouncer jika koneksi zombie menumpuk.
- **Verifikasi Pemulihan:**
  - Amati Grafana Dashboard selama minimal 10 menit: pastikan error rate 5xx < 0.1%, latensi kembali ke baseline, dan alert berhenti firing (*resolved*).

---

## 4. Eskalasi

Jalur komunikasi dan eskalasi penanganan insiden:

- **Incident Commander (IC) (§10.7):**
  - Setiap penanganan insiden SEV1–SEV2 dipimpin oleh **satu Incident Commander tunggal** yang bertanggung jawab atas koordinasi, mitigasi, dan komunikasi.
- **Matriks Kontak Eskalasi:**
  - **Level 1 (On-Call Engineer):** Triage awal dan diagnosis langkah 1–3 (waktu respon: < 15 menit untuk SEV1/SEV2).
  - **Level 2 (Tech Lead / Core Maintainer):** Dihubungi jika diagnosis langkah 4–5 membutuhkan keputusan arsitektur atau rollback besar (waktu respon: < 30 menit).
  - **Level 3 (Platform Owner / AWS Support):** Eskalasi ke AWS Business/Enterprise Support jika terdapat degradasi level cloud provider di region Jakarta (`ap-southeast-3`).
- **Kanal Komunikasi Insiden:**
  - Slack / Discord: `#incident-war-room`
  - Status Page Eksternal: Diperbarui jika SEV1 berlangsung lebih dari 30 menit.

---

## 5. Pasca Insiden & Postmortem

Prosedur wajib setelah insiden terselesaikan:

1. **Postmortem Tanpa Menyalahkan (*Blameless Postmortem*) (§10.7):**
   - Wajib disusun dan direview bersama tim dalam waktu maksimal **5 hari kerja**.
   - Fokus pada pembelajaran sistem (*systemic failure*), bukan kelalaian individu.
2. **Format Dokumen Postmortem:**
   - Ringkasan insiden, durasi downtime, dan total error budget yang terbakar.
   - Kronologi detail (*timeline kejadian* berbasis timestamp UTC/WIB).
   - Analisis akar masalah dengan metode 5 Whys.
   - Tindakan perbaikan (*action items*) dengan nomor GitHub Issue yang ditugaskan ke pemilik konkret.
3. **Pembaruan Keputusan & Dokumentasi:**
   - Perbarui runbook ini jika ada langkah diagnosis atau mitigasi baru yang ditemukan selama penanganan.
   - Catat keputusan perbaikan arsitektural di `docs/decision-log.md` sesuai format §0 Aturan 1.
