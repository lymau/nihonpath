# [ADR-0000] Judul Keputusan Arsitektur

- **Status:** [Draft | Proposed | Accepted | Rejected | Deprecated | Superseded by ADR-xxxx]
- **Tanggal:** YYYY-MM-DD
- **Pembuat / Kontributor:** [Nama Engineer / AI Implementer]
- **Bagian Dokumen Acuan:** [§X.X Bab Dokumen Rancangan Teknis]
- **Issue Terkait:** [Link atau Nomor GitHub Issue, misal: #7]

---

## Konteks

Jelaskan latar belakang masalah, batasan teknis atau bisnis, dan kondisi saat keputusan ini perlu diambil.

- Apa masalah arsitektural spesifik yang ingin diselesaikan?
- Apa faktor pendorong keputusan (*decision drivers*):
  - Kebutuhan NFR (misal: cold start < 2s, latensi sync p95 < 500ms, offline-first).
  - Keamanan dan privasi (§0 Aturan 7, §12).
  - Skalabilitas dan keandalan (§11).
  - Kebijakan dependency atau lisensi open source (§0 Aturan 5, §3.2).

---

## Pilihan Keputusan

Daftar opsi atau alternatif arsitektur yang dipertimbangkan beserta analisis kelebihan dan kekurangannya.

### Opsi 1: [Nama Pendekatan / Teknologi A]
- **Deskripsi:** Penjelasan ringkas pendekatan atau solusi yang diusulkan.
- **Kelebihan:**
  - Kelebihan 1
  - Kelebihan 2
- **Kekurangan:**
  - Kekurangan 1
  - Kekurangan 2

### Opsi 2: [Nama Pendekatan / Teknologi B]
- **Deskripsi:** Penjelasan ringkas pendekatan atau solusi alternatif.
- **Kelebihan:**
  - Kelebihan 1
  - Kelebihan 2
- **Kekurangan:**
  - Kekurangan 1
  - Kekurangan 2

### Opsi Alternatif / Fallback (Opsi B sesuai §0 Aturan 8)
- **Deskripsi:** Opsi fallback jika spesifikasi utama terkendala dependensi atau kompatibilitas platform.
- **Analisis Kompromi:** Alasan dan kondisi aktivasi opsi B ini.

---

## Keputusan Terpilih

Jelaskan opsi yang dipilih dan justifikasi spesifik mengapa opsi tersebut dipilih dibandingkan alternatif lain.

- **Pilihan:** Opsi X ([Nama Pendekatan])
- **Justifikasi:** Mengapa opsi ini paling optimal memenuhi konteks dan batasan di atas.
- **Implementasi:**
  - Modul atau repositori yang terdampak (`apps/api`, `apps/mobile`, `packages/contracts`, `infra/terraform`).
  - Kontrak API atau schema yang perlu diperbarui (§0 Aturan 2).
  - Konfigurasi atau environment variables baru.

---

## Konsekuensi

Dampak dari keputusan terpilih terhadap sistem, tim pengembang, dan operasional.

### Konsekuensi Positif
- Peningkatan performa, efisiensi resource, atau keterbacaan kode.
- Pemenuhan target NFR dan kriteria Definition of Done (DoD).

### Konsekuensi Negatif
- Biaya operasional tambahan atau peningkatan kompleksitas arsitektur.
- Keterbatasan teknis (*technical debt* atau trade-off) yang disadari dan diterima.

### Risiko dan Mitigasi
- **Risiko:** Risiko potensial yang mungkin terjadi di masa depan.
- **Mitigasi:** Langkah antisipasi atau tindakan pencegahan yang disiapkan.

---

## Kepatuhan dan Validasi

- [ ] Sesuai dengan batasan arsitektur §0 (tidak ada PII di log, lisensi valid, clock interface).
- [ ] Kontrak API / schema diperbarui sebelum kode implementasi (§0 Aturan 2).
- [ ] Unit test dan skrip verifikasi otomatis tersedia.
- [ ] Dicatat dalam `docs/decision-log.md` (§0 Aturan 1).
