"""Common utilities and data definitions for NihonPath issue generation."""

from dataclasses import dataclass, field
from typing import List, Optional

@dataclass
class IssueSpec:
    id: str
    title: str
    milestone: str
    milestone_num: int
    size: str  # S, M, L
    area: str  # infra, backend, content, mobile, security-ops, qa
    tujuan: str
    acuan: str
    input_data: str
    output_data: str
    langkah: List[str]
    tes: List[str]
    observability: List[str]
    out_of_scope: List[str]
    aturan_ketat: List[str]
    catatan_keputusan: Optional[str] = None
    labels: List[str] = field(default_factory=list)

    def to_markdown(self) -> str:
        md = []
        md.append(f"# [{self.id}] {self.title}\n")
        md.append(f"**Milestone:** {self.milestone}  ")
        md.append(f"**Estimasi Ukuran:** {self.size}  ")
        md.append(f"**Area:** `{self.area}`  \n")
        md.append("---\n")
        
        md.append("## Task Brief\n")
        md.append(f"- **Task ID / Judul:** `{self.id}` — {self.title}")
        md.append(f"- **Tujuan:** {self.tujuan}")
        md.append(f"- **Bagian Dokumen Acuan:** {self.acuan}")
        md.append(f"- **Input:** {self.input_data}")
        md.append(f"- **Output:** {self.output_data}\n")
        
        md.append("### Langkah Implementasi")
        for i, step in enumerate(self.langkah, 1):
            md.append(f"{i}. {step}")
        md.append("")
        
        md.append("### Tes yang Harus Ada")
        for t in self.tes:
            md.append(f"- [ ] {t}")
        md.append("")
        
        md.append("### Observability yang Harus Ada")
        for o in self.observability:
            md.append(f"- [ ] {o}")
        md.append("")
        
        md.append("### Di Luar Cakupan (Out of Scope)")
        for os in self.out_of_scope:
            md.append(f"- {os}")
        md.append("")
        
        md.append("### Aturan Teknis Ketat & Larangan (§0, §4.3, §10, §12, §16)")
        for rule in self.aturan_ketat:
            md.append(f"- ⚠️ {rule}")
        md.append("")
        
        if self.catatan_keputusan:
            md.append("### Catatan Keputusan / Asumsi")
            md.append(self.catatan_keputusan)
            md.append("")
            
        md.append("### Definition of Done (DoD) (§0 Aturan 4)")
        md.append("- [ ] Seluruh kode implementasi tuntas sesuai spesifikasi di atas.")
        md.append("- [ ] Seluruh unit test & integration test yang disyaratkan lulus 100%.")
        md.append("- [ ] Linter dan formatter lulus tanpa error maupun warning.")
        md.append("- [ ] Log, metrik, dan tracing terpasang sesuai standar §10 tanpa kebocoran PII.")
        md.append("- [ ] Dokumentasi singkat atau `docs/decision-log.md` diperbarui jika ada keputusan teknis.")
        md.append("- [ ] Tidak ada `TODO` tersisa tanpa nomor issue aktif.")
        md.append("- [ ] Ukuran diff PR kurang dari ±400 baris diff (di luar file hasil generate kode).")
        
        return "\n".join(md)
