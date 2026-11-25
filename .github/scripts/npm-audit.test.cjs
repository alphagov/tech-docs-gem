const assert = require('node:assert/strict')
const { spawnSync } = require('node:child_process')
const { mkdtempSync, readFileSync, rmSync, writeFileSync } = require('node:fs')
const { tmpdir } = require('node:os')
const path = require('node:path')
const { test } = require('node:test')

const script = path.join(__dirname, 'npm-audit.cjs')

function runAudit (output, status = 0) {
  const directory = mkdtempSync(path.join(tmpdir(), 'tech-docs-npm-audit-'))
  const summary = path.join(directory, 'summary.md')
  const calls = path.join(directory, 'calls.txt')
  writeFileSync(path.join(directory, 'npm'), `#!/bin/sh
printf '%s\\n' "$*" >> "$AUDIT_TEST_CALLS"
printf '%s' "$AUDIT_TEST_OUTPUT"
exit "$AUDIT_TEST_STATUS"
`, { mode: 0o755 })

  try {
    const result = spawnSync(process.execPath, [script], {
      encoding: 'utf8',
      env: {
        ...process.env,
        PATH: directory + path.delimiter + process.env.PATH,
        GITHUB_STEP_SUMMARY: summary,
        AUDIT_TEST_CALLS: calls,
        AUDIT_TEST_OUTPUT: output,
        AUDIT_TEST_STATUS: String(status)
      }
    })
    assert.equal(result.error, undefined)
    assert.equal(readFileSync(calls, 'utf8'), 'audit --audit-level=high --json\n')
    return { ...result, summary: readFileSync(summary, 'utf8') }
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
}

function report (counts = {}) {
  return JSON.stringify({ metadata: { vulnerabilities: { critical: 0, high: 0, ...counts } } })
}

for (const [name, counts] of [
  ['clean audit', {}],
  ['low and moderate findings below the configured threshold', { low: 2, moderate: 3, total: 5 }]
]) {
  test(`passes a ${name}`, () => {
    const result = runAudit(report(counts))
    assert.equal(result.status, 0)
    assert.match(result.summary, /No high or critical vulnerabilities found/)
    assert.doesNotMatch(result.stderr, /::error::/)
  })
}

for (const [name, counts, status] of [
  ['high finding', { high: 1 }, 1],
  ['critical finding', { critical: 2 }, 1],
  ['findings despite a successful command exit', { high: 1 }, 0]
]) {
  test(`fails an audit with a ${name}`, () => {
    const result = runAudit(report(counts), status)
    assert.equal(result.status, 1)
    assert.match(result.summary, /High or critical vulnerabilities detected/)
    assert.match(result.summary, new RegExp(`\\| High \\| ${counts.high || 0} \\|`))
    assert.match(result.summary, new RegExp(`\\| Critical \\| ${counts.critical || 0} \\|`))
    assert.doesNotMatch(result.summary, /No high or critical vulnerabilities found/)
  })
}

for (const [name, output, status] of [
  ['registry failure', JSON.stringify({ error: { code: 'ECONNREFUSED' } }), 1],
  ['network error without an error property', JSON.stringify({ message: 'Registry unavailable' }), 1],
  ['error alongside valid counts', JSON.stringify({ error: { code: 'EAUDIT' }, metadata: { vulnerabilities: { high: 0, critical: 0 } } }), 1],
  ['empty output', '', 1],
  ['malformed output', 'not JSON', 0],
  ['null report', 'null', 0],
  ['missing metadata', '{}', 0],
  ['missing counts', JSON.stringify({ metadata: { vulnerabilities: {} } }), 0],
  ['missing high count', report({ high: undefined }), 0],
  ['missing critical count', report({ critical: undefined }), 0],
  ['negative count', report({ high: -1 }), 0],
  ['non-numeric count', report({ critical: '0' }), 0],
  ['fractional count', report({ high: 0.5 }), 0],
  ['failed command with zero findings', report(), 1]
]) {
  test(`fails safely on ${name}`, () => {
    const result = runAudit(output, status)
    assert.equal(result.status, 1)
    assert.match(result.summary, /audit could not be completed/)
    assert.match(result.stderr, /::error::/)
    assert.doesNotMatch(result.summary, /No high or critical vulnerabilities found/)
  })
}
