# NihonPath — Rancangan Teknis Aplikasi Belajar Bahasa Jepang (N5–N1)

Versi 1.0 · Nama kerja produk: NihonPath · Bahasa dokumen: Indonesia (istilah teknis tetap Inggris)

Dokumen ini terdiri dari 4 bagian berurutan: (A) §0–5 fondasi, pedagogi, kurikulum, arsitektur, Flutter; (B) §6–9 data, sinkronisasi, API, content pipeline; (C) §10–14 observability, reliability, keamanan, billing, DevOps; (D) §15–17 roadmap, task breakdown, risiko, lampiran.

## 0. Cara Membaca Dokumen Ini (WAJIB untuk implementer)

Dokumen ini ditulis agar bisa dieksekusi oleh model/engineer yang tidak mengambil keputusan arsitektur sendiri. Aturan:

1. Dokumen ini adalah sumber kebenaran. Jika ada hal yang ambigu, pilih opsi paling sederhana yang konsisten dengan dokumen, catat di `docs/decision-log.md` (format: tanggal, konteks, keputusan, alasan), lalu lanjutkan. Jangan mengubah arsitektur secara diam-diam.
2. Contract-first: tulis dan commit `contracts/openapi.yaml` dan JSON Schema konten SEBELUM menulis kode yang memakainya. Klien Dart dan tipe TypeScript dihasilkan dari kontrak, bukan ditulis tangan.
3. Kerjakan berdasarkan Task ID di §15. Satu task = satu PR kecil (kurang dari ±400 baris diff, di luar file hasil generate).
4. Definition of Done (DoD) setiap task: kode + unit test lulus + lint/format lulus + log/metric/trace sesuai §10 + dokumentasi singkat diperbarui + tidak ada TODO tanpa nomor issue.
5. DILARANG: menambah dependency di luar daftar tanpa catatan keputusan; menyalin konten berhak cipta/proprietary (WaniKani, Duolingo, Genki, Minna no Nihongo, soal resmi JLPT, dsb.); membuat kriptografi sendiri; menyimpan secret di repo; mencatat PII (email, token, isi jawaban bebas) ke log; memakai `DateTime.now()` atau `Date.now()` langsung di logika bisnis (gunakan interface `Clock`).
6. Versi paket: gunakan versi stabil terbaru saat implementasi, lalu pin (lockfile di-commit). Baca changelog sebelum upgrade mayor. Angka versi di dokumen ini sengaja tidak ditulis agar tidak usang.
7. Jika keamanan/privasi bertentangan dengan kemudahan, keamanan/privasi menang.
8. Jika spesifikasi tidak bisa dipenuhi (misal paket tidak ada), jangan berimprovisasi diam-diam: tulis opsi B yang sudah disiapkan di dokumen ini, atau catat blocker di decision log dan kerjakan task lain.

## 1. Ringkasan Produk

**Visi.** Aplikasi mobile yang membawa pelajar dari nol (kana) hingga kesiapan JLPT N1 dengan metode yang berbasis bukti: spaced repetition, retrieval practice, input bermakna, dan latihan output, dengan pengalaman offline-first.

**Target pengguna.** Pelajar Indonesia (utama) dan internasional. UI dwibahasa (Indonesia, Inggris); penjelasan tata bahasa dalam Indonesia dan Inggris.

**Platform.** Android dan iOS (Flutter). Tidak ada web app pada fase awal.

**Goals (MVP → v1):**

- Kurikulum Level 0 (Kana) dan N5 sampai N1 yang berurutan, dengan SRS untuk kosakata, kanji, dan tata bahasa.
- Latihan membaca dan mendengar bertingkat, serta mock test bergaya JLPT.
- Berfungsi penuh tanpa internet setelah paket konten diunduh; sinkron antar-perangkat.
- Observability dan reliability kelas produksi sejak hari pertama.

**Non-goals (MVP):** fitur sosial/leaderboard, penilaian ucapan real-time, konten buatan pengguna, LLM saat runtime, aplikasi web, pembayaran selain IAP store.

**Non-functional requirements (NFR) yang mengikat:**

| Area | Target |
| --- | --- |
| Cold start (mid-range Android) | kurang dari 2,0 s sampai layar Home |
| Transisi kartu review | kurang dari 100 ms, 60 fps tanpa jank |
| Offline | seluruh sesi review, pelajaran, dan mock test yang sudah diunduh bekerja tanpa jaringan |
| Ketersediaan API | SLO 99,9% per bulan |
| Latensi sync push (server) | p95 kurang dari 500 ms, p99 kurang dari 1,5 s |
| Crash-free sessions | di atas 99,5% |
| Kehilangan data review | 0 (review log append-only, idempoten, dengan outbox durable) |
| Ukuran unduhan awal | APK/IPA kurang dari 40 MB; paket konten diunduh terpisah per level |
| Skala desain | nyaman di 100 ribu MAU, tanpa re-arsitektur sampai 1 juta MAU (lihat §11) |

## 2. Fondasi Pedagogi (hasil riset dan cara menerapkannya)

| Prinsip | Kekuatan bukti | Penerapan di produk |
| --- | --- | --- |
| Distributed practice (spacing effect) | Kuat. Meta-analisis Cepeda dkk. 2006; Dunlosky dkk. 2013 menilai utilitas tinggi | Semua kartu vocab/kanji/grammar dijadwalkan SRS |
| Retrieval practice (testing effect) | Kuat. Roediger dan Karpicke 2006; Dunlosky dkk. 2013 | Kartu selalu meminta recall aktif; kuis langsung setelah materi baru; tidak ada mode baca-saja untuk hafalan |
| Penjadwalan berbasis data (FSRS, model DSR) | Benchmark open-spaced-repetition pada data review skala besar menunjukkan prediksi lebih akurat daripada SM-2 | FSRS-6 (21 parameter), desired retention default 0,90 |
| Four strands (Nation 2007): meaning-focused input, meaning-focused output, language-focused learning, fluency | Kerangka yang diterima luas di pengajaran bahasa | Rencana harian seimbang: SRS + pelajaran baru + membaca/mendengar + produksi |
| Extensive reading / comprehensible input | Sedang-kuat untuk membaca (meta-analisis Nakanishi 2015); hipotesis i+1 Krashen masih diperdebatkan | Bacaan bertingkat dengan gloss ketuk; kontrol cakupan kata dikenal sekitar 95–98% |
| Frekuensi dan lexical coverage (Nation) | Kuat untuk prioritas kosakata | Urutan kata berdasarkan level JLPT lalu frekuensi |
| Elaborative encoding (keyword/mnemonic, dual coding) | Sedang; efektif untuk pembelajaran awal (Atkinson dan Raugh 1975) | Dekomposisi komponen kanji, mnemonik singkat, ilustrasi; tetap diikuti SRS |
| Interleaving / desirable difficulties | Sedang; bukti dominan dari matematika/motorik, hasil bahasa campuran | Pencampuran ringan tipe kartu; tidak dipaksakan |
| Pelatihan fonetik variabilitas tinggi (pitch accent, Hirata 2004) | Sedang | Audio dari 2 suara atau lebih, pitch accent ditampilkan, latihan shadowing |
| Output dan feedback (Swain) | Sedang | Mengetik jawaban, menyusun kalimat, menulis kanji dengan tangan, feedback instan dengan penjelasan |
| Penetapan tujuan dan kebiasaan | Sedang-lemah | Target harian kecil, streak dengan freeze; TANPA dark pattern |

**Catatan kejujuran (wajib dipatuhi tim produk dan marketing).** Bukti terkuat ada pada spacing dan retrieval. Fitur lain adalah hipotesis yang wajib diukur sendiri lewat A/B test dan metrik retensi (§10.6). Jangan mengklaim peluang lulus JLPT tanpa data. Referensi di atas ditulis dari pengetahuan peneliti dan harus diverifikasi ulang sebelum dikutip di materi publik.

**Konfigurasi FSRS yang diwajibkan:** desired\_retention default 0.90 (pilihan pengguna: 0.85 Santai, 0.90 Standar, 0.95 Ketat); maximum\_interval 365 hari (konteks ujian); fuzz aktif dengan seed deterministik (hash dari card\_id dan reps) agar replay deterministik; short-term scheduling aktif dengan learning\_steps 1m dan 10m, relearning\_steps 10m.

## 3. Kurikulum dan Model Konten

### 3.1 Cakupan per level (perkiraan kumulatif)

JLPT tidak lagi merilis daftar resmi sejak 2010; angka berikut adalah estimasi umum komunitas dan dipakai sebagai target kerja. Content lead memfinalkan silabus.

| Level | Kosakata (kumulatif) | Kanji (kumulatif) | Fokus |
| --- | --- | --- | --- |
| 0 Kana | n/a | n/a | Hiragana, katakana, dakuten, yoon, mora, penulisan tangan |
| N5 | sekitar 800 | sekitar 100 | Salam, angka, waktu, kalimat dasar, partikel dasar |
| N4 | sekitar 1.500 | sekitar 300 | Bentuk te/ta/nai, kondisional dasar, keigo dasar |
| N3 | sekitar 3.750 | sekitar 650 | Teks sehari-hari, ekspresi kausatif/pasif, nuansa |
| N2 | sekitar 6.000 | sekitar 1.000 | Teks umum dan berita, bahasa formal, kolokasi |
| N1 | sekitar 10.000 | sekitar 2.000 | Teks abstrak, ekspresi sastra/formal, nuansa halus |

### 3.2 Sumber data dan lisensi (LEGAL REVIEW wajib sebelum rilis)

| Sumber | Dipakai untuk | Lisensi (verifikasi ulang) |
| --- | --- | --- |
| JMdict (EDRDG) | Arti, bacaan, kelas kata | CC BY-SA 4.0 |
| KANJIDIC2 (EDRDG) | Makna, on/kun, jumlah goresan | CC BY-SA 4.0 |
| KanjiVG | Urutan goresan (SVG) | CC BY-SA 3.0 |
| Tatoeba | Kalimat contoh | CC BY 2.0 FR (sebagian CC0) |
| Daftar level JLPT komunitas (mis. Tanos) | Pemetaan level | CC BY, tidak resmi |
| Data pitch accent komunitas (mis. Kanjium) | Aksen nada | Lisensi tidak pasti: verifikasi dulu; jika tidak jelas, tandai fitur ditunda |
| Sudachi/UniDic | Tokenisasi saat build (bukan runtime) | Apache 2.0 / BSD |
| TTS cloud (Google, Azure, Amazon) | Audio pra-render | Periksa ToS terkait caching dan redistribusi audio di dalam aplikasi |

Implikasi CC BY-SA: dataset turunan harus diberi atribusi dan dibagikan dengan lisensi sama. Halaman Atribusi di aplikasi wajib. Konsultasikan dengan penasihat hukum mengenai pemisahan dataset konten dari kode aplikasi.

Konten yang dihasilkan LLM (penjelasan tata bahasa, mnemonik, bacaan, soal) hanya boleh dibuat di content pipeline (offline), WAJIB direview manusia (reviewer level N2 atau lebih), dan dilacak dengan field `provenance` (lihat §9). Tidak ada generasi LLM saat runtime di MVP.

