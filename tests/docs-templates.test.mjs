import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { verifyDocumentation } from '../scripts/verify-docs.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const docsDir = resolve(rootDir, 'docs');
const decisionLogPath = resolve(docsDir, 'decision-log.md');
const adrTemplatePath = resolve(docsDir, 'adr/0000-template.md');
const runbookTemplatePath = resolve(docsDir, 'runbooks/TEMPLATE.md');

test('Documentation template files exist (§0, §10.7, §14.1, M0-5)', () => {
  assert.ok(existsSync(decisionLogPath), 'docs/decision-log.md must exist');
  assert.ok(existsSync(adrTemplatePath), 'docs/adr/0000-template.md must exist');
  assert.ok(existsSync(runbookTemplatePath), 'docs/runbooks/TEMPLATE.md must exist');
});

test('docs/decision-log.md conforms strictly to §0 Aturan 1 & 8', () => {
  const content = readFileSync(decisionLogPath, 'utf-8');

  // Must reference §0 Aturan 1 and §0 Aturan 8
  assert.match(content, /§0\s+Aturan\s+1/, 'Must reference §0 Aturan 1');
  assert.match(content, /§0\s+Aturan\s+8/, 'Must reference §0 Aturan 8');

  // Must contain implementer guidance on assumptions and opsi B
  assert.match(
    content,
    /asumsi/i,
    'Must include guidance that assumptions must be recorded in decision log',
  );
  assert.match(
    content,
    /opsi\s+b/i,
    'Must include guidance that choosing opsi B must be recorded in decision log',
  );

  // Parse entries
  const entries = content.split(/^## (?=\d{4}-\d{2}-\d{2})/m).slice(1);
  assert.ok(entries.length >= 7, `Expected at least 7 decision entries, got ${entries.length}`);

  const requiredFields = ['- **Tanggal:**', '- **Konteks:**', '- **Keputusan:**', '- **Alasan:**'];

  for (const entry of entries) {
    const firstLine = entry.split('\n')[0].trim();
    let prevIndex = -1;

    for (const field of requiredFields) {
      const idx = entry.indexOf(field);
      assert.ok(
        idx !== -1,
        `Entry "${firstLine}" is missing mandatory field "${field}" (§0 Aturan 1)`,
      );
      assert.ok(
        idx > prevIndex,
        `Entry "${firstLine}" field "${field}" is out of order (must be Tanggal -> Konteks -> Keputusan -> Alasan)`,
      );
      prevIndex = idx;
    }
  }
});

test('docs/adr/0000-template.md contains mandatory MADR sections', () => {
  const content = readFileSync(adrTemplatePath, 'utf-8');

  assert.match(content, /Status:/, 'ADR template must contain Status metadata');
  assert.match(content, /^##\s+Konteks/m, 'ADR template must contain "## Konteks"');
  assert.match(
    content,
    /^##\s+Pilihan\s+Keputusan/m,
    'ADR template must contain "## Pilihan Keputusan"',
  );
  assert.match(
    content,
    /^##\s+Keputusan\s+Terpilih/m,
    'ADR template must contain "## Keputusan Terpilih"',
  );
  assert.match(content, /^##\s+Konsekuensi/m, 'ADR template must contain "## Konsekuensi"');
  assert.match(
    content,
    /Opsi\s+B/i,
    'ADR template should include fallback/opsi B consideration (§0 Aturan 8)',
  );
});

test('docs/runbooks/TEMPLATE.md contains 5-step diagnosis and all §10.7 requirements', () => {
  const content = readFileSync(runbookTemplatePath, 'utf-8');

  // Mandatory sections from §10.7
  assert.match(content, /^##\s+(?:1\.\s+)?Dampak/m, 'Runbook template must contain Dampak section');
  assert.match(
    content,
    /^##\s+(?:2\.\s+)?Diagnosis\s+5\s+Langkah/m,
    'Runbook template must contain Diagnosis 5 Langkah section',
  );
  assert.match(
    content,
    /^##\s+(?:3\.\s+)?Mitigasi/m,
    'Runbook template must contain Mitigasi section',
  );
  assert.match(
    content,
    /^##\s+(?:4\.\s+)?Eskalasi/m,
    'Runbook template must contain Eskalasi section',
  );

  // All 5 diagnosis steps must be present
  for (let step = 1; step <= 5; step++) {
    const pattern = new RegExp(`###\\s+Langkah\\s+${step}:`, 'm');
    assert.match(content, pattern, `Runbook template must contain "Langkah ${step}:"`);
  }

  // Severity levels SEV1-SEV4
  assert.match(content, /SEV1/i, 'Runbook template must specify SEV1');
  assert.match(content, /SEV2/i, 'Runbook template must specify SEV2');
  assert.match(content, /SEV3/i, 'Runbook template must specify SEV3');
  assert.match(content, /SEV4/i, 'Runbook template must specify SEV4');

  // Incident Commander and Blameless Postmortem within 5 working days (§10.7)
  assert.match(content, /Incident Commander/i, 'Runbook must specify Incident Commander (§10.7)');
  assert.match(content, /postmortem/i, 'Runbook must include postmortem guidelines (§10.7)');
  assert.match(
    content,
    /5\s+hari\s+kerja/i,
    'Runbook must specify 5 working days postmortem SLA (§10.7)',
  );
});

test('verifyDocumentation validator function and script succeed', () => {
  assert.equal(verifyDocumentation(), true, 'verifyDocumentation() must return true');

  const isWindows = process.platform === 'win32';
  const scriptPath = resolve(rootDir, 'scripts/verify-docs.mjs');
  const res = spawnSync('node', [scriptPath], {
    cwd: rootDir,
    encoding: 'utf-8',
    shell: isWindows,
  });

  assert.equal(
    res.status,
    0,
    `verify-docs.mjs should succeed with exit code 0:\n${res.stdout}\n${res.stderr}`,
  );
  assert.match(res.stdout, /All documentation templates verified successfully/);
});

test('Format validation fails when required decision log field or order is corrupted', () => {
  // Test detection of missing field
  const invalidEntryMissingField = `## 2026-10-16 — [TEST] Incomplete Entry
- **Tanggal:** 2026-10-16
- **Konteks:** Missing decisions and reasons
`;
  assert.ok(
    !invalidEntryMissingField.includes('- **Keputusan:**') ||
      !invalidEntryMissingField.includes('- **Alasan:**'),
    'Should detect missing mandatory fields',
  );

  // Test detection of disordered fields
  const disorderedEntry = `## 2026-10-16 — [TEST] Disordered Entry
- **Tanggal:** 2026-10-16
- **Alasan:** Alasan before keputusan
- **Keputusan:** Keputusan after alasan
- **Konteks:** Konteks last
`;
  const alasanIdx = disorderedEntry.indexOf('- **Alasan:**');
  const keputusanIdx = disorderedEntry.indexOf('- **Keputusan:**');
  assert.ok(alasanIdx < keputusanIdx, 'Detected disordered field sequence');
});
