"""Main script to generate Markdown issue files and publish to GitHub via gh CLI."""

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List

# Reconfigure stdout and stderr to handle UTF-8 characters on Windows console
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if sys.stderr.encoding != 'utf-8':
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

from .common import IssueSpec
from .milestone_m0 import get_m0_issues
from .milestone_m1 import get_m1_issues
from .milestone_m2 import get_m2_issues
from .milestone_m3 import get_m3_issues
from .milestone_m4 import get_m4_issues
from .milestone_m5 import get_m5_issues
from .milestone_m6 import get_m6_issues
from .milestone_m7 import get_m7_issues
from .milestone_m8 import get_m8_issues

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DOCS_ISSUES_DIR = WORKSPACE_ROOT / "docs" / "issues"

MILESTONES_DEF = [
    {"num": 1, "title": "M0 — Fondasi", "desc": "Fondasi monorepo, kontrak OpenAPI, docker-compose lokal, Terraform dev, dan panduan"},
    {"num": 2, "title": "M1 — Backend Inti", "desc": "Backend NestJS, Kysely DB, auth guest/refresh/OIDC, modul sync push/pull, metrik, partisi"},
    {"num": 3, "title": "M2 — Content Pipeline dan Konten Awal", "desc": "Content CLI ingest JMdict/KANJIDIC2/KanjiVG/Tatoeba, validator, builder paket zip, TTS audio, kurikulum Level 0 & N5"},
    {"num": 4, "title": "M3 — Flutter Inti (Offline)", "desc": "Flutter mobile feature-first, Forui UI preset ajeneb, Drift SQLite, pack manager, FSRS-6 scheduler, queue builder, review & lesson alur, kana"},
    {"num": 5, "title": "M4 — Auth dan Sync Klien", "desc": "Client auth, Dio interceptor, Outbox Drift, SyncClient loop, Merge engine, pemicu workmanager, fault injection"},
    {"num": 6, "title": "M5 — Observability, Hardening, Beta Tertutup", "desc": "Sentry, PostHog, Dashboard Grafana, burn rate alert, k6 load/soak/chaos test, OWASP MASVS L1, disaster recovery PITR, beta"},
    {"num": 7, "title": "M6 — Rilis v1", "desc": "RevenueCat billing paywall, konten N4 & N3, reading & listening, kepatuhan store/atribusi, staged rollout"},
    {"num": 8, "title": "M7 — N2–N1 dan Mock Test", "desc": "Engine mock test bergaya JLPT, kurikulum N2 & N1, facet lanjutan SRS"},
    {"num": 9, "title": "M8 — Fase 3", "desc": "FSRS server optimizer, shadowing, lazy backfill, delta packs, tablet widgets, partner percakapan LLM"}
]

LABELS_DEF = [
    # Milestones
    {"name": "M0: Fondasi", "color": "0075ca", "desc": "Milestone M0: Fondasi Proyek"},
    {"name": "M1: Backend Inti", "color": "1d76db", "desc": "Milestone M1: Backend Inti"},
    {"name": "M2: Content Pipeline", "color": "008672", "desc": "Milestone M2: Content Pipeline & Konten"},
    {"name": "M3: Flutter Inti", "color": "5319e7", "desc": "Milestone M3: Flutter Inti Offline"},
    {"name": "M4: Auth & Sync", "color": "7057ff", "desc": "Milestone M4: Auth dan Sync Klien"},
    {"name": "M5: Observability & Hardening", "color": "b60205", "desc": "Milestone M5: Observability, Hardening, Beta"},
    {"name": "M6: Rilis v1", "color": "0e8a16", "desc": "Milestone M6: Rilis Produksi v1"},
    {"name": "M7: N2-N1 & Mock Test", "color": "fbca04", "desc": "Milestone M7: N2-N1 dan Mock Test"},
    {"name": "M8: Fase 3", "color": "e99695", "desc": "Milestone M8: Fase 3 Berdasarkan Data"},
    # Sizes
    {"name": "size:S", "color": "c2e0c6", "desc": "Ukuran S: sampai 1 hari"},
    {"name": "size:M", "color": "fef2c0", "desc": "Ukuran M: 2 sampai 4 hari"},
    {"name": "size:L", "color": "f9d0c4", "desc": "Ukuran L: lebih dari 4 hari"},
    # Areas
    {"name": "area:infra", "color": "bfdadc", "desc": "Infrastruktur, Docker, CI/CD, Terraform"},
    {"name": "area:backend", "color": "1d76db", "desc": "Backend NestJS, Kysely, Postgres, Redis"},
    {"name": "area:content", "color": "bfd4f2", "desc": "Content CLI, kurasi silabus, data bahasa"},
    {"name": "area:mobile", "color": "d4c5f9", "desc": "Aplikasi Flutter, Drift, Riverpod, UI Forui"},
    {"name": "area:security-ops", "color": "e11d48", "desc": "Keamanan, audit MASVS, legal, runbook"},
    {"name": "area:qa", "color": "c5def5", "desc": "Testing beban, soak test, chaos, beta test"}
]

def collect_all_issues() -> List[IssueSpec]:
    all_issues = []
    all_issues.extend(get_m0_issues())
    all_issues.extend(get_m1_issues())
    all_issues.extend(get_m2_issues())
    all_issues.extend(get_m3_issues())
    all_issues.extend(get_m4_issues())
    all_issues.extend(get_m5_issues())
    all_issues.extend(get_m6_issues())
    all_issues.extend(get_m7_issues())
    all_issues.extend(get_m8_issues())
    return all_issues