### 3.3 Hierarki konten

`Level (0,N5..N1) → Unit (tema) → Lesson (5–8 menit) → ContentItem`.

- Satu Unit mencakup tema (misal Perkenalan Diri) dan berisi: Lesson Kosakata (8 item), Lesson Kanji (4 item, kanji yang muncul di kosakata unit tersebut), Lesson Tata Bahasa (2 pola), 1 Reading, 1 Listening.
- Prinsip kanji-in-context: kanji diajarkan setelah kata yang memakainya diperkenalkan.
- Item kana (Level 0) memakai audio dan latihan menulis tangan.

### 3.4 Tipe item dan facet kartu

Satu kartu SRS = satu item × satu facet. `card_id = UUIDv5(NAMESPACE_CARD, item_external_key + ':' + facet)`. Deterministik dan sama di semua perangkat, sehingga tidak ada duplikasi.

| Tipe item | Facet MVP | Bentuk soal |
| --- | --- | --- |
| vocab | `recognition` (JP→arti), `recall` (arti→JP) | Pilihan ganda (awal), ketik/pilih kana-kanji (lanjut); audio otomatis |
| kanji | `meaning`, `reading` | Pilih makna; ketik bacaan dalam konteks kata |
| grammar | `cloze` | Isi rumpang dalam kalimat, susun kalimat |
| kana | `recognition`, `writing` | Pilih romaji/suara; tulis dengan tangan |

Facet ditunda ke fase 2: `listening` (audio→arti), `writing` kanji, `production` tata bahasa.

### 3.5 Alur pelajaran

1. **Perkenalan** (3–5 item per layar): item + audio + contoh kalimat + mnemonik. Pengguna mengetuk Lanjut.
2. **Kuis langsung** (retrieval): setiap item baru ditanyakan sampai benar sekali. Ini memicu kartu pertama.
3. **Masuk SRS**: tiap jawaban kuis dicatat sebagai review log pertama; kartu berstatus Learning dengan jadwal dari FSRS.
4. **Ringkasan**: item yang dipelajari, akurasi, estimasi beban review esok hari.

### 3.6 Rencana harian dan pembentukan antrean

Urutan Home: (1) Review jatuh tempo, (2) Pelajaran baru, (3) Latihan baca/dengar, (4) opsional: drill khusus.

```
buildQueue(now, settings):
  dayEnd = akhir hari lokal pengguna, pergantian hari jam 04:00
  learning = kartu Learning/Relearning dengan due <= now + 20 menit   # selalu pertama
  reviews  = kartu Review dengan due <= dayEnd, urut retrievability ASC,
             dibatasi settings.max_reviews_per_day (default 200)
  newGate  = (jumlah reviews terjatuh tempo) < settings.new_gate (default 100)
  newCards = newGate ? min(settings.new_per_day - introducedToday, sisaKuota) : 0
             # new_per_day default 10, rentang 0..30; diambil dari lesson berikutnya sesuai urutan kurikulum
  interleave: 1 kartu baru per 4 review; kartu dari item yang sama berjarak minimal 3 kartu;
              sibling (facet lain dari item sama) di-bury sampai besok setelah salah satu dijawab
```

**Mapping rating:** salah = Again(1); benar tetapi memakai hint atau lebih lambat dari ambang waktu per tipe soal = Hard(2); benar = Good(3); tombol opsional Mudah setelah benar = Easy(4). Kartu bergaya flashcard memakai 4 tombol langsung.

**Leech:** lapses 8 atau lebih → kartu otomatis ditangguhkan (suspended), pengguna ditawari mnemonik alternatif atau latihan khusus, lalu bisa diaktifkan lagi.

### 3.7 Skill lain

- **Reading:** bacaan pendek (N5: 50–150 karakter; naik bertahap). Teks sudah ditokenisasi saat build; ketuk kata menampilkan arti dan furigana; ada metrik cakupan kata dikenal per pengguna.
- **Listening:** audio multi-suara, kecepatan 0,75x/1x, pertanyaan pemahaman gaya 聴解, transkrip dibuka setelah menjawab.
- **Mock test:** struktur dan waktu menyerupai JLPT (文字・語彙・文法, 読解, 聴解). Skor resmi JLPT memakai skala terekuivalensi; aplikasi hanya menampilkan estimasi persentase dengan disclaimer jelas.

## 4. Arsitektur Sistem

### 4.1 Diagram

```
Flutter App (Android/iOS)
 ├─ UI (Riverpod, go_router)
 ├─ Domain (SRS engine, queue builder, test engine)
 ├─ Data: SQLite (Drift) ◄─ Outbox ─► SyncClient ──HTTPS──┐
 └─ Content packs (zip) ◄──────────── CDN ◄─ Object Storage
                                                           │
CDN/WAF ─► Load Balancer ─► API (NestJS, stateless xN) ────┼─► PostgreSQL (primary + read replica)
                                   │                       ├─► Redis (rate limit, cache, BullMQ)
                                   └─► Worker (BullMQ) ─────┴─► Object Storage (packs, audio)

Observability: OpenTelemetry Collector → Prometheus/Loki/Tempo → Grafana + Alertmanager; Sentry
Content pipeline: Git repo konten + CLI + CI → publish → Postgres + packs + audio
```

### 4.2 Pilihan teknologi (dan alasan)

| Lapisan | Pilihan | Alasan | Cadangan |
| --- | --- | --- | --- |
| Mobile | Flutter stable terbaru, Dart 3, Forui (preset ajeneb), Riverpod, go\_router | Satu codebase; state mudah diuji | Bloc |
| DB lokal | Drift di atas SQLite | Query typed, migrasi, stream reaktif | sqflite |
| Backend | Node.js LTS aktif, TypeScript strict, NestJS (adapter Fastify) | Ekosistem luas, struktur modul jelas, mudah ditulis model | Go |
| Bentuk deploy | Modular monolith + 1 worker | Hindari kompleksitas microservice; modul punya batas jelas sehingga bisa dipisah | n/a |
| Database | PostgreSQL (versi mayor stabil terbaru yang didukung provider, minimal 16) | Transaksional, JSONB, partisi | n/a |
| Query/migrasi | Kysely + migrasi SQL murni (node-pg-migrate) | Type-safe tanpa magic ORM; mendukung partisi | Drizzle |
| Cache/queue | Redis + BullMQ | Rate limit, job async | n/a |
| Object storage + CDN | S3-compatible + Cloudflare/CloudFront | Paket konten dan audio | n/a |
| Auth | JWT buatan backend + verifikasi OIDC Google/Apple + email OTP | Tanpa lock-in; guest mode; Apple Sign In wajib jika ada login sosial di iOS | Firebase Auth |
| Observability | OpenTelemetry → Grafana stack; Sentry untuk error mobile dan backend | Standar terbuka | Datadog |
| Analitik produk | PostHog (cloud region EU/US atau self-host) | Funnel, eksperimen | Firebase Analytics |
| IaC | Terraform; container (Cloud Run/ECS/Kubernetes terkelola) | Reproducible | n/a |
| Region | Jakarta (AWS ap-southeast-3 atau GCP asia-southeast2) | Latensi untuk pengguna Indonesia | Singapura |

### 4.3 Prinsip arsitektur (wajib)

1. **Offline-first:** UI hanya membaca/menulis SQLite lokal. Jaringan hanya dipakai oleh SyncClient dan pengunduh paket.
2. **Review log append-only dan idempoten:** ID dibuat klien (UUIDv7); server memakai `ON CONFLICT DO NOTHING`.
3. **Stateless API:** tidak ada state sesi di memori; mudah diskalakan horizontal.
4. **Konten read-mostly:** konten dikirim sebagai paket versi-ed lewat CDN, bukan lewat API per-item.
5. **Semua operasi tulis idempoten dan aman di-retry** (backoff eksponensial + jitter).
6. **Degradasi anggun:** jika backend turun, aplikasi tetap bisa belajar penuh; sync menunggu.
7. **Config dan feature flag dari server** (cache lokal dengan TTL) untuk kill-switch fitur.

## 5. Aplikasi Flutter

### 5.1 Struktur proyek (feature-first)

```
lib/
  main.dart, app.dart
  core/        # clock, id_generator, logger, result, errors, env, telemetry
  data/        # drift db, DAO, outbox, sync_client, content_pack_manager, api (generated)
  domain/      # entities, srs/ (scheduler, queue_builder), tests/ (mock test engine)
  features/
    onboarding/  home/  lesson/  review/  kana/  kanji/  grammar/
    reading/  listening/  mocktest/  progress/  settings/  paywall/  auth/
  l10n/        # arb: id, en
  ui/          # widgets/ komponen kustom di atas Forui (JpText, ReviewCard); tema ada di lib/theme/ (hasil CLI Forui)
test/ integration_test/ contracts/ (symlink ke repo kontrak)
```

Aturan lapisan: `features/*` → `domain` → `data`. UI tidak boleh mengimpor Drift/dio langsung; selalu lewat repository. Semua waktu lewat `Clock`, semua ID lewat `IdGenerator`, sehingga logika SRS dapat diuji deterministik.

### 5.2 Paket yang diizinkan

forui (UI library, lihat §5.2.1), flutter\_riverpod (+riverpod\_generator), go\_router, drift (+sqlite3\_flutter\_libs, drift\_dev), dio, freezed, json\_serializable, build\_runner, uuid (UUIDv7 dan v5), just\_audio + audio\_session, flutter\_secure\_storage, workmanager, connectivity\_plus, flutter\_local\_notifications, sentry\_flutter, in\_app\_purchase (atau purchases\_flutter jika RevenueCat dipilih di §13), google\_mlkit\_digital\_ink\_recognition, flutter\_svg, intl, archive (unzip paket), crypto (verifikasi SHA-256), mocktail, integration\_test, alchemist (golden test), package `fsrs` resmi dari organisasi open-spaced-repetition di pub.dev.

### 5.2.1 UI library: Forui (preset ajeneb)

**Keputusan (mengikat):** UI memakai Forui (forui.dev), library UI Flutter minimalis yang terinspirasi shadcn/ui, dengan tema dari preset `ajeneb`. Bagian ini menggantikan semua rujukan ke design system kustom atau Material sebagai basis UI. Forui bersifat platform-agnostic, mengutamakan sentuhan, dan dapat dipakai berdampingan dengan widget Material/Cupertino.

**Perintah setup (jalankan sekali di `apps/mobile`):**

```
flutter pub add forui
dart run forui init --preset ajeneb --template=router
```

`--preset` menerima kode tema (theme code), jadi `ajeneb` adalah kode tema yang dipilih pemilik produk. Perintah ini membuat `forui.yaml`, `lib/theme/` (theme.dart, colors.dart, typography.dart, style.dart, icons.dart), dan `main.dart` dengan `MaterialApp.router`. Hanya tema saja: `dart run forui theme create --preset ajeneb`.

**Catatan penting untuk implementer:**

