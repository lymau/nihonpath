#!/usr/bin/env node

import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const docsDir = resolve(rootDir, 'docs');
const decisionLogPath = resolve(docsDir, 'decision-log.md');
const adrTemplatePath = resolve(docsDir, 'adr/0000-template.md');
const runbookTemplatePath = resolve(docsDir, 'runbooks/TEMPLATE.md');

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

function error(msg) {
  console.error(`[${new Date().toISOString()}] ERROR: ${msg}`);
}

export function verifyDocumentation() {
  log('Starting documentation templates verification (§0, §10.7, §14.1)...');
  let hasErrors = false;

  // 1. File existence
  const requiredFiles = [
    { path: decisionLogPath, name: 'docs/decision-log.md' },
    { path: adrTemplatePath, name: 'docs/adr/0000-template.md' },
    { path: runbookTemplatePath, name: 'docs/runbooks/TEMPLATE.md' },
  ];

  for (const { path, name } of requiredFiles) {
    if (!existsSync(path)) {
      error(`Missing required documentation file: ${name}`);
      hasErrors = true;
    } else {
      log(`✔ File exists: ${name}`);
    }
  }

  if (hasErrors) {
    return false;
  }

  // 2. Validate docs/decision-log.md
  log('Verifying docs/decision-log.md structure & entries (§0 Aturan 1 & 8)...');
  const decisionLogContent = readFileSync(decisionLogPath, 'utf-8');

  // Check guidelines for implementers
  if (!decisionLogContent.includes('§0 Aturan 1')) {
    error('docs/decision-log.md missing reference to §0 Aturan 1');
    hasErrors = true;
  }
  if (!decisionLogContent.includes('§0 Aturan 8')) {
    error('docs/decision-log.md missing reference to §0 Aturan 8');
    hasErrors = true;
  }
  if (!/opsi\s+b/i.test(decisionLogContent)) {
    error('docs/decision-log.md missing guidelines regarding Opsi B requirement');
    hasErrors = true;
  }
  if (!/asumsi/i.test(decisionLogContent)) {
    error('docs/decision-log.md missing guidelines regarding assumption logging');
    hasErrors = true;
  }

  // Parse decision entries: lines starting with '## YYYY-MM-DD'
  const entryHeaderRegex = /^## \d{4}-\d{2}-\d{2}.*$/gm;
  const entries = decisionLogContent.split(/^## (?=\d{4}-\d{2}-\d{2})/m);
  // First element before first entry is header/guidelines
  const headerSection = entries[0];
  const decisionEntries = entries.slice(1);

  if (decisionEntries.length === 0) {
    error('No decision entries found in docs/decision-log.md');
    hasErrors = true;
  } else {
    log(`✔ Found ${decisionEntries.length} decision entries in docs/decision-log.md`);
  }

  const requiredFields = [
    { key: '- **Tanggal:**', name: 'Tanggal' },
    { key: '- **Konteks:**', name: 'Konteks' },
    { key: '- **Keputusan:**', name: 'Keputusan' },
    { key: '- **Alasan:**', name: 'Alasan' },
  ];

  for (let i = 0; i < decisionEntries.length; i++) {
    const entry = decisionEntries[i];
    const firstLine = entry.split('\n')[0].trim();
    let lastIndex = -1;

    for (const field of requiredFields) {
      const idx = entry.indexOf(field.key);
      if (idx === -1) {
        error(`Entry "${firstLine}" is missing mandatory field "${field.name}"`);
        hasErrors = true;
      } else if (idx < lastIndex) {
        error(
          `Entry "${firstLine}" has field "${field.name}" out of order (must be Tanggal -> Konteks -> Keputusan -> Alasan)`,
        );
        hasErrors = true;
      }
      lastIndex = idx;
    }
  }

  if (!hasErrors) {
    log('✔ docs/decision-log.md format and all entries conform strictly to §0 Aturan 1');
  }

  // 3. Validate docs/adr/0000-template.md
  log('Verifying docs/adr/0000-template.md structure (MADR format)...');
  const adrContent = readFileSync(adrTemplatePath, 'utf-8');

  const adrRequiredHeadings = [
    { pattern: /^##\s+Konteks/m, name: '## Konteks' },
    { pattern: /^##\s+Pilihan\s+Keputusan/m, name: '## Pilihan Keputusan' },
    { pattern: /^##\s+Keputusan\s+Terpilih/m, name: '## Keputusan Terpilih' },
    { pattern: /^##\s+Konsekuensi/m, name: '## Konsekuensi' },
  ];

  for (const { pattern, name } of adrRequiredHeadings) {
    if (!pattern.test(adrContent)) {
      error(`docs/adr/0000-template.md missing mandatory heading: "${name}"`);
      hasErrors = true;
    }
  }

  if (!adrContent.includes('Status:')) {
    error('docs/adr/0000-template.md missing Status metadata field');
    hasErrors = true;
  }

  if (!hasErrors) {
    log('✔ docs/adr/0000-template.md contains all required sections');
  }

  // 4. Validate docs/runbooks/TEMPLATE.md
  log('Verifying docs/runbooks/TEMPLATE.md structure (§10.7)...');
  const runbookContent = readFileSync(runbookTemplatePath, 'utf-8');

  const runbookRequiredHeadings = [
    { pattern: /^##\s+(?:1\.\s+)?Dampak/m, name: 'Dampak' },
    { pattern: /^##\s+(?:2\.\s+)?Diagnosis\s+5\s+Langkah/m, name: 'Diagnosis 5 Langkah' },
    { pattern: /^##\s+(?:3\.\s+)?Mitigasi/m, name: 'Mitigasi' },
    { pattern: /^##\s+(?:4\.\s+)?Eskalasi/m, name: 'Eskalasi' },
  ];

  for (const { pattern, name } of runbookRequiredHeadings) {
    if (!pattern.test(runbookContent)) {
      error(`docs/runbooks/TEMPLATE.md missing mandatory section: "${name}"`);
      hasErrors = true;
    }
  }

  // Verify all 5 diagnosis steps are present
  for (let step = 1; step <= 5; step++) {
    const stepPattern = new RegExp(`###\\s+Langkah\\s+${step}:`, 'm');
    if (!stepPattern.test(runbookContent)) {
      error(`docs/runbooks/TEMPLATE.md missing Diagnosis step: "Langkah ${step}:"`);
      hasErrors = true;
    }
  }

  // Verify SEV1-4 and Postmortem mentions (§10.7)
  const requiredKeywords = [
    { pattern: /SEV1/i, desc: 'Severity level SEV1' },
    { pattern: /SEV2/i, desc: 'Severity level SEV2' },
    { pattern: /SEV3/i, desc: 'Severity level SEV3' },
    { pattern: /SEV4/i, desc: 'Severity level SEV4' },
    { pattern: /Incident Commander/i, desc: 'Incident Commander role' },
    { pattern: /postmortem/i, desc: 'Postmortem process' },
    { pattern: /5\s+hari\s+kerja/i, desc: '5 hari kerja postmortem SLA' },
  ];

  for (const { pattern, desc } of requiredKeywords) {
    if (!pattern.test(runbookContent)) {
      error(`docs/runbooks/TEMPLATE.md missing required concept: ${desc}`);
      hasErrors = true;
    }
  }

  if (!hasErrors) {
    log('✔ docs/runbooks/TEMPLATE.md contains 5-step diagnosis and all §10.7 requirements');
  }

  return !hasErrors;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const success = verifyDocumentation();
  if (!success) {
    console.error('\nDocumentation verification failed.');
    process.exit(1);
  }
  console.log('\nAll documentation templates verified successfully.');
}
