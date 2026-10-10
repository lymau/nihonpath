"""Milestone M7: N2–N1 dan Mock Test issues."""

from typing import List
from .common import IssueSpec

def get_m7_issues() -> List[IssueSpec]:
    return [
        IssueSpec(
            id="M7-1",
            title="Engine Mock Test bergaya JLPT",
            milestone="M7 — N2–N1 dan Mock Test",
            milestone_num=8,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan engine mock test bergaya JLPT pada layar /mocktest/:id dengan timer ujian, 3 seksi tes terstruktur, skor estimasi persentase dengan disclaimer eksplisit, dan sinkronisasi test_attempts.",
            acuan="§3.7 (Mock test bergaya JLPT), §5.3 (/mocktest/:id), §6.2 (Tabel test_attempts), §16.3 (Disclaimer skor & batasan resmi)",
            input_data="Data paket ujian `pack-*-tests-v1.zip` dari content pipeline.",
            output_data="Layar `/mocktest/:id` di `apps/mobile/lib/features/mocktest/`, engine test di `apps/mobile/lib/domain/tests/`, dan test attempt outbox sync.",
            langkah=[
                "Implementasikan engine ujian di `apps/mobile/lib/domain/tests/`:",
                "  - Struktur 3 seksi standar ujian JLPT (§3.7): 文字・語彙・文法 (Kosakata & Tata Bahasa), 読解 (Membaca), dan 聴解 (Mendengarkan).",
                "  - Timer hitung mundur ujian yang ketat sesuai batas waktu level yang diuji.",
                "  - Manajemen state jawaban pengguna, navigasi antar butir soal, dan penanda ragu-ragu.",
                "Implementasikan layar antarmuka `/mocktest/:id` menggunakan Forui widgets (`FScaffold`, `FCard`, `FButton`) (§5.2.1).",
                "Implementasikan Layar Hasil Ujian (§3.7, §16.3):",
                "  - Hitung persentase jawaban benar per seksi dan total.",
                "  - WAJIB SERTAKAN DISCLAIMER EKSPLISIT (§3.7, §16.3): skor resmi JLPT menggunakan skala terekuivalensi (scaled scores / Item Response Theory); aplikasi ini hanya menampilkan estimasi persentase dan TIDAK mengklaim atau menjamin kelulusan resmi JLPT.",
                "Simpan riwayat hasil ujian ke tabel lokal Drift `test_attempts` (id, test_id, started_at, finished_at, score_json) dan masukkan entri ke outbox sync (§6.2, §7.3).",
                "Pancarkan event analitik: `mocktest_completed` (§10.6)."
            ],
            tes=[
                "Unit test: engine timer menghitung mundur dan otomatis mengakhiri ujian saat waktu habis.",
                "Unit test: kalkulasi skor persentase benar per seksi akurat.",
                "Widget test: layar hasil menampilkan disclaimer resmi bahwa skor merupakan estimasi dan bukan sertifikat resmi JLPT.",
                "Integration test: data percobaan tersimpan di tabel `test_attempts` dan dicatat di outbox."
            ],
            observability=[
                "Event analitik `mocktest_completed` mencatat durasi, skor persentase, dan ID tes."
            ],
            out_of_scope=[
                "Penerbitan sertifikat resmi (aplikasi hanya alat latihan belajar mandiri)."
            ],
            aturan_ketat=[
                "Hasil ujian WAJIB menampilkan disclaimer jelas bahwa skor adalah estimasi persentase, bukan skor resmi JLPT (§3.7, §16.3).",
                "DILARANG mengklaim peluang lulus JLPT tanpa data valid (§2, §16.3, §17).",
                "DILARANG menyalin soal resmi JLPT yang berhak cipta (§0 Aturan 5)."
            ],
            labels=["M7: N2-N1 & Mock Test", "size:M", "area:mobile"]
        ),
        IssueSpec(
            id="M7-2",
            title="Konten N2 dan N1",
            milestone="M7 — N2–N1 dan Mock Test",
            milestone_num=8,
            size="L",
            area="content",
            tujuan="Mengurasi dan melengkapi seluruh kurikulum tingkat lanjut Level N2 (~6.000 kata, ~1.000 kanji) dan Level N1 (~10.000 kata, ~2.000 kanji) dengan tinjauan manusia 100%.",
            acuan="§3.1 (Target N2 & N1), §3.2 (Lisensi & LLM), §3.3, §9.1, §9.3",
            input_data="Kolam kandidat `content/_pool/`, generator TTS audio M2-4.",
            output_data="Dataset kurikulum Level N2 dan N1 di `content/n2/` dan `content/n1/` dengan status `human_reviewed` 100%.",
            langkah=[
                "Kurasi materi Level N2 (§3.1): target kumulatif ~6.000 kosakata dan ~1.000 kanji; fokus pada teks umum dan berita, bahasa formal, dan kolokasi kata kerja/frasa.",
                "Kurasi materi Level N1 (§3.1): target kumulatif ~10.000 kosakata dan ~2.000 kanji; fokus pada teks abstrak, ekspresi sastra/formal, nuansa halus perbedaan pola tata bahasa.",
                "Organisasikan konten ke dalam struktur Unit dan Lesson tematik sesuai formula pedagogis produk (§3.3).",
                "Enrichment: padankan kalimat contoh Tatoeba, jalankan tokenisasi build-time Sudachi, lengkapi segmen furigana terstruktur, dan generate audio neural TTS 2 suara format Opus (§9.1 tahap 3).",
                "Lakukan review manusia komprehensif oleh peninjau bersertifikat N1 atau penutur asli (§3.2, §9.1 tahap 4). Pastikan 100% item berstatus `provenance: human_reviewed` dengan atribut `reviewed_by` valid.",
                "Jalankan `nihon-content validate` dan build paket rilis `pack-2-*-v1.zip` dan `pack-1-*-v1.zip` serta verifikasi kepatuhan anggaran ukuran zip (§9.3)."
            ],
            tes=[
                "Validasi `nihon-content validate` lulus 100% pada dataset N2 dan N1.",
                "Pemeriksaan otomatis membuktikan 100% item berstatus `human_reviewed` tanpa ada materi draf LLM yang belum ditinjau.",
                "Verifikasi seluruh paket zip mematuhi anggaran ukuran §9.3."
            ],
            observability=[
                "Laporan cakupan konten memvalidasi ketercapaian target kumulatif N2 dan N1."
            ],
            out_of_scope=[
                "Pengembangan partner percakapan AI LLM (dikerjakan di fase 3 / M8-6)."
            ],
            aturan_ketat=[
                "100% item N2 dan N1 WAJIB bertanda `provenance: human_reviewed` (§9.1 tahap 4).",
                "Reviewer WAJIB berkualifikasi minimal N1 atau penutur asli (§3.2).",
                "DILARANG menyalin dari buku teks berhak cipta atau soal resmi JLPT (§0 Aturan 5)."
            ],
            catatan_keputusan="Task ini berukuran besar (L) dan mencakup rilis kurikulum tingkat lanjut N2 dan N1 sesuai roadmap §15 M7.",
            labels=["M7: N2-N1 & Mock Test", "size:L", "area:content"]
        ),
        IssueSpec(
            id="M7-3",
            title="Penambahan Facet Lanjutan SRS (Listening, Kanji Writing, Grammar Production)",
            milestone="M7 — N2–N1 dan Mock Test",
            milestone_num=8,
            size="M",
            area="mobile",
            tujuan="Mengimplementasikan facet kartu SRS fase 2: listening (audio -> arti), writing kanji (tulis tangan kanji on-device), dan production tata bahasa (penyusunan kalimat / ketik output).",
            acuan="§2 (Pelatihan fonetik & Output Swain), §3.4 (Facet ditunda ke fase 2), §5.5 (Tulisan tangan kanji)",
            input_data="Engine SRS klien M3-4 & M3-6, dataset kanji dan tata bahasa.",
            output_data="Facet handlers baru di `apps/mobile/lib/domain/srs/` dan komponen UI pendukung di `apps/mobile/lib/ui/widgets/`.",
            langkah=[
                "Implementasikan Facet `listening` untuk item kosakata (§3.4):",
                "  - Kartu memutar audio tanpa menampilkan teks Jepang terlebih dahulu;",
                "  - Pengguna diminta memilih atau mengetik arti (audio -> makna);",
                "  - Teks kanji dan furigana baru ditampilkan setelah pengguna menjawab.",
                "Implementasikan Facet `writing` untuk karakter kanji N5–N1 (§3.4, §5.5):",
                "  - Pengguna disajikan prompt makna kanji dan bacaan on/kun;",
                "  - Pengguna menulis karakter kanji pada `HandwritingCanvas` menggunakan ML Kit Digital Ink Recognition on-device;",
                "  - Animasi goresan KanjiVG ditampilkan sebagai referensi feedback pasca-menjawab.",
                "Implementasikan Facet `production` untuk tata bahasa (§3.4):",
                "  - Latihan menyusun blok kata menjadi kalimat utuh atau mengetik konjugasi kata kerja yang tepat dalam konteks kalimat.",
                "Pastikan penomoran `card_id` deterministik tetap berlaku: `card_id = UUIDv5(NAMESPACE_CARD, item_external_key + ':' + facet)` sehingga facet baru tidak menduplikasi kartu lama (§3.4, §6.1)."
            ],
            tes=[
                "Unit test: pembentukan card_id deterministik UUIDv5 untuk facet listening, writing, dan production.",
                "Widget test: kartu facet listening memutar audio dan menyembunyikan teks sebelum jawaban dinilai.",
                "Widget test: kanvas tulisan tangan kanji memvalidasi input goresan pengguna secara on-device."
            ],
            observability=[
                "Log review mencatat `exercise_type` baru sesuai facet yang dikerjakan (§6.2, §10.2)."
            ],
            out_of_scope=[
                "Penilaian ucapan suara pengguna (speech recognition real-time dilarang di MVP sesuai §1 Non-goals)."
            ],
            aturan_ketat=[
                "card_id WAJIB deterministik UUIDv5 dari key + facet (§3.4, §6.1).",
                "Pengenalan tulisan tangan kanji WAJIB on-device via ML Kit (§5.5).",
                "Satu review tetap WAJIB satu transaksi atomik SQLite (log + kartu + outbox) (§5.4, §16.3)."
            ],
            labels=["M7: N2-N1 & Mock Test", "size:M", "area:mobile"]
        )
    ]