- Saya tidak dapat memverifikasi tampilan tema `ajeneb` (warna, radius, font). Setelah perintah dijalankan, catat hasilnya di `docs/decision-log.md` (nilai warna inti, radius, font bawaan) dan simpan tangkapan layar terang dan gelap. Jika kode ditolak CLI, JANGAN mengarang tema: catat blocker dan lanjutkan dengan `FTheme.neutral`.
- Versi: Forui terbaru mensyaratkan Flutter 3.44 atau lebih baru dan CLI-nya Dart 3.12 atau lebih baru (periksa persyaratan di forui.dev saat implementasi). Gunakan impor yang dihasilkan template `forui init` (paket Material kini bisa berupa `material_ui`), bukan impor dari ingatan.
- Forui masih di bawah 1.0: versi minor bisa memuat breaking change. Pin versi di `pubspec.lock`, baca changelog, jalankan `dart fix --apply` saat upgrade.
- Dokumentasi mesin-terbaca untuk model: forui.dev/docs/llms.txt (indeks) dan forui.dev/docs/llms-full.txt (lengkap dengan contoh kode). Rujuk ini untuk nama widget dan parameter, bukan menebak.

**Kerangka aplikasi (app.dart), menyatukan Forui + go\_router + Riverpod:**

```dart
final lt = lightTheme;   // dari lib/theme/theme.dart (hasil CLI)
final dt = darkTheme;

MaterialApp.router(
  supportedLocales: FLocalizations.supportedLocales,
  localizationsDelegates: [...FLocalizations.localizationsDelegates, AppLocalizations.delegate],
  theme: lt.toApproximateMaterialTheme(),
  darkTheme: dt.toApproximateMaterialTheme(),
  builder: (context, child) => FTheme(
    data: Theme.brightnessOf(context) == Brightness.light ? lt : dt,
    child: FToaster(child: FTooltipGroup(child: child!)),
  ),
  routerConfig: ref.watch(routerProvider),
);
```

**Aturan penggunaan (wajib):**

1. Semua UI baru memakai widget Forui (`FScaffold`, `FButton`, `FCard`, dan seterusnya). Widget Material hanya jika Forui tidak punya padanan, dengan catatan di decision log.
2. Warna, tipografi, radius, dan spasi hanya lewat `context.theme.colors`, `.typography`, `.style`. Dilarang menulis `Color(0x...)`, `fontSize`, atau `BorderRadius` angka mentah di kode fitur.
3. Token khusus aplikasi (warna rating Again/Hard/Good/Easy, warna furigana, warna benar/salah) dibuat sebagai `ThemeExtension` (`AppColors`, `AppStyle`) di `lib/theme/`, diakses lewat `context.theme.colors.app`.
4. Jangan menjalankan ulang `forui init` atau `forui theme create` dengan `--force` setelah ada modifikasi manual; itu menimpa file.
5. Font Jepang: ubah `_display` dan `_body` di `typography.dart` agar memakai Noto Sans JP hasil subset (§5.5) sebagai `fontFamily`, dengan `fontFamilyFallback` ke font sistem. Tinggi baris diuji dengan teks kanji dan furigana.
6. Ikon: `FLucideIcons` (Lucide, sudah termasuk dalam paket forui); periksa lisensi Lucide untuk halaman Atribusi. `flutter_svg` tetap dipakai untuk goresan KanjiVG.
7. Varian `touch` dipakai (aplikasi mobile saja); mode terang dan gelap mengikuti sistem.
8. Widget kustom ditaruh di `lib/ui/widgets/`, dibangun dari token tema, dan wajib punya golden test terang dan gelap, dengan `FTheme` membungkus widget uji.
9. Efek animasi mengikuti motion bawaan Forui; tidak menambah library animasi.

**Pemetaan kebutuhan ke widget:**

| Kebutuhan | Widget Forui | Catatan |
| --- | --- | --- |
| Kerangka layar | `FScaffold` | Navigasi bawah dan header: cek nama widget di dokumentasi |
| Tombol, tombol rating review | `FButton` (varian primary, secondary, outline, destructive) | Warna rating lewat token `AppColors` |
| Kartu pelajaran, ringkasan | `FCard` |  |
| Daftar pelajaran, pengaturan, perpustakaan | `FItemGroup` dan `FItem` | Mendukung scroll lazy (`FItemGroup.builder`) |
| Label level N5–N1, status | `FBadge` |  |
| Penjelasan tata bahasa | `FAccordion` |  |
| Kalender streak | `FLineCalendar` atau `FCalendar` (mode tampilan saja) |  |
| Input jawaban ketik | `FTextField` | Jangan evaluasi saat IME masih composing (§16.3) |
| Notifikasi singkat | `FToaster` |  |
| Avatar profil | `FAvatar` |  |

**Komponen kustom (tidak ada di Forui):** `JpText` (furigana), `ReviewCard` (tampilan soal dan jawaban), `HandwritingCanvas`, `StrokeOrderPlayer`, `AudioButton`, `ForecastBars` (grafik batang sederhana dengan `CustomPainter`, tanpa library grafik baru), `PackDownloadTile`.

**Dampak pada task (§15):** M3-1 diperluas: jalankan setup Forui di atas, integrasikan `routerProvider` go\_router, dan buat `AppColors` dengan token rating. Setiap task layar M3–M6 memakai widget sesuai tabel di atas. Tambahkan golden test terang dan gelap untuk `JpText` dan `ReviewCard`.

**Risiko:** Forui pre-1.0 (breaking change antar-minor) dan tema `ajeneb` yang belum terverifikasi. Mitigasi: pin versi, bungkus widget yang sering dipakai di `lib/ui/widgets/` agar perubahan API terisolasi, dan tinjau tangkapan layar tema sebelum M3-6 dimulai.

### 5.3 Daftar layar

| Route | Layar | Catatan |
| --- | --- | --- |
| /onboarding | Pilih target level, tes penempatan singkat (opsional), target harian | Guest mode tanpa daftar |
| /home | Rencana harian, streak, tombol Mulai | Baca dari SQLite |
| /review | Sesi review | Antrean dari queue\_builder |
| /lesson/:id | Perkenalan → kuis → ringkasan |  |
| /kana | Tabel kana + latihan tulis |  |
| /library | Telusuri kosakata/kanji/grammar per level | Pencarian lokal FTS5 |
| /reading/:id, /listening/:id | Latihan bertingkat |  |
| /mocktest/:id | Ujian bergaya JLPT dengan timer |  |
| /progress | Statistik retensi, forecast beban review, riwayat |  |
| /settings | Retention, kuota baru, notifikasi, akun, data | Hapus akun wajib ada (kebijakan store) |
| /paywall | Langganan | Lihat §13 |

### 5.4 SRS engine di klien (domain/srs)

- Definisikan interface `Scheduler { ReviewResult review(CardState, Rating, DateTime now); }` agar implementasi dapat diganti.
- Implementasi utama: package Dart `fsrs` resmi. WAJIB verifikasi bahwa versinya mengimplementasikan FSRS-6 (21 parameter). **Opsi B** bila tidak memenuhi: bungkus `fsrs-rs` (Rust) lewat flutter\_rust\_bridge. Catat pilihan di decision log.
- **Golden test wajib:** hasilkan vektor uji dari implementasi referensi (ts-fsrs) berupa rangkaian rating dan keluaran yang diharapkan (state, stability, difficulty, due) untuk minimal 50 skenario; tes Dart membandingkan dengan toleransi 1e-6 (interval hari harus identik).
- Parameter FSRS disimpan di `user_settings.fsrs_params` (default bawaan paket). Personalisasi (optimizer) ditunda ke fase 3 dan berjalan di server (§15).
- Setiap review: (1) hitung state baru, (2) tulis `review_logs` + update `user_cards` + insert `outbox` dalam SATU transaksi SQLite, (3) picu sync tertunda (debounce 5 detik, atau saat sesi selesai).
- Kartu yang jatuh tempo dalam sesi berjalan (learning steps) dimasukkan ulang ke antrean in-memory.

### 5.5 Audio, furigana, tulisan tangan, font

- **Audio:** pra-render dengan TTS saraf, minimal 2 suara (laki-laki dan perempuan), format Opus/AAC 32–48 kbps, disimpan di paket konten. Pemutaran dengan just\_audio; preload audio kartu berikutnya.
- **Furigana:** widget `JpText` menerima segmen `[{t: 漢字, r: かんじ}]` dari data (tidak menghitung bacaan saat runtime); pengaturan Furigana: selalu / hanya kanji di atas level pengguna / tidak.
- **Tulisan tangan:** ML Kit Digital Ink Recognition (model bahasa ja diunduh sekali, on-device); animasi urutan goresan dari KanjiVG.
- **Font:** bundel Noto Sans JP yang di-subset (kana + kanji sampai N1 + tanda baca) memakai pyftsubset agar ukuran kecil dan tampilan konsisten.
- **Pencarian:** SQLite FTS5 pada kolom kana, kanji, romaji, dan arti.

### 5.6 Performa, aksesibilitas, lokalisasi

- Query review memakai indeks `(state, due)`; jangan memuat seluruh tabel kartu ke memori. Gambar/animasi ringan; hindari rebuild tidak perlu (select pada provider).
- Aksesibilitas: semantic label, dukung ukuran font sistem hingga 200%, kontras WCAG AA, dukung mode gelap, target sentuh minimal 48 dp.
- Lokalisasi: ARB id dan en; teks penjelasan konten dwibahasa tersimpan di data konten.

### 5.7 Strategi pengujian klien

| Jenis | Cakupan minimum |
| --- | --- |
| Unit | queue\_builder, mapping rating, sync merge, outbox, parser paket (cakupan baris domain di atas 85%) |
| Widget/golden | JpText (furigana), kartu review, layar pelajaran, mode gelap dan teks besar |
| Integration | Alur: onboarding → pelajaran → review → mode pesawat → sync pulih |
| Fault injection | Putus koneksi saat sync, 500 acak, respons lambat, paket konten korup |
| Performa | Profil cold start dan transisi kartu di perangkat Android kelas menengah, dijalankan di CI mingguan |

## 6. Model Data

### 6.1 Konvensi

- ID: UUIDv7 (dibuat klien untuk data pengguna). `card_id` memakai UUIDv5 (§3.4). Konten memakai `external_key` stabil, misal `vocab:jmdict:1358280`, `kanji:漢`, `grammar:n5:です`.
- Waktu: UTC, ISO-8601 dengan milidetik di API; `timestamptz` di Postgres; integer epoch ms di SQLite.
- `jlpt_level`: 0 = Kana, 5 = N5, 4 = N4, 3 = N3, 2 = N2, 1 = N1. Urutan belajar: 0, 5, 4, 3, 2, 1.
- `state` kartu: 0 New, 1 Learning, 2 Review, 3 Relearning. `rating`: 1 Again, 2 Hard, 3 Good, 4 Easy.
- Tidak ada hard delete pada data pengguna kecuali lewat penghapusan akun (§12).

### 6.2 Skema SQLite klien (Drift)

