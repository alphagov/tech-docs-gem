const { spawnSync } = require('node:child_process')
const { appendFileSync } = require('node:fs')

const audit = spawnSync('npm', ['audit', '--audit-level=high', '--json'], {
  encoding: 'utf8'
})

// Keep the original report in the job log without making a second audit request.
if (audit.stdout) process.stdout.write(audit.stdout)
if (audit.stderr) process.stderr.write(audit.stderr)

const summary = ['## NPM Dependency Audit Summary', '']
let exitCode = 1

try {
  if (audit.error || audit.signal || audit.status === null) {
    throw new Error('The npm audit command could not complete.')
  }

  const report = JSON.parse(audit.stdout)
  const counts = report?.metadata?.vulnerabilities

  if (report.error || !counts ||
      ![counts.critical, counts.high].every(count => Number.isSafeInteger(count) && count >= 0)) {
    throw new Error('The audit report has an error or is missing valid vulnerability counts.')
  }

  if (counts.critical > 0 || counts.high > 0) {
    summary.push(
      '**High or critical vulnerabilities detected in npm dependencies.**',
      '',
      '| Vulnerability severity | Total count |',
      '| :--- | ---: |',
      `| Critical | ${counts.critical} |`,
      `| High | ${counts.high} |`,
      '',
      'See the captured audit report in the job log for details.'
    )
    console.error(`::error::npm audit detected ${counts.critical} critical and ${counts.high} high vulnerabilities.`)
  } else if (audit.status !== 0) {
    throw new Error(`The npm audit command failed with exit code ${audit.status}.`)
  } else {
    summary.push('**No high or critical vulnerabilities found.**')
    exitCode = 0
  }
} catch (error) {
  summary.push('**The npm audit could not be completed. Dependency security has not been verified.**')
  console.error(`::error::${error.message}`)
}

if (process.env.GITHUB_STEP_SUMMARY) {
  appendFileSync(process.env.GITHUB_STEP_SUMMARY, summary.join('\n') + '\n')
}

process.exitCode = exitCode