def write_issue_markdown_files(issues: List[IssueSpec]):
    DOCS_ISSUES_DIR.mkdir(parents=True, exist_ok=True)
    
    print(f"Writing {len(issues)} markdown files into {DOCS_ISSUES_DIR}...")
    for issue in issues:
        filename = f"{issue.id}.md"
        filepath = DOCS_ISSUES_DIR / filename
        content = issue.to_markdown()
        filepath.write_text(content, encoding="utf-8")
        
    # Write master README.md
    readme_path = DOCS_ISSUES_DIR / "README.md"
    readme_lines = [
        "# NihonPath — Daftar GitHub Issues & Task Breakdown",
        "",
        "Dokumen ini memuat daftar lengkap seluruh GitHub Issue yang dipartisi secara ketat berdasarkan spesifikasi teknis `NihonPath — Rancangan Teknis Aplikasi Belajar Bahasa Jepang N5–N1.md`.",
        "",
        f"**Total Issue:** {len(issues)} tasks  ",
        "**Aturan Eksekusi:** Satu issue = Satu PR kecil (< ±400 baris diff) sesuai Definition of Done (DoD) §0.",
        "",
        "---",
        ""
    ]
    
    current_ms = None
    for issue in issues:
        if issue.milestone != current_ms:
            current_ms = issue.milestone
            readme_lines.append(f"\n## {current_ms}\n")
            readme_lines.append("| ID | Judul | Area | Ukuran | Acuan | File |")
            readme_lines.append("| --- | --- | --- | --- | --- | --- |")
        
        file_link = f"[{issue.id}.md](./{issue.id}.md)"
        readme_lines.append(f"| `{issue.id}` | {issue.title} | `{issue.area}` | `{issue.size}` | {issue.acuan} | {file_link} |")
        
    readme_path.write_text("\n".join(readme_lines), encoding="utf-8")
    print(f"Master index generated at {readme_path}")

def setup_github_labels():
    print("Setting up GitHub labels...")
    for label in LABELS_DEF:
        cmd = [
            "gh", "label", "create", label["name"],
            "--color", label["color"],
            "--description", label["desc"],
            "--force"
        ]
        res = subprocess.run(cmd, cwd=str(WORKSPACE_ROOT), capture_output=True, text=True)
        if res.returncode == 0:
            print(f"  [OK] Label: {label['name']}")
        else:
            print(f"  [FAIL] Label: {label['name']}: {res.stderr.strip()}")

def setup_github_milestones() -> Dict[str, str]:
    print("Setting up GitHub milestones...")
    # Fetch existing milestones
    res = subprocess.run(["gh", "api", "repos/lymau/nihonpath/milestones"], cwd=str(WORKSPACE_ROOT), capture_output=True, text=True)
    existing_map = {}
    if res.returncode == 0:
        try:
            existing_list = json.loads(res.stdout)
            for item in existing_list:
                existing_map[item["title"]] = str(item["title"])
        except Exception:
            pass

    for ms in MILESTONES_DEF:
        if ms["title"] in existing_map:
            print(f"  [EXISTS] Milestone: {ms['title']}")
        else:
            create_cmd = [
                "gh", "api", "repos/lymau/nihonpath/milestones",
                "-f", f"title={ms['title']}",
                "-f", f"description={ms['desc']}"
            ]
            c_res = subprocess.run(create_cmd, cwd=str(WORKSPACE_ROOT), capture_output=True, text=True)
            if c_res.returncode == 0:
                print(f"  [CREATED] Milestone: {ms['title']}")
            else:
                print(f"  [FAIL] Milestone: {ms['title']}: {c_res.stderr.strip()}")

def publish_github_issues(issues: List[IssueSpec]):
    print(f"Checking existing issues on GitHub...")
    res = subprocess.run(["gh", "issue", "list", "--limit", "150", "--json", "number,title"], cwd=str(WORKSPACE_ROOT), capture_output=True, text=True)
    existing_ids = set()
    if res.returncode == 0:
        try:
            data = json.loads(res.stdout)
            for item in data:
                title = item["title"]
                # extract ID like [M0-1]
                if title.startswith("[") and "]" in title:
                    id_part = title[1:title.index("]")]
                    existing_ids.add(id_part)
        except Exception as e:
            print(f"Warning parsing existing issues: {e}")

    print(f"Found {len(existing_ids)} existing issue IDs: {sorted(list(existing_ids))}")
    for idx, issue in enumerate(issues, 1):
        filename = f"{issue.id}.md"
        filepath = DOCS_ISSUES_DIR / filename
        title = f"[{issue.id}] {issue.title}"
        
        if issue.id in existing_ids:
            print(f"  [{idx}/{len(issues)}] Skipping already created: [{issue.id}]")
            continue

        cmd = [
            "gh", "issue", "create",
            "--title", title,
            "--body-file", str(filepath),
            "--milestone", issue.milestone
        ]
        for l in issue.labels:
            cmd.extend(["--label", l])
            
        print(f"  [{idx}/{len(issues)}] Creating issue: {title} ...", end=" ", flush=True)
        res = subprocess.run(cmd, cwd=str(WORKSPACE_ROOT), capture_output=True, text=True)
        if res.returncode == 0:
            issue_url = res.stdout.strip()
            print(f"DONE -> {issue_url}")
        else:
            print(f"ERROR: {res.stderr.strip()}")

def main():
    issues = collect_all_issues()
    print(f"Total partitioned issues defined: {len(issues)}")
    
    # 1. Write markdown files to docs/issues/
    write_issue_markdown_files(issues)
    
    # 2. Setup GitHub labels (already completed)
    # setup_github_labels()
    
    # 3. Setup GitHub milestones (already completed)
    # setup_github_milestones()
    
    # 4. Publish issues to GitHub
    publish_github_issues(issues)

if __name__ == "__main__":
    main()