| Tabel | Kolom penting | Catatan |
| --- | --- | --- |
| content\_items | id, external\_key (unik), type, jlpt\_level, payload\_json, content\_version | Diisi dari paket konten |
| lessons, lesson\_items | id, level, unit\_no, lesson\_no, kind, title\_json; (lesson\_id, item\_id, position) |  |
| fts\_items | FTS5 atas kana, kanji, romaji, arti | Dibangun saat paket dipasang |
| user\_cards | card\_id (PK), item\_external\_key, facet, state, due, stability, difficulty, elapsed\_days, scheduled\_days, reps, lapses, step, last\_review\_at, suspended, buried\_until, updated\_at | Indeks (state, due) dan (item\_external\_key) |
| review\_logs | id (PK), card\_id, rating, state\_before, reviewed\_at, duration\_ms, scheduled\_days, elapsed\_days, stability\_before, difficulty\_before, exercise\_type | Append-only; tidak pernah diubah |
| user\_settings | id=1, data\_json, version, updated\_at | Retention, kuota, furigana, FSRS params |
| lesson\_progress | lesson\_id (PK), status, best\_score, completed\_at, updated\_at |  |
| test\_attempts | id, test\_id, started\_at, finished\_at, score\_json |  |
| outbox | op\_id (PK), type, payload\_json, created\_at, attempts, next\_attempt\_at, last\_error | Antrean sync durable |
| sync\_state | key (PK), value | Kunci: device\_id, pull\_cursor, last\_sync\_at, clock\_offset\_ms |
| pack\_state | pack\_id, kind, level, version, sha256, installed\_at |  |

### 6.3 Skema PostgreSQL (migrasi SQL murni, urut)

```sql
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
  id uuid PRIMARY KEY,
  email citext UNIQUE,
  email_verified_at timestamptz,
  display_name text,
  locale text NOT NULL DEFAULT 'id' CHECK (locale IN ('id','en')),
  timezone text NOT NULL DEFAULT 'Asia/Jakarta',
  target_level smallint CHECK (target_level BETWEEN 1 AND 5),
  is_guest boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);
CREATE TABLE auth_identities (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider text NOT NULL CHECK (provider IN ('google','apple','email')),
  provider_subject text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_subject)
);
CREATE TABLE devices (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform text NOT NULL, app_version text, os_version text,
  push_token text, last_seen_at timestamptz
);
CREATE TABLE refresh_tokens (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id uuid NOT NULL, family_id uuid NOT NULL,
  token_hash bytea NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL, revoked_at timestamptz, replaced_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON refresh_tokens (user_id, family_id);

-- Konten (read-mostly)
CREATE TABLE content_items (
  id uuid PRIMARY KEY,
  external_key text NOT NULL UNIQUE,
  type text NOT NULL CHECK (type IN ('vocab','kanji','grammar','kana','sentence','passage','listening','test')),
  jlpt_level smallint NOT NULL CHECK (jlpt_level BETWEEN 0 AND 5),
  payload jsonb NOT NULL,
  content_version int NOT NULL,
  status text NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published','retired')),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON content_items (jlpt_level, type);
CREATE TABLE lessons (
  id uuid PRIMARY KEY, jlpt_level smallint NOT NULL, unit_no int NOT NULL, lesson_no int NOT NULL,
  kind text NOT NULL, title jsonb NOT NULL,
  UNIQUE (jlpt_level, unit_no, lesson_no, kind)
);
CREATE TABLE lesson_items (
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  item_id uuid NOT NULL REFERENCES content_items(id),
  position int NOT NULL, PRIMARY KEY (lesson_id, position)
);
CREATE TABLE content_packs (
  id uuid PRIMARY KEY, jlpt_level smallint NOT NULL,
  kind text NOT NULL CHECK (kind IN ('core','audio','strokes','passages','tests')),
  version int NOT NULL, sha256 text NOT NULL, size_bytes bigint NOT NULL,
  storage_key text NOT NULL, min_app_version text NOT NULL,
  is_premium boolean NOT NULL DEFAULT false, published_at timestamptz,
  UNIQUE (jlpt_level, kind, version)
);

-- Data pengguna
CREATE TABLE user_sync_state (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  last_seq bigint NOT NULL DEFAULT 0
);
CREATE TABLE user_cards (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  card_id uuid NOT NULL,
  item_external_key text NOT NULL, facet text NOT NULL,
  state smallint NOT NULL CHECK (state BETWEEN 0 AND 3),
  due timestamptz NOT NULL, stability real NOT NULL, difficulty real NOT NULL,
  elapsed_days int NOT NULL DEFAULT 0, scheduled_days int NOT NULL DEFAULT 0,
  reps int NOT NULL, lapses int NOT NULL, step smallint,
  last_review_at timestamptz,
  suspended boolean NOT NULL DEFAULT false, buried_until date,
  updated_at timestamptz NOT NULL,
  user_seq bigint NOT NULL, origin_device_id uuid NOT NULL,
  PRIMARY KEY (user_id, card_id)
);
CREATE INDEX ON user_cards (user_id, user_seq);

CREATE TABLE review_logs (
  user_id uuid NOT NULL, id uuid NOT NULL, card_id uuid NOT NULL,
  rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 4),
  state_before smallint NOT NULL, reviewed_at timestamptz NOT NULL,
  duration_ms int, scheduled_days int, elapsed_days int,
  stability_before real, difficulty_before real, exercise_type text,
  device_id uuid NOT NULL, user_seq bigint NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, reviewed_at, id)
) PARTITION BY RANGE (reviewed_at);
CREATE INDEX ON review_logs (user_id, user_seq);
CREATE INDEX ON review_logs (user_id, card_id, reviewed_at);

CREATE TABLE user_settings (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  data jsonb NOT NULL, version int NOT NULL, updated_at timestamptz NOT NULL, user_seq bigint NOT NULL
);
CREATE TABLE lesson_progress (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_key text NOT NULL, status text NOT NULL, best_score real, completed_at timestamptz,
  updated_at timestamptz NOT NULL, user_seq bigint NOT NULL,
  PRIMARY KEY (user_id, lesson_key)
);
CREATE TABLE test_attempts (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id uuid NOT NULL, test_key text NOT NULL, started_at timestamptz NOT NULL,
  finished_at timestamptz, score jsonb, user_seq bigint NOT NULL,
  PRIMARY KEY (user_id, id)
);
CREATE TABLE subscriptions (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform text NOT NULL CHECK (platform IN ('apple','google')),
  product_id text NOT NULL, original_txn_id text NOT NULL,
  status text NOT NULL, expires_at timestamptz, last_verified_at timestamptz,
  PRIMARY KEY (platform, original_txn_id)
);
```

**Manajemen partisi:** partisi bulanan `review_logs_YYYY_MM`. Job terjadwal membuat partisi 3 bulan ke depan (atau pg\_partman bila tersedia di provider) dan satu partisi DEFAULT sebagai pengaman; alert jika baris masuk ke partisi DEFAULT. Partisi lebih tua dari 18 bulan diarsipkan ke object storage (Parquet) untuk keperluan optimizer, lalu di-detach.

**Validasi server atas `reviewed_at`:** harus berada dalam rentang \[now - 400 hari, now + 1 hari\]; di luar itu op ditolak dengan kode `SYNC_CLOCK_INVALID`.

## 7. Protokol Sinkronisasi

### 7.1 Prinsip

- **Push-pull berbasis outbox.** Setiap perubahan lokal menulis baris `outbox` dalam transaksi yang sama dengan perubahan datanya.
- **Sequence per pengguna, gapless.** Dalam transaksi push, server menjalankan `UPDATE user_sync_state SET last_seq = last_seq + $n WHERE user_id = $1 RETURNING last_seq` dan memberi nomor `user_seq` berurutan pada tiap entitas yang diterima. Row lock mencegah masalah commit tak berurutan yang biasa merusak cursor berbasis sequence global.
- **Idempoten:** op yang sama dikirim ulang menghasilkan `duplicate` (dianggap sukses).

### 7.2 Endpoint

`POST /v1/sync/push` — maksimum 200 op dan 512 KB per request. Contoh isi:

```json
{
  "device_id": "0190a1b2-...",
  "ops": [
    {"op_id": "0190...", "type": "review_log", "data": {"id": "0190...", "card_id": "7c1e...", "rating": 3, "state_before": 2, "reviewed_at": "2026-10-10T03:12:44.120Z", "duration_ms": 4100, "exercise_type": "vocab_recognition_mcq"}},
    {"op_id": "0190...", "type": "card_state", "data": {"card_id": "7c1e...", "state": 2, "due": "2026-10-14T03:00:00.000Z", "stability": 4.2, "difficulty": 5.1, "reps": 6, "lapses": 0, "last_review_at": "2026-10-10T03:12:44.120Z", "updated_at": "2026-10-10T03:12:44.200Z"}}
  ]
}
```

Respons: `{ results: [{op_id, status: accepted|duplicate|rejected, code?}], next_cursor, server_time }`. Tipe op: `review_log`, `card_state`, `settings`, `lesson_progress`, `test_attempt`.

`GET /v1/sync/pull?cursor=<int>&limit=500&entities=cards,settings,progress,logs` — mengembalikan perubahan dengan `user_seq > cursor` dari perangkat lain (`origin_device_id` atau `device_id` bukan perangkat peminta), diurutkan menurut `user_seq` memakai UNION ALL atas tabel entitas. Respons: `{ changes: [{seq, entity, data}], next_cursor, has_more, server_time }`. Cursor tetap maju walaupun seluruh baris terfilter.

### 7.3 Aturan merge

| Entitas | Aturan |
| --- | --- |
| review\_log | Union. Tidak pernah ditimpa. Konflik kunci = duplicate |
| card\_state | Last-write-wins berdasarkan `last_review_at` yang lebih besar; jika sama, `reps` lebih besar menang; jika masih sama, `updated_at` lebih besar. Log review tetap disimpan semuanya |
| settings | LWW berdasarkan `updated_at`; field `version` naik tiap perubahan |
| lesson\_progress | Status maju-saja (not\_started < in\_progress < completed); `best_score` = maksimum |
| test\_attempt | Union berdasarkan id |

Konflik nyata (review kartu sama di dua perangkat offline) jarang. Kompromi disengaja: LWW pada snapshot kartu, sementara kebenaran historis ada di log. Fitur perbaikan di fase 2: tombol Bangun Ulang Kartu dari Log yang memutar ulang log lewat FSRS.

### 7.4 Algoritma klien

```
sync():
  if sedang berjalan: return
  loop:
    ops = outbox WHERE next_attempt_at <= now ORDER BY created_at LIMIT 200
    if ops kosong: break
    res = POST /v1/sync/push
    accepted/duplicate -> hapus dari outbox
    rejected (4xx permanen) -> pindahkan ke dead_letter + log + metric sync_op_rejected_total
    error jaringan/5xx/429 -> attempts++, next_attempt_at = now + min(2^attempts * 2s, 15 menit) + jitter(0..30%)
  loop pull sampai has_more == false:
    transaksi lokal: terapkan merge, simpan cursor
  simpan clock_offset_ms = server_time - now()
```

Pemicu sync: sesi selesai, app ke foreground, jaringan pulih, periodik setiap 15 menit lewat workmanager, setelah login. Debounce 5 detik untuk mencegah badai request.

