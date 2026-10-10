"""Milestone M6: Rilis v1 (Level 0–N5 gratis; N4–N3 premium) issues."""

from typing import List
from .common import IssueSpec

def get_m6_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M6-1a",
            title="Integrasi SDK RevenueCat & Layar Paywall Klien",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="mobile",
            tujuan="Mengintegrasikan SDK purchases_flutter (RevenueCat), membangun antarmuka layar /paywall tanpa dark pattern, cache entitlement offline 7 hari, dan tombol pulihkan pembelian.",
            acuan="§5.2 (purchases_flutter), §5.3 (/paywall), §11.3 (Degradasi RevenueCat), §13 (Monetisasi & Billing)",
            input_data="API keys RevenueCat untuk Android dan iOS, penawaran produk langganan in-app store.",
            output_data="Layar `/paywall` di `apps/mobile/lib/features/paywall/`, billing service di `lib/data/billing/`.",
            langkah=[
                "Integrasikan SDK RevenueCat (`purchases_flutter`) di Flutter (pilihan default sesuai §13). Hubungkan identifier pengguna dengan `user_id` anonim / login.",
                "Bangun antarmuka layar `/paywall` menggunakan Forui widgets (`FScaffold`, `FCard`, `FButton`) (§5.2.1):",
                "  - Kebijakan Tanpa Dark Pattern (§13): tombol tutup silang (close button) harus terlihat jelas; dilarang menggunakan hitung mundur palsu atau diskon manipulatif.",
                "  - Tampilkan harga resmi terlokalisasi langsung dari store (tier IDR di Indonesia, §13).",
                "  - Wajib sertakan tombol 'Pulihkan Pembelian' (Restore Purchases) yang berfungsi (§13).",
                "Implementasikan Caching Entitlement Sisi Klien (§11.3, §13):",
                "  - Simpan status entitlement aktif di penyimpanan lokal aman.",
                "  - Terapkan MASA TENGGANG (grace period) 7 HARI saat perangkat offline: pengguna tetap dapat mengakses fitur premium yang sudah diunduh selama masa tenggang ketika tidak ada koneksi ke RevenueCat/store (§11.3, §13).",
                "Pancarkan event analitik: `paywall_viewed` dan `subscription_started` (§10.6)."
            ],
            tes=[
                "Widget test: layar paywall me-render penawaran harga dan tombol tutup serta pulihkan pembelian.",
                "Integration test (Store Sandbox): pengujian pembelian in-app sandbox di Android dan iOS berhasil memberikan entitlement premium.",
                "Unit test: simulasi offline membuktikan entitlement tetap valid selama masa tenggang 7 hari dan kedaluwarsa setelah hari ke-8."
            ],
            observability=[
                "Event analitik `paywall_viewed` dan `subscription_started` tercatat di PostHog.",
                "Log INFO saat status entitlement lokal diperbarui."
            ],
            out_of_scope=[
                "Metode pembayaran selain IAP resmi Apple dan Google Play (eksplisit non-goals MVP sesuai §1).",
                "Iklan in-app (eksplisit dilarang sesuai §13, aplikasi tanpa iklan)."
            ],
            aturan_ketat=[
                "DILARANG DARK PATTERN: tombol tutup harus jelas, tidak ada countdown palsu (§13).",
                "Tombol 'Pulihkan Pembelian' WAJIB ada (§13).",
                "Masa tenggang offline entitlement WAJIB 7 hari (§11.3, §13).",
                "Harga WAJIB ditampilkan dari store lokal (tier IDR) (§13)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-1 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M6-1b",
            title="Backend Webhook Handler RevenueCat",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan endpoint webhook RevenueCat untuk sinkronisasi mutasi langganan ke tabel subscriptions dan endpoint verifikasi entitlement pengguna.",
            acuan="§6.3 (Tabel subscriptions), §8.2 (Billing), §10.3 (billing_verify_total), §13 (Monetisasi & Billing)",
            input_data="Payload webhook event RevenueCat, shared authorization secret header.",
            output_data="Module billing di `apps/api/src/modules/billing/` dengan endpoint `POST /v1/webhooks/revenuecat` dan `GET /v1/billing/entitlements`.",
            langkah=[
                "Implementasikan endpoint `POST /v1/webhooks/revenuecat` (atau `/v1/webhooks/apple`, `/v1/webhooks/google` jika opsi B, §8.2, §13).",
                "Verifikasi header otorisasi bersama (shared authorization secret) pada incoming request webhook untuk mencegah spoofing request (§13).",
                "Ekstrak event langganan (INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION).",
                "Upsert record ke tabel `subscriptions` di PostgreSQL (§6.3):",
                "  `user_id`, `platform` ('apple'|'google'), `product_id`, `original_txn_id`, `status`, `expires_at`, `last_verified_at`.",
                "Implementasikan endpoint `GET /v1/billing/entitlements` (§8.2, §13): kueri status langganan aktif pengguna berdasarkan token JWT.",
                "Perbarui metrik Prometheus `billing_verify_total{platform, result}` (§10.3)."
            ],
            tes=[
                "Security test: webhook menolak request tanpa shared secret header yang valid (401 Unauthorized).",
                "Integration test: webhook event pembelian berhasil memperbarui tabel `subscriptions`.",
                "Integration test: endpoint `GET /v1/billing/entitlements` mengembalikan status entitlement aktif yang sesuai."
            ],
            observability=[
                "Metrik `billing_verify_total{platform, result}` dicatat (§10.3).",
                "Log audit INFO untuk setiap mutasi status langganan (dengan user_hash, tanpa PII)."
            ],
            out_of_scope=[
                "Pemrosesan pembayaran langsung dengan kartu kredit / payment gateway eksternal."
            ],
            aturan_ketat=[
                "Webhook WAJIB memvalidasi shared authorization header (§13).",
                "Validasi receipt dan status langganan WAJIB diverifikasi di server, JANGAN percaya klien (§12.1).",
                "DILARANG mencatat informasi kartu atau PII pembayaran ke log (§10.2)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-1 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M6-1c",
            title="Penegakan Entitlement Server pada Paket Konten Premium",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="backend",
            tujuan="Mengimplementasikan penegakan entitlement server-side pada pembuatan URL unduhan paket premium (N4–N1, passages, audio offline).",
            acuan="§6.3 (content_packs.is_premium), §8.2 (download-url), §12.1 (Proteksi konten premium), §13 (Freemium: N5 gratis, N4-N1 premium)",
            input_data="Tabel `content_packs`, tabel `subscriptions`, service presigned URL S3.",
            output_data="Logika proteksi entitlement di `apps/api/src/modules/content/content.service.ts`.",
            langkah=[
                "Kaitkan pengecekan entitlement langganan pada endpoint `GET /v1/content/packs/:id/download-url` (§8.2, §13):",
                "  - Baca atribut `is_premium` pada paket konten yang diminta dari tabel `content_packs`.",
                "  - Model freemium (§13): Level 0 (Kana) dan Level N5 gratis untuk seluruh pengguna (`is_premium = false`).",
                "  - Level N4 s/d N1, mock test lengkap, dan paket audio/passages offline tingkat lanjut ditandai `is_premium = true`.",
                "  - Jika paket berstatus premium, verifikasi tabel `subscriptions` untuk `user_id` pemanggil: pastikan ada record langganan aktif (`expires_at > now()`).",
                "  - Jika pengguna tidak memiliki entitlement valid, tolak dengan status 403 Forbidden dan kode error RFC 9457 `ENTITLEMENT_REQUIRED` (§8.4).",
                "  - Jika valid, generate URL unduhan S3/CloudFront bertanda tangan (presigned URL) berumur pendek."
            ],
            tes=[
                "Security test: pengguna gratis berhasil mengunduh paket core dan audio Level N5.",
                "Security test: pengguna gratis menerima error ENTITLEMENT_REQUIRED saat mencoba meminta URL unduh paket Level N4 atau N3.",
                "Security test: pengguna dengan subscription aktif berhasil memperoleh download-url bertanda tangan untuk paket premium."
            ],
            observability=[
                "Log WARN saat akses paket premium ditolak karena ketiadaan entitlement.",
                "Metrik Prometheus counter penolakan entitlement."
            ],
            out_of_scope=[
                "Enkripsi DRM biner pada file audio (perlindungan cukup via presigned URL dan rate limit sesuai §12.1)."
            ],
            aturan_ketat=[
                "Server WAJIB menegakkan entitlement pada URL unduh paket; dilarang mengandalkan proteksi klien semata (§12.1, §13).",
                "Level 0 dan N5 WAJIB tetap gratis (§13).",
                "Presigned URL WAJIB berumur pendek (§12.1)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-1 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:backend"]
        ),
        IssueSpec(
            id="M6-2a",
            title="Silabus, Kurasi & Enrichment Konten Level N4",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="content",
            tujuan="Mengurasi dan melengkapi seluruh kurikulum Level N4 (~1.500 kosakata kumulatif, ~300 kanji kumulatif, tata bahasa bentuk te/ta/nai/keigo dasar) dengan tinjauan manusia 100%.",
            acuan="§3.1 (Target N4), §3.2 (Lisensi & LLM), §3.3 (Hierarki), §9.1 (Pipeline konten), §9.2",
            input_data="Dataset `content/_pool/`, generator audio TTS M2-4.",
            output_data="Dataset kurikulum Level N4 di `content/n4/` dengan status `human_reviewed` 100%.",
            langkah=[
                "Kurasi materi Level N4: kosakata kumulatif mencapai ~1.500 kata, kanji kumulatif ~300 karakter (§3.1).",
                "Kurasi tata bahasa N4: bentuk te/ta/nai, kondisional dasar (tara, ba, to), keigo dasar (sonkeigo/kenjougo dasar), dsb. (§3.1).",
                "Susun ke dalam Unit dan Lesson tematik dengan formula 8 vocab, 4 kanji (kanji-in-context), dan 2 grammar per unit (§3.3).",
                "Enrichment: contoh kalimat Tatoeba, tokenisasi Sudachi build-time, anotasi segmen furigana, dan pra-render audio neural TTS 2 suara (f1 dan m1) format Opus (§9.1 tahap 3).",
                "Lakukan review manusia oleh peninjau berkualifikasi minimal N2; pastikan 100% item berstatus `provenance: human_reviewed` dengan atribut `reviewed_by` valid (§9.1 tahap 4).",
                "Eksekusi `nihon-content validate` dan build paket `pack-4-*-v1.zip` serta verifikasi anggaran ukuran (§9.3)."
            ],
            tes=[
                "Validasi `nihon-content validate` lulus 100% pada dataset N4.",
                "100% item N4 berstatus `human_reviewed` (nol `llm_draft`).",
                "Verifikasi ukuran paket zip N4 memenuhi batas anggaran §9.3."
            ],
            observability=[
                "Laporan cakupan konten memvalidasi ketercapaian target kurikulum N4."
            ],
            out_of_scope=[
                "Penyusunan materi N3 (dikerjakan di M6-2b).",
                "Materi N2 dan N1 (dikerjakan di M7-2)."
            ],
            aturan_ketat=[
                "100% item N4 WAJIB bertanda `provenance: human_reviewed` (§9.1 tahap 4).",
                "Prinsip kanji-in-context wajib dipatuhi (§3.3).",
                "DILARANG menyalin dari buku teks berhak cipta (§0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-2 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M6-2b",
            title="Silabus, Kurasi & Enrichment Konten Level N3",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="content",
            tujuan="Mengurasi dan melengkapi seluruh kurikulum Level N3 (~3.750 kosakata kumulatif, ~650 kanji kumulatif, ekspresi kausatif/pasif & nuansa) dengan tinjauan manusia 100%.",
            acuan="§3.1 (Target N3), §3.2 (Lisensi & LLM), §3.3, §9.1 (Pipeline konten), §9.2",
            input_data="Dataset `content/_pool/`, generator audio TTS M2-4.",
            output_data="Dataset kurikulum Level N3 di `content/n3/` dengan status `human_reviewed` 100%.",
            langkah=[
                "Kurasi materi Level N3: kosakata kumulatif mencapai ~3.750 kata, kanji kumulatif ~650 karakter (§3.1).",
                "Kurasi tata bahasa N3: ekspresi kausatif, pasif, kausatif-pasif, nuansa kalimat sehari-hari, dan konjungsi teks umum (§3.1).",
                "Organisasikan materi ke dalam Unit dan Lesson tematik sesuai hierarki pedagogis produk (§3.3).",
                "Enrichment: padankan kalimat contoh Tatoeba, tokenisasi build-time Sudachi, anotasi segmen furigana terstruktur, dan audio neural TTS 2 suara format Opus (§9.1 tahap 3).",
                "Lakukan review manusia oleh reviewer level N2 atau lebih tinggi; pastikan 100% item berstatus `provenance: human_reviewed` dengan `reviewed_by` valid (§9.1 tahap 4).",
                "Eksekusi `nihon-content validate` dan build paket `pack-3-*-v1.zip` serta verifikasi anggaran ukuran (§9.3)."
            ],
            tes=[
                "Validasi `nihon-content validate` lulus 100% pada dataset N3.",
                "Pemeriksaan membuktikan 100% item N3 berstatus `human_reviewed` tanpa materi LLM tanpa review.",
                "Verifikasi paket zip N3 mematuhi anggaran ukuran §9.3."
            ],
            observability=[
                "Laporan cakupan konten memvalidasi ketercapaian target kumulatif N3."
            ],
            out_of_scope=[
                "Penyusunan konten N2 dan N1 (dikerjakan di M7-2)."
            ],
            aturan_ketat=[
                "100% item N3 WAJIB bertanda `provenance: human_reviewed` (§9.1 tahap 4).",
                "DILARANG menyalin konten berhak cipta (soal resmi JLPT, buku komersial, dsb., §0 Aturan 5).",
                "Anggaran ukuran paket zip wajib dipatuhi (§9.3)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-2 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M6-3a",
            title="Content Pipeline Reading Bertingkat & Listening",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="content",
            tujuan="Mengembangkan alat pipeline konten untuk materi bacaan bertingkat (analisis lexical coverage 95-98% & tokenisasi Sudachi) dan audio dialog listening multi-suara.",
            acuan="§2 (Extensive reading 95-98% coverage), §3.7 (Reading & Listening), §9.1, §9.3 (Anggaran passages)",
            input_data="Teks bacaan dan naskah dialog listening N5–N3.",
            output_data="CLI command `nihon-content passages build`, file YAML di `content/passages/`, dan paket zip `pack-*-passages-v1.zip`.",
            langkah=[
                "Implementasikan penganalisis bacaan bertingkat di `tools/content-cli/`:",
                "  - Hitung metrik cakupan leksikal: pastikan persentase kata yang sudah dikenal oleh pengguna pada level tersebut berada di rentang 95–98% (§2, §3.7).",
                "  - Eksekusi tokenisasi build-time menggunakan Sudachi dan hasilkan anotasi furigana serta kamus arti (gloss) per kata (§3.7).",
                "  - Batasi panjang teks bacaan N5 pada rentang 50–150 karakter dan tingkatkan bertahap untuk N4 dan N3 (§3.7).",
                "Implementasikan pipeline konten listening:",
                "  - Format dialog dengan audio multi-suara pra-render.",
                "  - Sediakan variasi kecepatan audio (0,75x dan 1,0x) (§3.7).",
                "  - Sertakan pertanyaan pemahaman gaya soal JLPT 聴解 dan transkrip teks lengkap.",
                "Kemas materi ke dalam paket zip `passages` dan verifikasi batas anggaran < 40 MB (§9.3)."
            ],
            tes=[
                "Unit test: penganalisis leksikal memvalidasi cakupan kata 95–98% pada bacaan bertingkat.",
                "Unit test: tokenisasi build-time menghasilkan segmen furigana dan gloss yang tepat.",
                "Verifikasi ukuran paket zip passages mematuhi anggaran < 40 MB (§9.3)."
            ],
            observability=[
                "Log output menampilkan persentase lexical coverage untuk setiap bacaan yang diproses."
            ],
            out_of_scope=[
                "UI layar bacaan dan listening di Flutter (dikerjakan di M6-3b)."
            ],
            aturan_ketat=[
                "Tokenisasi dan anotasi gloss WAJIB dilakukan saat build, BUKAN saat runtime (§3.2, §3.7).",
                "Anggaran ukuran paket passages WAJIB < 40 MB (§9.3).",
                "Konten bacaan dan soal wajib orisinal atau berlisensi terbuka bebas klaim hak cipta (§0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-3 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M6-3b",
            title="UI Layar Reading (/reading/:id) & Listening (/listening/:id)",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan antarmuka layar latihan membaca /reading/:id (gloss ketuk & metrik cakupan kata) dan layar mendengar /listening/:id (kontrol kecepatan & transkrip terkunci).",
            acuan="§3.7 (Skill lain: Reading & Listening), §5.2.1, §5.3 (/reading/:id, /listening/:id)",
            input_data="Data paket passages dari M6-3a.",
            output_data="Layar `/reading/:id` dan `/listening/:id` di `apps/mobile/lib/features/` (`reading/`, `listening/`).",
            langkah=[
                "Implementasikan layar `/reading/:id` menggunakan Forui `FScaffold` (§5.2.1, §5.3):",
                "  - Tampilkan teks bacaan bertingkat dengan furigana proporsional.",
                "  - Fitur Gloss Ketuk (§3.7): mengetuk kata mana pun dalam bacaan memunculkan popover/kartu Forui yang menampilkan arti kata, bacaan kana, dan level kata.",
                "  - Tampilkan indikator metrik persentase kata yang dikenal oleh pengguna pada bacaan tersebut (§3.7).",
                "  - Sertakan pertanyaan pemahaman bacaan di akhir teks.",
                "Implementasikan layar `/listening/:id` menggunakan Forui widgets (§5.2.1, §5.3):",
                "  - Audio player terintegrasi dengan tombol kontrol kecepatan: beralih antara 0,75x dan 1,0x (§3.7).",
                "  - Tampilkan pertanyaan pemahaman audio gaya ujian 聴解.",
                "  - Proteksi Transkrip (§3.7): transkrip teks dialog WAJIB TERKUNCI pada awalnya, dan hanya dibuka/ditampilkan kepada pengguna setelah pengguna menjawab pertanyaan pemahaman.",
                "Catat penyelesaian latihan ke dalam progres lokal dan outbox sync."
            ],
            tes=[
                "Widget test: mengetuk kata pada teks reading memunculkan gloss arti yang benar.",
                "Widget test: player listening merespons perubahan kecepatan 0,75x dan 1,0x.",
                "Widget test: transkrip audio listening terbukti tersembunyi sebelum dijawab dan terbuka setelah dijawab."
            ],
            observability=[
                "Event analitik produk saat latihan reading dan listening diselesaikan."
            ],
            out_of_scope=[
                "Ujian mock test lengkap (dikerjakan di M7-1)."
            ],
            aturan_ketat=[
                "Transkrip listening WAJIB hanya dibuka setelah pengguna menjawab pertanyaan (§3.7).",
                "UI wajib memanfaatkan token tema Forui (§5.2.1).",
                "Target sentuh interaksi kata minimal 48 dp (§5.6)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M6-3 sesuai arahan §15.",
            labels=["M6: Rilis v1", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M6-4",
            title="Aset Toko, Privasi, Atribusi Lisensi, Kebijakan Penghapusan Akun",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="M",
            area="security-ops",
            tujuan="Menyiapkan kelengkapan legal dan kepatuhan toko aplikasi (Google Play & Apple App Store): halaman atribusi lisensi CC BY-SA, kebijakan privasi dwibahasa, formulir data safety, dan kepatuhan penamaan non-afiliasi JLPT.",
            acuan="§3.2 (Atribusi lisensi terbuka), §12.2 (Privasi, UU PDP, GDPR, Hapus akun), §16.3 (Kebijakan toko & batasan merek JLPT)",
            input_data="Daftar dependensi open source dan dataset lisensi (§3.2).",
            output_data="Halaman Atribusi di aplikasi (`/settings/attribution`), dokumen `docs/legal/privacy-policy.md`, `docs/legal/terms.md`, dan checklist kepatuhan toko.",
            langkah=[
                "Buat Halaman Atribusi Lisensi di dalam aplikasi (`/settings/attribution`) (§3.2, §16.3):",
                "  - Wajib menyertakan teks atribusi dan lisensi: JMdict (CC BY-SA 4.0), KANJIDIC2 (CC BY-SA 4.0), KanjiVG (CC BY-SA 3.0), Tatoeba (CC BY 2.0 FR / CC0), Sudachi/UniDic (Apache 2.0 / BSD), serta Lucide Icons (§3.2, §5.2.1).",
                "Susun Kebijakan Privasi (Privacy Policy) dan Syarat Ketentuan (Terms of Service) dalam dwibahasa (Indonesia dan Inggris) yang mematuhi UU PDP Indonesia dan GDPR (§12.2).",
                "Lengkapi formulir kepatuhan Google Play Data Safety dan Apple Privacy Nutrition Label:",
                "  - Deklarasikan bahwa aplikasi TIDAK mengumpulkan data lokasi presisi, data kontak, atau ID iklan (§12.2).",
                "Verifikasi penegakan kebijakan tombol 'Hapus Akun' di menu pengaturan aplikasi (memenuhi persyaratan mutlak Apple & Google) (§12.2, §16.3).",
                "Pemeriksaan Kepatuhan Merek JLPT (§16.3): pastikan seluruh teks di aplikasi dan metadata toko TIDAK menggunakan istilah resmi JLPT yang menyiratkan afiliasi/sponsor resmi (gunakan frasa 'bergaya JLPT' atau 'tingkat setara JLPT')."
            ],
            tes=[
                "Pemeriksaan kepatuhan: halaman atribusi menampilkan seluruh lisensi sumber data terbuka.",
                "Pemeriksaan teks: tidak ada klaim afiliasi resmi terhadap JLPT atau The Japan Foundation.",
                "Verifikasi formulir data safety toko cocok 100% dengan implementasi telemetri aplikasi."
            ],
            observability=[
                "Dokumentasi kepatuhan legal tersimpan lengkap di repository."
            ],
            out_of_scope=[
                "Materi kampanye iklan berbayar."
            ],
            aturan_ketat=[
                "Halaman atribusi lisensi CC BY-SA WAJIB ada di dalam aplikasi (§3.2, §16.3).",
                "DILARANG mengklaim afiliasi resmi dengan JLPT; gunakan istilah 'bergaya JLPT' (§16.3).",
                "Tombol hapus akun wajib berfungsi penuh (§12.2, §16.3)."
            ],
            labels=["M6: Rilis v1", "size:M", "area:security-ops"]
        ),
        IssueSpec(
            id="M6-5",
            title="Staged Rollout Produksi v1 dengan Gerbang §11.6",
            milestone="M6 — Rilis v1",
            milestone_num=7,
            size="S",
            area="security-ops",
            tujuan="Mengeksekusi peluncuran publik v1 secara bertahap (staged rollout) dengan mematuhi gerbang kriteria penghentian otomatis (halt criteria).",
            acuan="§1 NFR, §10.7 (SLO ketersediaan & crash-free), §11.6 (Strategi rilis bertahap mobile & backend), Lampiran B (Checklist pra-rilis)",
            input_data="Checklist pra-rilis Lampiran B, build rilis produksi.",
            output_data="Konfigurasi staged rollout di Google Play Console & Apple App Store Connect, serta deployment canary di backend.",
            langkah=[
                "Verifikasi kelulusan 10 butir Checklist Pra-Rilis Lampiran B (SLO aktif, runbook ada, load test lulus, restore backup teruji, 100% konten human_reviewed, hapus akun berfungsi, kill switch teruji, on-call siap, §Lampiran B).",
                "Eksekusi deployment backend: gunakan rolling/blue-green dengan canary 5% selama 15 menit; rollback otomatis jika burn-rate alert menyala (§11.6).",
                "Konfigurasi Staged Rollout mobile bertahap persis sesuai §11.6:",
                "  `1% → 5% → 20% → 50% → 100%` di Google Play Console dan Phased Release 7 hari di iOS App Store.",
                "Gerbang Penghentian Otomatis (Halt Criteria, §11.6):",
                "  - HENTIKAN rollout seketika jika tingkat sesi bebas crash (crash-free sessions) turun di bawah 99,5% (§1 NFR, §11.6).",
                "  - HENTIKAN rollout jika tingkat keberhasilan sinkronisasi (sync success rate) yang dilaporkan klien turun di bawah 99,5% (§10.7, §11.6).",
                "  - HENTIKAN rollout jika alert burn-rate backend menyala.",
                "Tingkatkan persentase rollout ke tahap berikutnya hanya jika metrik release health terpantau stabil selama minimal 24 jam per tahap."
            ],
            tes=[
                "Checklist pra-rilis Lampiran B terverifikasi 100% terpenuhi.",
                "Uji coba canary 5% di backend berhasil tanpa memicu alarm.",
                "Rollout mobile mencapai 100% tanpa pelanggaran kriteria halt."
            ],
            observability=[
                "Dashboard Client Release Health dan Service Overview Grafana dipantau ketat secara real-time.",
                "Notifikasi status tahapan rollout tercatat di log rilis."
            ],
            out_of_scope=[
                "Pengembangan fitur fase 3 (M8)."
            ],
            aturan_ketat=[
                "Staged rollout WAJIB bertahap 1% -> 5% -> 20% -> 50% -> 100% (§11.6).",
                "Jika crash-free sessions < 99,5% atau sync success turun, rollout WAJIB DIHENTIKAN SEKETIKA (§11.6)."
            ],
            labels=["M6: Rilis v1", "size:S", "area:security-ops"]
        )
    ]
