"""Milestone M2: Content Pipeline dan Konten Awal issues."""

from typing import List
from .common import IssueSpec

def get_m2_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M2-1a",
            title="CLI Ingest JMdict & KANJIDIC2",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengembangkan modul CLI tools/content-cli untuk mem-parsing data JMdict dan KANJIDIC2 serta menyimpannya ke kolam kandidat konten dengan metadata lisensi CC BY-SA 4.0.",
            acuan="§3.2 (Sumber data dan lisensi), §9.1 tahap 1 (Ingest), §14.1 (tools/content-cli)",
            input_data="File XML sumber JMdict dan KANJIDIC2 (EDRDG).",
            output_data="CLI command `nihon-content ingest jmdict` dan `nihon-content ingest kanjidic` yang menghasilkan file YAML di `content/_pool/vocab/` dan `content/_pool/kanji/`.",
            langkah=[
                "Buat command line tool di `tools/content-cli/` menggunakan TypeScript / Node.js.",
                "Implementasikan XML streaming parser untuk JMdict: ekstrak ID entri, pembacaan kana, kanji, part-of-speech (pos), serta arti dalam bahasa Indonesia dan Inggris.",
                "Implementasikan XML streaming parser untuk KANJIDIC2: ekstrak karakter kanji, makna (meaning), on'yomi, kun'yomi, dan jumlah goresan (stroke count).",
                "Format output ke file YAML terstruktur dengan metadata atribusi lisensi CC BY-SA 4.0 (§3.2, §9.2): `source: [{name: JMdict/KANJIDIC2, license: CC-BY-SA-4.0}]`.",
                "Simpan kandidat item ke dalam `content/_pool/vocab/` dan `content/_pool/kanji/` dengan penamaan `external_key` stabil (mis. `vocab:jmdict:1358280`, `kanji:食`)."
            ],
            tes=[
                "Unit test: parser JMdict berhasil mengekstrak entri vocab kompleks (multiple readings & meanings).",
                "Unit test: parser KANJIDIC2 mengekstrak kanji beserta goresan dan on/kun.",
                "Verifikasi output YAML menyertakan blok metadata `source` dan `license` lengkap."
            ],
            observability=[
                "Log proses ingest mencatat jumlah total entri diproses, error parsing, dan waktu eksekusi."
            ],
            out_of_scope=[
                "Ingest KanjiVG dan Tatoeba (dikerjakan di M2-1b).",
                "Kurasi silabus level spesifik (dikerjakan di M2-1c dan M2-6)."
            ],
            aturan_ketat=[
                "WAJIB menyertakan metadata lisensi CC BY-SA 4.0 pada setiap item hasil impor (§3.2).",
                "`external_key` WAJIB stabil dan deterministik (§6.1).",
                "DILARANG menyalin konten dari kamus/aplikasi proprietary lain (§0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-1 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-1b",
            title="CLI Ingest KanjiVG & Tatoeba",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengembangkan modul CLI tools/content-cli untuk mem-parsing SVG urutan goresan KanjiVG dan kalimat contoh Tatoeba ke dalam kolam kandidat konten.",
            acuan="§3.2 (Sumber data dan lisensi), §9.1 tahap 1 (Ingest), §14.1 (tools/content-cli)",
            input_data="Arsip file SVG KanjiVG dan corpus Tatoeba (dataset kalimat bahasa Jepang - Indonesia/Inggris).",
            output_data="CLI command `nihon-content ingest kanjivg` dan `nihon-content ingest tatoeba` yang menyimpan asset ke `content/_pool/strokes/` dan `content/_pool/sentences/`.",
            langkah=[
                "Implementasikan parser untuk KanjiVG: sanitasi file SVG urutan goresan kanji/kana, ekstrak path strokes dan nomor urut goresan.",
                "Format output SVG KanjiVG ke `content/_pool/strokes/{unicode}.svg` dengan metadata lisensi CC BY-SA 3.0 (§3.2).",
                "Implementasikan parser untuk corpus Tatoeba: filter kalimat berbahasa Jepang yang memiliki terjemahan bahasa Indonesia (`id`) dan bahasa Inggris (`en`).",
                "Format kalimat contoh Tatoeba ke YAML di `content/_pool/sentences/` menyertakan `tatoeba_id`, teks Jepang, terjemahan, dan atribusi lisensi CC BY 2.0 FR (atau CC0 jika berlaku, §3.2, §9.2)."
            ],
            tes=[
                "Unit test: validasi sintaks XML/SVG hasil ekstraksi KanjiVG.",
                "Unit test: parser Tatoeba memadankan pasangan terjemahan ja-id dan ja-en dengan benar.",
                "Verifikasi setiap file output menyertakan metadata lisensi yang tepat."
            ],
            observability=[
                "Log ringkasan jumlah goresan SVG dan kalimat contoh yang berhasil diimpor."
            ],
            out_of_scope=[
                "Tokenisasi Sudachi untuk kalimat Tatoeba (dikerjakan di M2-6b).",
                "Ingest JMdict/KANJIDIC2 (dikerjakan di M2-1a)."
            ],
            aturan_ketat=[
                "Atribusi lisensi KanjiVG (CC BY-SA 3.0) dan Tatoeba (CC BY 2.0 FR) wajib dicatat (§3.2).",
                "SVG wajib disanitasi dari tag atau atribut script berbahaya."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-1 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-1c",
            title="CLI Pool Manager & Pemetaan Level JLPT Komunitas",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengembangkan modul CLI tools/content-cli untuk memetakan kolam kandidat konten ke level perkiraan JLPT (Tanos) dan frekuensi kata (wordfreq).",
            acuan="§2 (Frekuensi dan lexical coverage), §3.1 (Cakupan per level), §3.2 (Lisensi komunitas), §9.1 tahap 2 (Kurasi)",
            input_data="Kolam konten `content/_pool`, daftar level JLPT komunitas (Tanos), pustaka `wordfreq`.",
            output_data="CLI command `nihon-content pool map-level` dan metadata level/frekuensi pada item di `content/_pool`.",
            langkah=[
                "Integrasikan daftar pemetaan level JLPT komunitas (mis. daftar Tanos, CC BY) ke dalam CLI.",
                "Integrasikan pustaka kalkulasi frekuensi leksikal bahasa Jepang (`wordfreq`).",
                "Buat algoritma penandaan item: setiap kosakata dan kanji di `content/_pool` diberi estimasi level JLPT (0, 5, 4, 3, 2, 1) serta skor frekuensi penggunaan riil (§2, §3.1).",
                "Sediakan utilitas CLI untuk memfilter dan mengurutkan kandidat kosakata berdasarkan level lalu frekuensi guna mempermudah pemilihan silabus oleh content lead (§2, §9.1 tahap 2)."
            ],
            tes=[
                "Unit test: verifikasi kosakata dasar (misal `食べる`, `行く`) terpetakan ke Level 5 (N5) dengan skor frekuensi tinggi.",
                "Unit test: ketiadaan duplikasi `external_key` saat pemetaan dilakukan."
            ],
            observability=[
                "Log statistik distribusi jumlah kata dan kanji per level (0, N5 s/d N1)."
            ],
            out_of_scope=[
                "Penyusunan unit dan lesson final (dikerjakan di M2-5 dan M2-6)."
            ],
            aturan_ketat=[
                "Urutan prioritas pembelajaran kosakata WAJIB berdasarkan level JLPT lalu frekuensi leksikal (§2, §6.1).",
                "Peringatan legal (§3.1, §3.2): JLPT tidak merilis daftar resmi; daftar komunitas harus diatribusikan CC BY."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-1 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-2",
            title="Validator konten (§9.1 tahap 5) + laporan cakupan",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Membangun CLI validator konten dan integrasi CI yang memvalidasi integritas referensi, konsistensi furigana, kelengkapan audio, provenance manusia, dan laporan cakupan level.",
            acuan="§3.2 (Aturan LLM & lisensi), §3.3 (Prinsip kanji-in-context), §9.1 tahap 4 & 5 (Validasi), §9.2 (Schema konten)",
            input_data="File YAML kurikulum di `content/`, JSON Schema dari M0-2.",
            output_data="CLI command `nihon-content validate`, laporan markdown cakupan level, dan CI step di `.github/workflows/ci.yml`.",
            langkah=[
                "Implementasikan fungsi validasi skema JSON Schema pada setiap file YAML di folder `content/`.",
                "Validasi integritas referensi: setiap `item_id` di `lessons` harus merujuk ke `content_items` yang ada.",
                "Validasi kelengkapan asset: setiap item vocab WAJIB memiliki minimal 1 file audio dan minimal 1 kalimat contoh (§9.1 tahap 5).",
                "Validasi konsistensi furigana: segmen furigana harus cocok dengan bacaan kana item.",
                "Validasi prinsip kanji-in-context (§3.3, §9.1 tahap 5): kanji dalam sebuah lesson harus sudah diperkenalkan di kosakata unit sebelumnya atau lesson itu sendiri.",
                "Validasi Larangan Keras LLM (§3.2, §9.1 tahap 4): item bertanda `provenance: llm_draft` DILARANG KERAS dipublikasikan! Item wajib bertanda `provenance: human_reviewed` dengan `reviewed_by` valid.",
                "Validasi keunikan: tidak ada duplikasi `external_key`.",
                "Generate laporan cakupan level: persentase target kosakata & kanji yang terpenuhi vs target kumulatif §3.1.",
                "Integrasikan ke pipeline CI: CI WAJIB GAGAL dan memblokir merge PR jika ada satu pun pelanggaran validasi."
            ],
            tes=[
                "Unit test: validator mendeteksi dan menolak item dengan `provenance: llm_draft`.",
                "Unit test: validator mendeteksi pelanggaran kanji-in-context (kanji diajarkan sebelum diperkenalkan).",
                "Unit test: validator menolak vocab tanpa file audio atau contoh kalimat.",
                "Integration test: pipeline CI gagal saat dimasukkan file YAML yang tidak valid."
            ],
            observability=[
                "Output konsol menampilkan rincian error validasi baris-per-baris dan ringkasan persentase kelulusan."
            ],
            out_of_scope=[
                "Penyusunan arsip zip paket konten (dikerjakan di M2-3).",
                "Pengisian konten kurikulum N5 (dikerjakan di M2-6)."
            ],
            aturan_ketat=[
                "Item `llm_draft` DILARANG KERAS lolos validasi publikasi; WAJIB `human_reviewed` (§3.2, §9.1).",
                "Vocab wajib punya ≥1 audio dan ≥1 contoh kalimat (§9.1 tahap 5).",
                "CI WAJIB memblokir merge jika validasi konten gagal (§9.1 tahap 5)."
            ],
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-3",
            title="Builder paket + publish + rollback manifest",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengembangkan builder CLI untuk mengemas konten menjadi arsip zip per-level, memverifikasi batas ukuran anggaran, mengunggah ke object storage, dan memperbarui manifest secara atomik.",
            acuan="§4.2 (Storage & CDN), §6.3 (content_packs), §9.1 tahap 6 & 7 (Build & Publish), §9.3 (Anggaran ukuran dan distribusi)",
            input_data="File konten tervalidasi di `content/`, aset audio/strokes, koneksi S3/MinIO dan PostgreSQL.",
            output_data="CLI command `nihon-content build`, `nihon-content publish`, dan `nihon-content rollback`.",
            langkah=[
                "Implementasikan `nihon-content build`: mengemas konten menjadi zip per level dan per jenis `pack-{level}-{kind}-v{n}.zip` (`core`, `audio`, `strokes`, `passages`, `tests`).",
                "Struktur isi zip: `items.jsonl`, `lessons.json`, `manifest.json`, file audio Opus/AAC, dan file SVG KanjiVG.",
                "Hitung checksum SHA-256 dan ukuran bytes dari setiap paket zip yang dihasilkan.",
                "Verifikasi kepatuhan anggaran ukuran ketat sesuai §9.3:",
                "  - `core` < 3 MB",
                "  - `audio` < 60 MB",
                "  - `strokes` < 5 MB",
                "  - `passages` < 40 MB",
                "  - `tests` < 30 MB",
                "Implementasikan `nihon-content publish`: unggah file zip ke S3/MinIO bucket, lakukan upsert record ke tabel `content_packs`, dan perbarui manifest di server secara atomik (satu transaksi penulisan).",
                "Implementasikan `nihon-content rollback`: mekanisme mengembalikan versi manifest ke versi sebelumnya secara instan jika ditemukan isu kritis pasca publikasi (§9.1 tahap 7)."
            ],
            tes=[
                "Unit test: build paket menghasilkan struktur zip valid dan checksum SHA-256 yang akurat.",
                "Unit test: builder melempar error jika ukuran paket melebihi batas anggaran §9.3.",
                "Integration test: publish berhasil mengunggah file ke MinIO dan mencatat record di tabel `content_packs`.",
                "Integration test: verifikasi prosedur rollback mengembalikan versi aktif manifest ke versi n-1."
            ],
            observability=[
                "Log proses build dan publish mencatat nama paket, versi, ukuran bytes, SHA-256, dan URL tujuan storage.",
                "Metrik waktu build dan total payload ukuran paket."
            ],
            out_of_scope=[
                "Pembaruan paket delta (ditunda ke fase 3 / M8-4).",
                "Unduh paket di sisi klien Flutter (dikerjakan di M3-3)."
            ],
            aturan_ketat=[
                "Anggaran ukuran paket WAJIB dipatuhi tanpa kompromi (§9.3).",
                "Publikasi manifest WAJIB bersifat atomik (satu transaksi/penulisan) (§9.1 tahap 7).",
                "Rollback manifest harus dapat dieksekusi tanpa downtime (§9.1 tahap 7)."
            ],
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-4",
            title="Pipeline audio TTS (multi-suara, Opus)",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengembangkan pipeline otomasi pra-render audio berbasis cloud neural TTS dengan minimal 2 variasi suara, format Opus 32–48 kbps, dan pelacakan biaya.",
            acuan="§2 (Pelatihan fonetik variabilitas tinggi), §3.2 (Lisensi ToS TTS), §5.5 (Audio pra-render), §9.1 tahap 3 (Enrichment), §9.3 (Anggaran audio)",
            input_data="Teks kata dan kalimat contoh dari `content/`, API key cloud TTS (Google Cloud TTS / Azure Speech / AWS Polly).",
            output_data="CLI command `nihon-content audio generate`, file audio `.opus` di `content/assets/audio/`, dan log pelacakan biaya.",
            langkah=[
                "Implementasikan modul generator audio di `tools/content-cli/` yang memanggil API neural TTS resmi.",
                "Wajibkan minimal 2 profil suara berbeda per item: 1 suara perempuan (`f1`) dan 1 suara laki-laki (`m1`) untuk memenuhi prinsip variabilitas fonetik (§2, §5.5, §9.2).",
                "Konversi/encode output audio ke format Opus (atau AAC) dengan bitrate efisien 32–48 kbps menggunakan `ffmpeg` guna memenuhi anggaran ukuran paket audio < 60 MB (§5.5, §9.3).",
                "Simpan audio dengan pola path stabil: `audio/vocab_{id}_{voice}.opus` dan kaitkan ke file YAML sumber konten.",
                "Implementasikan tracking biaya API TTS (hitung estimasi biaya per 1.000 karakter/item yang di-render) dan simpan laporan ringkasan biaya.",
                "Pastikan verifikasi kepatuhan ToS penyedia TTS terkait izin penyimpanan (caching) dan redistribusi audio offline dalam aplikasi (§3.2)."
            ],
            tes=[
                "Unit test: generator audio menghasilkan minimal 2 file audio (f1 dan m1) untuk setiap kata uji.",
                "Unit test: verifikasi bitrate audio berada dalam rentang 32–48 kbps dan format kontainer Opus valid.",
                "Verifikasi estimasi kalkulasi biaya tercatat akurat di log output."
            ],
            observability=[
                "Log mencatat jumlah file audio dibuat, durasi pemanggilan API, total kuota karakter TTS terpakai, dan kalkulasi biaya."
            ],
            out_of_scope=[
                "Pemutaran audio di aplikasi mobile (dikerjakan di M3-6 menggunakan `just_audio`).",
                "Penilaian ucapan real-time (dikecualikan dari MVP sesuai §1 Non-goals)."
            ],
            aturan_ketat=[
                "Setiap vocab WAJIB memiliki minimal 2 suara pra-render (laki-laki dan perempuan) (§2, §5.5, §9.2).",
                "Format audio WAJIB Opus/AAC 32–48 kbps untuk menjaga ukuran paket (§5.5).",
                "Periksa ToS cloud TTS terkait hak redistribusi audio (§3.2)."
            ],
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-5",
            title="Konten Level 0 (kana): audio, goresan",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Menyusun seluruh konten Level 0 (Hiragana & Katakana) lengkap dengan audio 2 suara, goresan KanjiVG, facet pengenalan & penulisan, serta tinjauan manusia 100%.",
            acuan="§3.1 (Level 0 Kana), §3.3 (Hierarki konten), §3.4 (Facet kana), §9.1, §9.2",
            input_data="Dataset karakter Hiragana & Katakana, goresan KanjiVG, generator audio M2-4.",
            output_data="Dataset YAML kurikulum Level 0 di `content/level0/` dengan status `human_reviewed`.",
            langkah=[
                "Susun silabus Level 0 lengkap: Hiragana dan Katakana standar (46 karakter masing-masing), dakuten, handakuten, yōon (kombinasi), serta konsep mora dasar (§3.1).",
                "Petakan SVG urutan goresan KanjiVG untuk setiap karakter kana ke direktori asset strokes.",
                "Generate file audio pengucapan pra-render (suara perempuan dan laki-laki) untuk seluruh mora menggunakan pipeline M2-4.",
                "Definisikan facet SRS Level 0 sesuai §3.4: facet `recognition` (pilih romaji/suara) dan facet `writing` (latihan tulis tangan).",
                "Lakukan review manusia oleh reviewer bersertifikat (level N2 atau lebih tinggi); ubah status seluruh item menjadi `provenance: human_reviewed` dan isi atribut `reviewed_by` (§9.1 tahap 4).",
                "Jalankan validator `nihon-content validate` dan pastikan seluruh konten Level 0 lolos validasi 100%."
            ],
            tes=[
                "Validasi `nihon-content validate` pada `content/level0/` lulus tanpa warning.",
                "100% item memiliki audio f1 dan m1 serta SVG goresan yang valid.",
                "100% item memiliki atribut `provenance: human_reviewed`."
            ],
            observability=[
                "Laporan cakupan konten menunjukkan penguasaan 100% karakter kana terverifikasi."
            ],
            out_of_scope=[
                "Komponen UI kanvas tulisan tangan di Flutter (dikerjakan di M3-9).",
                "Penyusunan konten N5 (dikerjakan di M2-6)."
            ],
            aturan_ketat=[
                "100% item kana WAJIB bertanda `provenance: human_reviewed` (§9.1 tahap 4).",
                "DILARANG mempublikasikan item berkode `llm_draft` (§3.2, §9.1)."
            ],
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-6a",
            title="Kurasi Silabus N5 & Penyusunan Struktur Unit/Lesson",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Mengurasi daftar kosakata (~800), kanji (~100), dan tata bahasa N5 serta menyusun struktur Unit dan Lesson sesuai hierarki pedagogis produk.",
            acuan="§3.1 (Target N5), §3.3 (Hierarki konten: Unit -> Lesson), §3.4 (Tipe item & facet)",
            input_data="Kolam kandidat `content/_pool/`, daftar frekuensi Tanos & wordfreq.",
            output_data="File silabus dan kerangka unit/lesson di `content/n5/` (`units.yaml`, `lessons.yaml`).",
            langkah=[
                "Pilih sekitar 800 kosakata target N5 dan sekitar 100 kanji N5 dari `content/_pool` berdasarkan kriteria frekuensi leksikal dan estimasi kurikulum JLPT N5 (§3.1).",
                "Pilih pola tata bahasa dasar N5 (salam, angka, waktu, partikel dasar, struktur kalimat dasar `XはYです`, dsb.).",
                "Organisasikan konten ke dalam struktur Unit bertema (misal: Perkenalan Diri, Belanja, Waktu & Arah) (§3.3).",
                "Rancang setiap Unit agar memuat: 1 Lesson Kosakata (8 item), 1 Lesson Kanji (4 item kanji-in-context yang muncul pada kosakata unit), 1 Lesson Tata Bahasa (2 pola), 1 Reading singkat, dan 1 Listening (§3.3).",
                "Pastikan prinsip kanji-in-context terpenuhi: kanji hanya diajarkan setelah kata yang memakainya diperkenalkan (§3.3)."
            ],
            tes=[
                "Unit test: verifikasi jumlah total kosakata mendekati 800 item dan kanji mendekati 100 item.",
                "Unit test: verifikasi struktur lesson mengikuti aturan 8 vocab, 4 kanji, 2 grammar per unit.",
                "Unit test: verifikasi kanji tidak diajarkan sebelum kosakata yang memuatnya."
            ],
            observability=[
                "Laporan ringkasan silabus N5 mencakup jumlah unit, lesson, dan distribusi materi."
            ],
            out_of_scope=[
                "Enrichment kalimat contoh dan audio (dikerjakan di M2-6b).",
                "Review manusia akhir (dikerjakan di M2-6c)."
            ],
            aturan_ketat=[
                "Prinsip kanji-in-context WAJIB dipatuhi (§3.3).",
                "Struktur unit dan lesson wajib sesuai formula §3.3 (8 vocab, 4 kanji, 2 pola grammar).",
                "DILARANG menyalin silabus atau soal dari buku berhak cipta (Genki, Minna no Nihongo, dsb., §0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-6 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-6b",
            title="Enrichment Konten N5 (Contoh, Tokenisasi, Furigana & Audio)",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Melengkapi seluruh item N5 dengan contoh kalimat Tatoeba, tokenisasi Sudachi, anotasi segmen furigana, draf mnemonik, dan audio pra-render Opus.",
            acuan="§3.2 (Sudachi/UniDic), §5.5 (Furigana segmentasi), §9.1 tahap 3 (Enrichment), §9.2 (Contoh item YAML sumber)",
            input_data="Silabus N5 dari M2-6a, kolam kalimat Tatoeba, generator TTS M2-4.",
            output_data="File item YAML lengkap di `content/n5/items/` dan aset audio di `content/assets/audio/n5/`.",
            langkah=[
                "Padankan setiap kosakata N5 dengan minimal 1 kalimat contoh Tatoeba yang mayoritas katanya berada pada level N5 atau lebih rendah (§9.1 tahap 3).",
                "Jalankan tokenisasi Sudachi/UniDic secara offline pada waktu build (bukan saat runtime, §3.2) untuk memecah teks kalimat dan kata.",
                "Bentuk segmentasi furigana terstruktur `[{t: '漢字', r: 'かんじ'}]` pada teks Jepang kata dan contoh kalimat (§5.5, §9.2).",
                "Tambahkan arti dwibahasa (Indonesia `id` dan Inggris `en`) untuk setiap item (§1, §9.2).",
                "Sediakan draf mnemonik singkat kanji (jika draf dibuat bantuan LLM, tandai `provenance: llm_draft`, §3.2, §9.1).",
                "Generate file audio neural TTS pra-render 2 suara (f1 dan m1) format Opus 32–48 kbps untuk seluruh kosakata dan kalimat contoh N5 menggunakan pipeline M2-4."
            ],
            tes=[
                "Unit test: validasi konsistensi furigana terhadap bacaan kana pada 100% item N5.",
                "Unit test: setiap item vocab memiliki minimal 1 file audio valid dan 1 kalimat contoh.",
                "Verifikasi format YAML sesuai contoh schema §9.2."
            ],
            observability=[
                "Log proses enrichment mencatat total kata diproses, rasio kecocokan furigana, dan file audio terbit."
            ],
            out_of_scope=[
                "Verifikasi manusia tanda tangan N2 (dikerjakan di M2-6c).",
                "Konten N4/N3 (dikerjakan di M6-2)."
            ],
            aturan_ketat=[
                "Tokenisasi Sudachi HANYA dijalankan saat build offline, BUKAN di runtime aplikasi mobile (§3.2).",
                "Furigana WAJIB disimpan dalam bentuk segmentasi data `[{t, r}]`, dilarang menghitung bacaan saat runtime (§5.5, §16.3).",
                "Item hasil draf LLM wajib diberi tanda `provenance: llm_draft` sebelum direview manusia (§3.2, §9.1)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-6 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        ),
        IssueSpec(
            id="M2-6c",
            title="Tinjauan Manusia Konten N5 (Human Review)",
            milestone="M2 — Content Pipeline dan Konten Awal",
            milestone_num=3,
            size="M",
            area="content",
            tujuan="Melakukan tinjauan manusia komprehensif oleh peninjau berkualifikasi minimal level N2 terhadap 100% item N5 dan memvalidasi kelulusan CI.",
            acuan="§3.2 (Aturan review manusia), §9.1 tahap 4 & 5 (Review & Validasi), §15 (M2-6)",
            input_data="Item konten N5 hasil enrichment M2-6b.",
            output_data="Dataset konten N5 di `content/n5/` dengan status `human_reviewed` 100% dan laporan kelulusan CI validator.",
            langkah=[
                "Lakukan peninjauan menyeluruh terhadap seluruh kosakata (~800), kanji (~100), penjelasan tata bahasa, arti dwibahasa, furigana, dan mnemonik oleh reviewer dengan kualifikasi JLPT N2 atau penutur asli (§3.2, §9.1 tahap 4).",
                "Koreksi kesalahan penerjemahan, ketidaktepatan furigana, atau kejanggalan kalimat contoh.",
                "Ubah atribut `provenance` dari `llm_draft` menjadi `human_reviewed` dan cantumkan identitas peninjau pada atribut `reviewed_by: reviewer_id` (§9.1, §9.2).",
                "Jalankan `nihon-content validate`: pastikan nol item bertanda `llm_draft` dan seluruh aturan validasi integritas terpenuhi.",
                "Bangun paket rilis N5 awal (`nihon-content build`) dan verifikasi kepatuhan anggaran ukuran zip (§9.3)."
            ],
            tes=[
                "Eksekusi CI `nihon-content validate` sukses 100% pada dataset N5.",
                "Pemeriksaan otomatis membuktikan 100% item N5 berstatus `human_reviewed` tanpa ada `llm_draft` tersisa.",
                "Verifikasi ketiadaan materi proprietary yang melanggar hak cipta (§0 Aturan 5)."
            ],
            observability=[
                "Laporan cakupan konten memvalidasi 100% target kurikulum N5 siap rilis."
            ],
            out_of_scope=[
                "Kurasi dan review level N4/N3 (dikerjakan di M6-2).",
                "Distribusi paket ke CDN (dikerjakan di M2-3)."
            ],
            aturan_ketat=[
                "Item `llm_draft` DILARANG KERAS dipublikasikan (§3.2, §9.1 tahap 4).",
                "Reviewer WAJIB berkualifikasi minimal level N2 atau penutur asli (§3.2, §15).",
                "DILARANG menyalin dari buku teks berhak cipta (Minna no Nihongo, Genki, dsb., §0 Aturan 5)."
            ],
            catatan_keputusan="Task ini merupakan pecahan dari task besar M2-6 sesuai arahan §15.",
            labels=["M2: Content Pipeline", "size:M", "area:content"]
        )
    ]