**Perangkat baru (bootstrap):** pull dengan `entities=cards,settings,progress` dari cursor 0 (tanpa log). Riwayat log dari perangkat lain ditarik lazy di latar belakang (fase 2) hanya untuk statistik.

**Guest → akun:** `POST /v1/auth/link` menautkan identitas ke `user_id` guest yang sama (data tidak berpindah). Jika identitas sudah dimiliki akun lain, MVP tidak melakukan merge otomatis: pengguna memilih data mana yang dipertahankan dengan peringatan eksplisit.

## 8. Kontrak API

### 8.1 Aturan umum

- Prefix `/v1`; perubahan hanya aditif. Versi minimum aplikasi dipaksa lewat `GET /v1/config` (`min_app_version`), dengan layar Perbarui Aplikasi.
- Header: `Authorization: Bearer <jwt>`, `X-Device-Id`, `X-App-Version`, `traceparent` (W3C Trace Context, dikirim klien agar trace tersambung).
- Format error: RFC 9457 `application/problem+json` dengan field tambahan `code` dan `trace_id`.
- Rate limit (Redis, sliding window): endpoint auth 30/menit/IP; push 30/menit/user; lainnya 120/menit/user; respons 429 dengan `Retry-After`.
- Validasi input dengan zod; OpenAPI dihasilkan dari skema yang sama; klien Dart dihasilkan (openapi-generator, dart-dio).

### 8.2 Endpoint

| Grup | Endpoint | Fungsi |
| --- | --- | --- |
| Auth | POST /auth/guest | Buat akun guest dan token |
|  | POST /auth/oidc | Tukar id\_token Google/Apple dengan token |
|  | POST /auth/email/start, /auth/email/verify | OTP email 6 digit, TTL 10 menit, 5 percobaan |
|  | POST /auth/refresh, /auth/logout, /auth/link | Rotasi refresh, cabut, tautkan guest |
| Akun | GET/PATCH /me | Profil dan preferensi |
|  | DELETE /me | Mulai penghapusan akun (§12) |
|  | POST /me/export | Ekspor data (job async, tautan unduh bertanda tangan) |
| Config | GET /config | Feature flag, min\_app\_version, parameter remote |
| Konten | GET /content/manifest?level= | Daftar paket, versi, sha256, ukuran (ETag) |
|  | GET /content/packs/:id/download-url | URL bertanda tangan (paket premium) |
| Sync | POST /sync/push, GET /sync/pull | §7 |
| Billing | POST /billing/verify, GET /billing/entitlements | §13 |
|  | POST /webhooks/apple, /webhooks/google | Notifikasi server store |
| Ops | GET /healthz, GET /readyz, GET /metrics | Liveness, readiness (cek DB dan Redis), metrik (jaringan internal saja) |

### 8.3 Autentikasi

- Access token JWT berumur 15 menit, ditandatangani ES256 atau EdDSA, `kid` mendukung rotasi, JWKS di `/.well-known/jwks.json`.
- Refresh token: 256-bit acak, disimpan sebagai hash SHA-256, berumur 30 hari, DIROTASI setiap pemakaian. Pemakaian ulang token lama = indikasi pencurian → seluruh `family_id` dicabut.
- OTP email disimpan sebagai hash, rate limit per email dan per IP; email lewat penyedia transaksional (SES/Postmark), tanpa menyebut apakah email terdaftar (cegah enumerasi).
- Klien menyimpan token di `flutter_secure_storage`.

### 8.4 Kode error

`AUTH_INVALID_TOKEN`, `AUTH_REFRESH_REUSED`, `VALIDATION_FAILED`, `RATE_LIMITED`, `SYNC_OP_REJECTED`, `SYNC_CLOCK_INVALID`, `CONTENT_NOT_FOUND`, `ENTITLEMENT_REQUIRED`, `APP_UPDATE_REQUIRED`, `INTERNAL`. Klien memetakan setiap kode ke pesan terlokalisasi; jangan menampilkan teks mentah dari server.

## 9. Content Pipeline

Konten dikelola sebagai kode: repo Git `content/` + CLI `nihon-content` + CI. Tidak ada CMS pada MVP (hemat biaya dan risiko).

### 9.1 Tahapan

1. **Ingest:** skrip mengimpor JMdict, KANJIDIC2, KanjiVG, Tatoeba, daftar level ke kolam kandidat (`content/_pool`), disertai metadata sumber dan lisensi.
2. **Kurasi:** content lead memilih item per level berdasarkan daftar level dan frekuensi (pustaka `wordfreq`), menyusun silabus Unit/Lesson.
3. **Enrichment:** kalimat contoh dari Tatoeba (dipilih yang kosakatanya sebagian besar level sama atau di bawahnya), tokenisasi (Sudachi) dan furigana, penjelasan/mnemonik (boleh draf LLM dengan `provenance: llm_draft`), audio TTS.
4. **Review manusia:** reviewer mengubah `provenance` menjadi `human_reviewed` dan mengisi `reviewed_by`. Item `llm_draft` DILARANG dipublikasikan.
5. **Validasi (CI, memblokir merge):** JSON Schema; integritas referensi; setiap vocab punya ≥1 audio dan ≥1 contoh; furigana konsisten dengan bacaan; kanji di sebuah lesson sudah diperkenalkan di kosakata sebelumnya atau lesson itu sendiri; tidak ada duplikat `external_key`; laporan cakupan level (persentase target terpenuhi).
6. **Build:** menghasilkan paket `pack-{level}-{kind}-v{n}.zip` berisi `items.jsonl`, `lessons.json`, `manifest.json`, `audio/*.opus`, `strokes/*.svg`; hitung SHA-256.
7. **Publish:** unggah ke object storage, upsert ke Postgres, lalu perbarui manifest secara atomik (satu penulisan). **Rollback** = mengembalikan manifest ke versi sebelumnya.

### 9.2 Contoh item (YAML sumber)

```yaml
external_key: vocab:jmdict:1358280
type: vocab
jlpt_level: 5
written:
  - {t: 食, r: た}
  - {t: べる}
reading_kana: たべる
pos: [v1, vt]
meanings: {id: [makan], en: [to eat]}
audio: [{voice: f1, file: audio/vocab_1358280_f1.opus}, {voice: m1, file: audio/vocab_1358280_m1.opus}]
examples:
  - tatoeba_id: 12345
    ja: [{t: 朝, r: あさ}, {t: ご飯, r: ごはん}, {t: を}, {t: 食, r: た}, {t: べます}]
    id: Saya makan sarapan.
    en: I eat breakfast.
mnemonic: {id: ..., provenance: human_reviewed, reviewed_by: reviewer_01}
source: [{name: JMdict, license: CC-BY-SA-4.0}]
```

### 9.3 Anggaran ukuran dan distribusi

| Paket | Isi | Anggaran per level (zip) |
| --- | --- | --- |
| core | teks item, lesson, FTS seed | kurang dari 3 MB |
| audio | vocab dan contoh | kurang dari 60 MB |
| strokes | SVG goresan | kurang dari 5 MB |
| passages | bacaan + listening (audio) | kurang dari 40 MB |
| tests | mock test | kurang dari 30 MB |

Klien mengunduh dengan resume (HTTP Range), memverifikasi SHA-256 sebelum dipasang, memasang dalam transaksi (atomik; gagal = rollback ke versi lama), dan hanya mengunduh audio saat Wi-Fi jika pengguna memilih. Pembaruan MVP = unduh ulang paket penuh; update delta masuk fase 2.

## 10. Observability

### 10.1 Prinsip

Setiap request dapat dilacak dari aplikasi sampai query database lewat satu `trace_id`. Telemetri dirancang untuk menjawab tiga pertanyaan: apakah sistem sehat, apakah pengguna benar-benar belajar, dan di mana letak masalah. Telemetri tidak boleh memuat PII.

### 10.2 Logging

- Library pino (backend); format JSON satu baris. Field wajib: `ts`, `level`, `service`, `env`, `version`, `trace_id`, `span_id`, `route`, `status`, `latency_ms`, `error_code`, `user_hash` (HMAC-SHA256 dari user\_id dengan kunci rahasia; bukan ID mentah).
- DILARANG di log: email, token, kode OTP, isi jawaban bebas, IP mentah (simpan hanya /24 yang dipotong atau hash), payload sync penuh.
- Level: ERROR untuk kegagalan yang butuh tindakan; WARN untuk anomali yang ditangani; INFO untuk kejadian bisnis penting; DEBUG nonaktif di produksi.
- Retensi: 14 hari hot, 90 hari cold storage.

### 10.3 Metrik (penamaan Prometheus)

| Metrik | Label | Tujuan |
| --- | --- | --- |
| `http_server_request_duration_seconds` (histogram) | route, method, status\_class | RED per endpoint |
| `sync_push_ops_total` | type, status | Throughput dan penolakan |
| `sync_push_batch_size` (histogram) |  | Ukuran batch |
| `sync_pull_changes_returned` (histogram) |  | Beban pull |
| `sync_clock_invalid_total` |  | Anomali jam perangkat |
| `review_logs_ingested_total` |  | Throughput inti |
| `db_query_duration_seconds` | query\_name | Query lambat per nama |
| `db_pool_in_use`, `db_pool_waiting` |  | Saturasi pool |
| `bullmq_queue_depth`, `bullmq_job_duration_seconds`, `bullmq_job_failed_total` | queue | Kesehatan worker |
| `auth_login_total` | provider, result | Keberhasilan login |
| `auth_refresh_reuse_detected_total` |  | Indikasi pencurian token |
| `billing_verify_total` | platform, result | Kesehatan billing |
| `partition_default_rows` (gauge) |  | Partisi hilang |

Aturan kardinalitas: label TIDAK BOLEH berisi user\_id, device\_id, atau URL penuh.

### 10.4 Tracing

OpenTelemetry SDK dengan auto-instrumentation HTTP, pg, ioredis; span manual `sync.push.validate`, `sync.push.persist`, `sync.pull.query`. Sampling: head 10% di SDK, ditambah tail-based di Collector: 100% untuk trace error atau lebih lambat dari 1 s. Klien mengirim `traceparent` sehingga satu trace mencakup sisi mobile (dari span sync) sampai DB.

### 10.5 Observability sisi klien

- **Sentry (Flutter):** crash, ANR, error non-fatal dengan breadcrumb, release health, trace performa untuk cold start, transisi kartu, dan sync. Scrub PII; `sendDefaultPii = false`.
- **Metrik kustom klien (dikirim sebagai event analitik, sampling 100%):** `sync_attempt{result, duration_ms}`, `outbox_depth` (di akhir sesi), `pack_download{result, size, duration_ms}`, `db_migration{result, from, to}`, `review_card_render_ms` (p50/p95 per sesi).
- Persetujuan: analitik hanya aktif jika pengguna setuju; crash reporting minimal tetap aktif berdasarkan kepentingan sah (tanpa PII) — konfirmasi dengan penasihat hukum.

### 10.6 Analitik produk dan metrik pembelajaran

Taksonomi event (snake\_case, tanpa teks bebas): `app_open`, `onboarding_completed`, `lesson_started`, `lesson_completed`, `review_session_started`, `review_session_completed {cards, accuracy, duration_s}`, `daily_goal_met`, `streak_extended`, `pack_downloaded`, `paywall_viewed`, `subscription_started`, `mocktest_completed`, `settings_changed`.

Metrik hasil belajar (dashboard Produk):

- **True retention:** proporsi rating Good/Easy pada kartu berstatus Review (target dekat desired retention).
- Retensi pengguna D1/D7/D30, WAU, rasio penyelesaian sesi review, jumlah kartu baru per hari aktif, leech rate, waktu sampai review pertama, backlog due median.
- **Guardrail:** crash-free sessions, sync success rate, durasi sesi, tingkat keluhan.

Eksperimen (feature flag PostHog): hipotesis, metrik utama, guardrail, dan durasi dicatat sebelum dimulai; hentikan jika guardrail turun. Ini cara membuktikan fitur di luar spacing/retrieval benar-benar bekerja.

### 10.7 SLO, alert, dashboard, runbook

| SLI | SLO |
| --- | --- |
| Ketersediaan API (bukan 5xx, di luar 429) | 99,9% per bulan (anggaran error sekitar 43 menit) |
| Sync push server | p95 kurang dari 500 ms, p99 kurang dari 1,5 s |
| Sync pull server | p95 kurang dari 400 ms |
| Sync success (dilaporkan klien) | 99,5% atau lebih |
| Crash-free sessions / users | 99,5% / 99,0% atau lebih |
| Ketersediaan CDN konten | 99,9% |

Alert berbasis burn rate (multi-window): PAGE jika konsumsi error budget 14,4x pada jendela 1 jam dan 5 menit; TICKET jika 6x pada 6 jam dan 30 menit. Alert tambahan: CPU DB di atas 80% selama 15 menit, koneksi DB di atas 80%, replication lag di atas 30 s, disk di atas 80%, kedalaman antrean di atas ambang selama 10 menit, `partition_default_rows` lebih dari 0, lonjakan `auth_refresh_reuse_detected_total`, backup gagal, sertifikat kedaluwarsa kurang dari 14 hari, tingkat 5xx di atas 2% selama 5 menit.

Dashboard wajib: (1) Service overview (RED), (2) Sync health, (3) Database, (4) Queue/worker, (5) Auth, (6) Learning outcomes, (7) Client release health. Setiap alert menunjuk ke runbook `docs/runbooks/<nama>.md` berisi: dampak, diagnosis 5 langkah, mitigasi, eskalasi. Proses insiden: severity SEV1–4, satu incident commander, postmortem tanpa menyalahkan dalam 5 hari kerja.

## 11. Reliability dan Scalability

### 11.1 Model kapasitas (asumsi untuk divalidasi di load test)

| Parameter | 100 ribu MAU | 1 juta MAU |
| --- | --- | --- |
| DAU (20% MAU) | 20 ribu | 200 ribu |
| Review per DAU per hari | 60 | 60 |
| Review log per hari | 1,2 juta | 12 juta |
| Rata-rata baris tulis per detik | sekitar 14 | sekitar 140 |
| Puncak (10x rata-rata) | sekitar 140 baris/dtk | sekitar 1.400 baris/dtk |
| Request push puncak (batch rata-rata 30) | sekitar 5/dtk | sekitar 50/dtk |
| Pertumbuhan penyimpanan log (sekitar 250 B/baris termasuk indeks) | sekitar 110 GB/tahun | sekitar 1,1 TB/tahun |

Kesimpulan: satu primary Postgres terkelola yang memadai plus partisi sudah cukup sampai kira-kira 1 juta MAU. Batch push dan SQLite lokal menjaga beban server rendah.

### 11.2 Tangga skala

| Tahap | Konfigurasi | Pemicu naik tahap |
| --- | --- | --- |
| 1 (sampai 100 ribu MAU) | 2–3 pod API (autoscale CPU 60% atau RPS), 1 worker, Postgres primary HA multi-AZ + 1 replica, Redis HA, PgBouncer (mode transaction), CDN | CPU API di atas 60% saat puncak, p95 sync mendekati SLO |
| 2 (sampai sekitar 1 juta) | Skala horizontal API, read replica untuk `pull` dan statistik, instance DB lebih besar, partisi bulanan | CPU primary di atas 60% rata-rata, pool wait terjadi |
| 3 (di atas 1 juta) | Pisahkan modul Sync menjadi service sendiri, shard `review_logs` per hash(user\_id) (Citus atau shard aplikasi), cluster Redis | Throughput tulis di atas kapasitas satu primary |

Catatan konsistensi replica: karena `user_seq` per pengguna gapless dan replica menerapkan WAL berurutan commit, pull dari replica selalu melihat prefiks konsisten dan aman terhadap cursor; lag hanya menunda kemunculan data baru.

### 11.3 Pola reliability (wajib)

- **Timeout di mana-mana:** HTTP klien 15 s; `statement_timeout` DB untuk API 3 s; panggilan eksternal 5 s.
- **Retry hanya untuk operasi idempoten**, dengan backoff eksponensial + jitter dan batas percobaan.
- **Circuit breaker** untuk dependensi eksternal (RevenueCat/App Store/Google Play, penyedia email, TTS). Gunakan library standar (mis. opossum).
- **Bulkhead:** pool DB terpisah untuk API dan worker; antrean terpisah per jenis job.
- **Load shedding:** balas 503 + `Retry-After` jika event-loop lag atau antrean melewati ambang; klien memperlakukan sebagai retry.
- **Graceful shutdown:** tangkap SIGTERM, berhenti menerima request, selesaikan request berjalan maksimal 30 s.
- **Migrasi tanpa downtime (expand → migrate → contract):** kolom baru nullable, `CREATE INDEX CONCURRENTLY`, backfill bertahap, `lock_timeout` 3 s pada migrasi, tidak ada DDL yang mengunci tabel besar. Backend wajib kompatibel dengan aplikasi versi N-2.
- **Feature flag dan kill switch** dari `/config` (cache lokal dengan TTL) untuk mematikan fitur bermasalah tanpa rilis ulang.

**Matriks degradasi:**

| Dependensi turun | Perilaku |
| --- | --- |
| Backend API | Aplikasi tetap belajar penuh; outbox menumpuk; sync saat pulih |
| Redis | Rate limit fail-open dengan batas lokal per pod; job tertunda; auth tetap jalan |
| DB replica | Pull dialihkan ke primary |
| CDN/object storage | Konten terpasang tetap bisa dipakai; unduhan baru gagal dengan pesan jelas dan retry |
| Penyedia email | OTP tertunda; login sosial tetap bisa |
| RevenueCat/store | Entitlement tersimpan di cache dipakai sampai masa tenggang 7 hari |

### 11.4 Backup dan pemulihan bencana

- Postgres: PITR dengan arsip WAL kontinu, retensi 14 hari, snapshot mingguan 90 hari, salinan lintas region (Singapura).
- **RPO 5 menit atau kurang; RTO 1 jam atau kurang** (single region multi-AZ). Failover diuji.
- **Latihan restore tiap kuartal** dengan hasil terdokumentasi; backup yang belum pernah diuji dianggap tidak ada.
- Object storage dengan versioning; seluruh infrastruktur dapat dibangun ulang dari Terraform; secret di secret manager.

### 11.5 Load, soak, dan chaos test

Skenario k6 (pass = SLO terpenuhi): (1) push stabil 500 req/s selama 30 menit; (2) lonjakan 10x selama 5 menit; (3) soak 8 jam; (4) pull dengan cursor jauh tertinggal; (5) push paralel untuk user yang sama → `user_seq` tetap gapless dan tidak ada deadlock; (6) failover DB dan matinya Redis saat beban berjalan. Jalankan di staging sebelum rilis mayor dan setiap kuartal.

### 11.6 Strategi rilis

- **Mobile:** staged rollout 1% → 5% → 20% → 50% → 100% (Play Console / phased release iOS). Hentikan jika crash-free sessions di bawah 99,5% atau sync success turun.
- **Backend:** rolling/blue-green dengan readiness probe; canary 5% selama 15 menit; rollback otomatis jika burn-rate alert menyala.

## 12. Keamanan dan Privasi

### 12.1 Ancaman utama dan kontrol

| Ancaman | Kontrol |
| --- | --- |
| Pencurian token | Access token pendek, refresh rotation + reuse detection, secure storage, logout cabut family |
| IDOR pada sync/data | `user_id` SELALU diambil dari JWT, tidak pernah dari body/path; semua query memfilter `user_id`; tes otomatis lintas-pengguna |
| Brute force OTP/login | Rate limit per email dan per IP, batas percobaan, respons seragam |
| Penyalahgunaan/scraping konten | Konten dasar publik tidak sensitif; paket premium lewat URL bertanda tangan berumur pendek; rate limit |
| Penipuan receipt | Verifikasi di server (via RevenueCat atau API store), jangan percaya klien |
| Injection | Query terparameter (Kysely), validasi zod pada semua input, batas ukuran body |
| Rantai pasok | Lockfile, Dependabot, OSV-Scanner, `npm audit`, SBOM, pin GitHub Actions dengan SHA |
| Kebocoran lewat log | Aturan §10.2, pengujian scrubbing, review PR |

Kontrol tambahan: TLS 1.2+ (utamakan 1.3) dan HSTS; role DB aplikasi tanpa hak DDL; IAM least privilege; enkripsi at-rest (layanan terkelola); gitleaks di CI; SAST (CodeQL atau semgrep); pemindaian container (Trivy); R8/obfuscation Android; checklist OWASP MASVS L1 dijalankan sebelum rilis. Certificate pinning TIDAK dipakai di MVP (risiko operasional); evaluasi ulang nanti.

### 12.2 Privasi

| Data | Tujuan | Catatan |
| --- | --- | --- |
| Email, nama tampilan | Akun | Opsional untuk guest |
| Data belajar (kartu, log, progres) | Fitur inti | Disimpan sampai akun dihapus |
| Info perangkat (platform, versi app) | Dukungan dan kompatibilitas | Tanpa ID iklan |
| Event analitik | Perbaikan produk | Berdasarkan persetujuan, tanpa teks bebas |

Tidak ada lokasi presisi, kontak, atau ID iklan. Prinsip: minimisasi data.

- **Dasar hukum dan persetujuan:** UU Pelindungan Data Pribadi Indonesia (UU No. 27 Tahun 2022) dan, untuk pengguna Uni Eropa, GDPR. Minta persetujuan eksplisit untuk analitik saat onboarding; sediakan Kebijakan Privasi dan Syarat Layanan dalam Indonesia dan Inggris. Transfer lintas negara dan batas usia: konsultasikan dengan penasihat hukum (usia minimum awal: 13 tahun; di bawah 18 butuh persetujuan orang tua sesuai hukum setempat).
- **Penghapusan akun:** `DELETE /me` langsung menonaktifkan akun dan mencabut token; job menghapus permanen seluruh data (cascade, termasuk analitik via API PostHog) dalam 30 hari; salinan backup kedaluwarsa dalam 14 hari berikutnya. Wajib tersedia di dalam aplikasi (kebijakan Apple dan Google).
- **Ekspor data:** `POST /me/export` menghasilkan JSON (kartu, log, pengaturan) dengan tautan unduh bertanda tangan berumur 24 jam.
- Kepatuhan toko: Sign in with Apple jika ada login sosial di iOS, Privacy Nutrition Label, formulir Data Safety Google Play, pengungkapan langganan yang jelas.

## 13. Monetisasi dan Billing

**Model awal (keputusan produk, dapat disesuaikan):** freemium. Gratis: Level 0 (Kana) dan N5 penuh dengan SRS. Premium: N4–N1, mock test lengkap, audio dan paket offline, statistik lanjutan. Tanpa iklan.

**Implementasi default: RevenueCat** (mengurangi kompleksitas validasi receipt). Alur: SDK `purchases_flutter` di klien → webhook RevenueCat ke `POST /webhooks/revenuecat` (verifikasi header otorisasi bersama) → tabel `subscriptions` → `GET /billing/entitlements`. Server menegakkan entitlement pada `download-url` paket premium. Klien menyimpan cache entitlement dengan masa tenggang 7 hari saat offline; paket yang sudah diunduh tetap bisa dipakai sampai entitlement habis ditambah masa tenggang.

**Opsi B** (bila RevenueCat tidak dipilih): `in_app_purchase` di klien; backend memverifikasi dengan App Store Server API dan notifikasi server v2, serta Google Play Developer API dan RTDN. Catat keputusan di decision log sebelum mulai.

Policy: harga lokal ditampilkan oleh store (tier IDR); tombol Pulihkan Pembelian wajib; tanpa dark pattern (tombol tutup paywall jelas, tidak ada hitung mundur palsu).

## 14. DevOps dan Kualitas Kode

### 14.1 Struktur monorepo

```
nihonpath/
  apps/mobile/            # Flutter
  apps/api/               # NestJS
    src/main.ts, app.module.ts
    src/common/           # config, logging, telemetry, errors, guards, rate-limit, clock
    src/modules/          # auth, users, content, sync, tests, billing, config, health
    src/jobs/             # BullMQ: export, deletion, partitions, notifications
    src/db/               # kysely, migrations/
  packages/contracts/     # openapi.yaml, json-schema/
  content/                # sumber konten (YAML), _pool
  tools/content-cli/
  infra/terraform/
  docs/                   # decision-log.md, runbooks/, adr/
  .github/workflows/
```

Aturan modul backend: controller → service → repository. Modul tidak mengakses tabel modul lain secara langsung, hanya lewat service. Modul `sync` memiliki `user_cards`, `review_logs`, `user_settings`, `lesson_progress`, `test_attempts`.

### 14.2 Lingkungan

| Lingkungan | Isi |
| --- | --- |
| local | docker-compose: Postgres, Redis, MinIO, OTel Collector, Grafana; seed konten kecil |
| dev | Deploy otomatis dari main |
| staging | Menyerupai produksi, data sintetis bervolume besar, dipakai load test |
| prod | Deploy setelah persetujuan manual + canary |

Konfigurasi 12-factor (env var), secret dari secret manager; Flutter flavor `dev`, `staging`, `prod` via `--dart-define`.

### 14.3 Pipeline CI/CD

| Tahap | Pemeriksaan |
| --- | --- |
| Setiap PR | lint dan format, unit test, deteksi perubahan breaking pada OpenAPI (oasdiff), cek klien hasil generate sudah mutakhir, dry-run migrasi pada Postgres sementara (Testcontainers), build container, pemindaian keamanan (gitleaks, OSV, Trivy, CodeQL), validasi konten |
| Merge ke main | Deploy ke staging, smoke test, e2e API |
| Rilis | Persetujuan manual → canary → bertahap; mobile lewat fastlane ke TestFlight/Play Internal → staged rollout |

Git: trunk-based, branch pendek, PR wajib, conventional commits, versi semantik untuk aplikasi.

### 14.4 Strategi pengujian backend

Unit (vitest/jest); integrasi dengan Testcontainers (Postgres, Redis); contract test terhadap OpenAPI (Schemathesis); property-based test untuk aturan merge (§7.3); tes konkurensi push paralel (sequence gapless); tes lintas-pengguna untuk IDOR. Target cakupan baris modul `sync` dan `auth` di atas 90%.

## 15. Roadmap dan Rincian Task

Urutan milestone bersifat berurutan kecuali disebut paralel. Ukuran: S (sampai 1 hari), M (2–4 hari), L (lebih dari 4 hari → pecah lagi menjadi sub-task sebelum dikerjakan). Setiap task mengikuti DoD di §0.

### M0 — Fondasi

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M0-1 | Monorepo, linter, formatter, CI kerangka | CI hijau di PR kosong; struktur sesuai §14.1 | M |
| M0-2 | `openapi.yaml` v0 (auth, config, manifest, sync) + JSON Schema konten + generator klien Dart/TS | Klien ter-generate; CI gagal bila hasil generate basi | M |
| M0-3 | docker-compose lokal (Postgres, Redis, MinIO, OTel Collector, Grafana) | `make up` menjalankan semua; trace contoh terlihat di Grafana | M |
| M0-4 | Terraform environment dev (jaringan, Postgres terkelola, Redis, storage, CDN, layanan container) | `terraform apply` dari nol berhasil; state remote | L → pecah |
| M0-5 | Template decision log, ADR, runbook | File ada dan terisi contoh | S |

### M1 — Backend inti (paralel dengan M2)

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M1-1 | Kerangka NestJS: config tervalidasi, pino, OTel, `/healthz` `/readyz`, filter error RFC 9457, `Clock` | Tes unit; trace dan log memuat `trace_id` | M |
| M1-2 | Migrasi 001 (seluruh skema §6.3) + Kysely typed | Migrasi naik-turun di Testcontainers; tabel `review_logs` terpartisi | M |
| M1-3 | Auth: guest, refresh rotation + reuse detection, JWKS | Tes: reuse mencabut family; token kedaluwarsa ditolak | M |
| M1-4 | Auth: OIDC Google/Apple, OTP email | Tes dengan mock provider; rate limit bekerja | M |
| M1-5 | `/me`, `/config`, job penghapusan dan ekspor akun | Data terhapus sesuai §12.2; tes cascade | M |
| M1-6 | Modul content: manifest (ETag) + download-url bertanda tangan | Tes ETag/304; paket premium butuh entitlement | M |
| M1-7 | Modul sync: push, pull, aturan merge | Lampiran C dipenuhi; tes properti merge; tes push paralel (seq monoton tanpa celah, tanpa deadlock) | L → pecah |
| M1-8 | Rate limiting Redis + metrik §10.3 + dashboard awal | Metrik muncul di Grafana | M |
| M1-9 | Job pembuat partisi + alert partisi DEFAULT | Tes: partisi 3 bulan ke depan tersedia | S |

### M2 — Content pipeline dan konten awal

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M2-1 | CLI ingest (JMdict, KANJIDIC2, KanjiVG, Tatoeba) ke `_pool` | Kolam terisi; metadata lisensi per item | L → pecah |
| M2-2 | Validator (§9.1 tahap 5) + laporan cakupan | CI memblokir konten tidak valid | M |
| M2-3 | Builder paket + publish + rollback manifest | Paket terverifikasi SHA-256; rollback teruji | M |
| M2-4 | Pipeline audio TTS (multi-suara, Opus) | Setiap vocab punya ≥2 audio; biaya per 1.000 item dicatat | M |
| M2-5 | Konten Level 0 (kana): audio, goresan | Reviewer menyetujui | M |
| M2-6 | Konten N5 lengkap (target §3.1), tinjauan manusia | 100% item `human_reviewed` | L (berjalan paralel dengan M3–M4) |

### M3 — Flutter inti (offline)

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M3-1 | Kerangka app: flavor, tema, l10n id/en, `Clock`, `IdGenerator`, router | App berjalan di 3 flavor | M |
| M3-2 | Skema Drift + tes migrasi | Tes migrasi naik dari setiap versi sebelumnya | M |
| M3-3 | Pack manager: unduh Range/resume, verifikasi SHA-256, pasang atomik, FTS | Tes fault injection: paket korup = rollback | L → pecah |
| M3-4 | Pembungkus `Scheduler` + FSRS + golden test ≥50 skenario | Semua golden lulus | M |
| M3-5 | `queue_builder` (§3.6) + tes | Tes: gate kartu baru, interleave, bury sibling, day boundary 04:00 | M |
| M3-6 | Layar review: pilihan ganda, ketik jawaban, flashcard 4 tombol; audio preload | Transisi kartu kurang dari 100 ms; satu transaksi per review | L → pecah |
| M3-7 | Alur pelajaran (perkenalan, kuis, ringkasan) | Review log pertama tercatat dari kuis | M |
| M3-8 | Home, progres, forecast beban review | Query memakai indeks; tanpa memuat semua kartu | M |
| M3-9 | Kana: tabel, latihan, tulis tangan (ML Kit) + animasi goresan | Berjalan offline setelah model diunduh | M |
| M3-10 | Onboarding, pengaturan, notifikasi lokal harian | Notifikasi mengikuti zona waktu | M |

### M4 — Auth dan sync klien

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M4-1 | Klien API ter-generate + alur auth + secure storage + refresh otomatis | Tes: refresh sekali meski banyak request paralel | M |
| M4-2 | Outbox + SyncClient + merge (§7.3–7.4) | Tes unit semua cabang merge | L → pecah |
| M4-3 | Pemicu sync + workmanager + backoff berjitter | Tes mode pesawat → pulih | M |
| M4-4 | Fault injection sync (putus, 500, lambat, 429) | Tidak ada data hilang; outbox akhirnya kosong | M |
| M4-5 | Tautkan guest, hapus akun, ekspor data (UI) | Alur uji end-to-end di staging | M |

### M5 — Observability, hardening, beta tertutup

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M5-1 | Sentry, metrik klien, analitik dengan consent | Event terverifikasi; tidak ada PII | M |
| M5-2 | Dashboard, alert burn-rate, runbook (§10.7) | Tiap alert punya runbook; uji alert dengan kegagalan sengaja | M |
| M5-3 | Load/soak/chaos test (§11.5) | SLO terpenuhi; hasil dilaporkan | M |
| M5-4 | Checklist MASVS L1 + tinjauan keamanan | Temuan tinggi/kritis = 0 | M |
| M5-5 | Latihan restore backup | Laporan waktu pemulihan terdokumentasi | S |
| M5-6 | Beta tertutup (TestFlight, Play Internal) | Crash-free di atas 99,5% selama 2 minggu | M |

### M6 — Rilis v1 (Level 0–N5 gratis; N4–N3 premium)

| ID | Task | Kriteria selesai | Ukuran |
| --- | --- | --- | --- |
| M6-1 | Billing (RevenueCat), paywall, entitlement, masa tenggang | Tes sandbox iOS dan Android; pulihkan pembelian | L → pecah |
| M6-2 | Konten N4 dan N3 | Seluruh item `human_reviewed` | L (paralel) |
| M6-3 | Reading bertingkat dan listening (alat konten + UI) | Tokenisasi build-time; gloss ketuk; kontrol kecepatan | L → pecah |
| M6-4 | Aset toko, privasi, atribusi lisensi, kebijakan penghapusan akun | Lolos review Apple dan Google | M |
| M6-5 | Staged rollout dengan gerbang §11.6 | Rilis 100% tanpa halt | S |

### M7 — N2–N1 dan mock test

Engine mock test (timer, bagian gaya 文字・語彙・文法/読解/聴解, pelaporan hasil, tanpa klaim skor resmi), konten N2 dan N1, penambahan facet `listening`, `writing`, dan `production`.

### M8 — Fase 3 (opsional, berdasarkan data)

Personalisasi parameter FSRS dengan optimizer di server (job batch; butuh sekitar 1.000 review atau lebih per pengguna), latihan shadowing dengan rekaman (tanpa skoring), backfill riwayat log, update paket delta, layout tablet, widget layar utama, partner percakapan berbasis LLM (dengan guardrail, biaya terkontrol, dan tinjauan privasi tersendiri).

### Template Task Brief (isi untuk setiap task sebelum dikerjakan)

```
Task ID / Judul:
Tujuan (1 kalimat):
Bagian dokumen yang menjadi acuan:
Input (file, kontrak, data):
Output (file/endpoint/layar):
Langkah:
Tes yang harus ada:
Observability yang harus ada:
Di luar cakupan:
Catatan keputusan (jika ada asumsi):
```

## 16. Panduan Khusus Implementer

### 16.1 Alur kerja per task

1. Baca bagian dokumen yang dirujuk dan Lampiran yang relevan. 2. Isi Task Brief. 3. Tulis/ubah kontrak bila perlu (OpenAPI/JSON Schema). 4. Tulis tes dulu untuk logika inti (SRS, merge, queue, sync). 5. Implementasi minimal. 6. Tambahkan log/metric/trace. 7. Jalankan lint, tes, dan build lokal; buka PR kecil dengan deskripsi dan hasil tes.

### 16.2 Keputusan yang SUDAH dikunci vs yang boleh dipilih

| Dikunci (jangan diubah tanpa decision log + persetujuan) | Boleh dipilih implementer |
| --- | --- |
| Offline-first, outbox, log append-only (§4.3) | Nama kelas, struktur internal modul selama aturan lapisan dipatuhi |
| FSRS-6 dengan konfigurasi §2 | Pustaka UI kecil (tanpa dependency baru di luar §5.2) |
| Skema data §6 dan protokol sync §7 | Detail visual selama mengikuti design system dan aksesibilitas §5.6 |
| Stack §4.2 dan paket §5.2 | Ukuran batch internal selama batas §7.2 dipatuhi |
| Aturan lisensi dan provenance konten (§3.2, §9) | Teks UI awal (dalam ARB, akan ditinjau) |

### 16.3 Jebakan umum (baca sebelum menulis kode)

- **Waktu:** simpan semua waktu UTC; batas hari belajar memakai zona waktu pengguna dan pergantian jam 04:00; uji di zona UTC+7 dan UTC-8 serta saat DST (pengguna internasional).
- **Determinisme FSRS:** fuzz memakai seed dari hash(card\_id, reps); jangan memakai random global; tes golden harus stabil.
- **Transaksi:** satu review = satu transaksi SQLite (log + kartu + outbox). Jangan pernah menulis sebagian.
- **Performa:** jangan memuat seluruh tabel kartu; selalu query terindeks dan berbatas.
- **Normalisasi teks Jepang (jawaban ketik):** NFKC; hapus spasi; bandingkan dalam hiragana untuk facet bacaan (katakana dikonversi); terima beberapa bacaan/jawaban dari field `accepted_answers` di data; jangan menebak aturan sendiri di UI. Perhatikan vokal panjang (ー), kana kecil, dan komposisi IME (jangan evaluasi saat masih composing).
- **Furigana:** jangan hitung bacaan saat runtime; pakai data segmentasi dari paket.
- **Idempotensi:** semua POST tulis harus aman di-retry; jangan membuat efek samping ganda.
- **Log:** jangan mencatat payload sync atau jawaban pengguna.
- **Jam perangkat salah:** server menolak `reviewed_at` di luar jendela (§6.3); klien menampilkan pesan Periksa jam perangkat dan tidak menghapus outbox.
- **Kebijakan toko:** jangan menghapus tombol hapus akun; jangan memakai istilah resmi JLPT yang menyiratkan afiliasi (JLPT adalah merek pihak lain): gunakan frasa bergaya JLPT atau tingkat setara JLPT.

### 16.4 Kapan harus berhenti dan bertanya

Hentikan dan catat di decision log (dengan opsi dan rekomendasi) jika: paket/versi yang disebut tidak ada; lisensi sumber data tidak jelas; perubahan akan menyentuh skema §6 atau protokol §7; atau tes golden FSRS tidak bisa dipenuhi.

## 17. Risiko dan Pertanyaan Terbuka

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Lisensi data (CC BY-SA, ToS TTS, pitch accent) | Hukum/penarikan konten | Tinjauan hukum sebelum M6; halaman atribusi; fitur pitch accent ditunda bila lisensi tidak jelas |
| Kualitas konten (kesalahan LLM/TTS, bacaan salah) | Merusak kepercayaan dan hasil belajar | Tinjauan manusia wajib; tombol Laporkan Masalah per item; audit sampel berkala |
| Paket Dart `fsrs` tertinggal | Jadwal tidak sesuai FSRS-6 | Opsi B (flutter\_rust\_bridge ke fsrs-rs); golden test sebagai gerbang |
| Ukuran aplikasi dan unduhan | Churn awal | Paket per level, unduh bertahap, anggaran §9.3 |
| Scope creep | Jadwal molor | Non-goals §1; fitur baru wajib lewat decision log |
| Manipulasi jam perangkat | Statistik/streak tidak akurat | Validasi jendela server; streak dihitung dari log tervalidasi |
| Kepatuhan privasi (UU PDP, GDPR, usia) | Sanksi | Tinjauan hukum, minimisasi data, §12.2 |
| Ketergantungan pihak ketiga (RevenueCat, Sentry, PostHog) | Gangguan/biaya | Abstraksi di belakang interface; kill switch; masa tenggang entitlement |
| Efektivitas klaim | Klaim berlebihan | Aturan §2; ukur true retention dan hasil sendiri |

**Pertanyaan terbuka untuk product owner (jawab sebelum M6):** harga dan paket langganan; nama dan merek final; anggaran reviewer penutur asli dan N2/N1; kebutuhan data residency; kebijakan usia; kanal dukungan pengguna; platform eksperimen (PostHog cloud atau self-host); apakah audio rekaman penutur asli diprioritaskan untuk level tertentu.

## Lampiran A — Glosarium

- **SRS:** spaced repetition system. **FSRS:** Free Spaced Repetition Scheduler, model memori DSR.
- **Stability (S):** hari sampai probabilitas ingat turun ke 90%. **Difficulty (D):** 1–10. **Retrievability (R):** probabilitas ingat saat ini.
- **Desired retention:** target R saat kartu dijadwalkan ulang. **Leech:** kartu yang berulang kali gagal.
- **Outbox:** antrean operasi lokal yang menunggu dikirim. **LWW:** last-write-wins. **Idempoten:** operasi yang aman diulang.
- **SLI/SLO:** indikator/target tingkat layanan. **RED:** Rate, Errors, Duration. **PITR:** point-in-time recovery. **RPO/RTO:** batas kehilangan data/waktu pemulihan.

## Lampiran B — Checklist pra-rilis

1. Seluruh SLO dan alert aktif, runbook ada. 2. Load test lulus pada staging. 3. Restore backup teruji dalam 90 hari terakhir. 4. Checklist MASVS L1 selesai. 5. Konten: 100% `human_reviewed`, atribusi lisensi tampil. 6. Hapus akun dan ekspor data berfungsi. 7. Formulir privasi toko akurat. 8. Kill switch dan `min_app_version` teruji. 9. Staged rollout dikonfigurasi dengan kriteria halt. 10. Tim on-call dan jalur eskalasi ditetapkan.

## Lampiran C — Pseudocode acuan

### C.1 Transaksi review di klien

```
onAnswer(card, rating, durationMs):
  now = clock.now()
  result = scheduler.review(card.state, rating, now)
  db.transaction:
    insert review_logs(id=uuidv7, card_id, rating, state_before, reviewed_at=now, ...)
    update user_cards set state, due, stability, difficulty, reps, lapses, last_review_at=now, updated_at=now
    insert outbox(op_id=uuidv7, type=review_log, payload=...)
    insert outbox(op_id=uuidv7, type=card_state, payload=...)   # boleh digabung per kartu: ganti op lama yang belum terkirim
  syncScheduler.requestSync(debounce=5s)
```

### C.2 Handler push di server

```
push(userId, deviceId, ops):
  validasi skema; jika ops lebih dari 200 atau ukuran lebih dari 512 KB -> 413
  BEGIN
    INSERT INTO user_sync_state(user_id) VALUES (userId) ON CONFLICT DO NOTHING
    SELECT last_seq FROM user_sync_state WHERE user_id = userId FOR UPDATE   # serialisasi per pengguna
    muat baris kartu yang direferensikan dan id review_log yang sudah ada
    untuk tiap op, tentukan keputusan tanpa menulis:
      review_log : reviewed_at di luar jendela -> rejected(SYNC_CLOCK_INVALID); id sudah ada -> duplicate; selain itu applied
      card_state : pakai aturan LWW §7.3 -> applied bila menang, duplicate bila kalah/identik
      settings, lesson_progress, test_attempt : aturan §7.3
    n = jumlah op applied
    nomor seq = last_seq + 1 .. last_seq + n (urut sesuai urutan op)
    tulis semua op applied dengan user_seq tersebut (batch INSERT ... multi-row)
    UPDATE user_sync_state SET last_seq = last_seq + n
  COMMIT
  return results per op + next_cursor + server_time
```

Akibatnya `user_seq` per pengguna monoton dan tanpa celah, sehingga cursor pull aman. Dua push paralel untuk pengguna yang sama diserialisasi oleh `FOR UPDATE`; pada kontensi tinggi, klien cukup retry.

### C.3 Handler pull di server

```
pull(userId, deviceId, cursor, limit, entities):
  rows = UNION ALL dari user_cards, review_logs, user_settings, lesson_progress, test_attempts
         WHERE user_id = userId AND user_seq > cursor AND (origin/device bukan deviceId) AND entitas dipilih
         ORDER BY user_seq LIMIT limit + 1
  has_more = rows.length > limit; potong ke limit
  next_cursor = has_more ? seq baris terakhir yang dikembalikan : max(cursor, last_seq milik pengguna)
  return changes, next_cursor, has_more, server_time
```

Catatan: bila baris terfilter (milik perangkat peminta) memenuhi seluruh halaman, query perlu dilanjutkan sampai terkumpul `limit` baris atau data habis, agar cursor tetap maju dan klien tidak menerima halaman kosong berulang.
