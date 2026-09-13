#!/usr/bin/env node
// Prime Directive regression gate.
//
// Enforces "no net-new failures" as a check rather than a sentence. Runs the
// project's test command and compares the result to a recorded baseline.
//
// Modes:
//   node regression-gate.js              SubagentStop hook. Reads the event
//                                        from stdin. Blocks the subagent
//                                        (exit 2) on net-new failures.
//   node regression-gate.js --baseline   Record the current result as the
//                                        baseline. /execute and /debug call
//                                        this before any change is made.
//   node regression-gate.js --check      Compare now and print the verdict.
//                                        Exit 1 on net-new failures.
//
// The test command comes from the project's CLAUDE.md, the line that reads
// "- Test: `command`", or from PRIME_DIRECTIVE_TEST_COMMAND. The baseline is
// stored at .claude/baseline.json in the project. With no test command the
// gate says so and does nothing; it never blocks on its own absence.
//
// Failure comparison is by signature: lines of test output that look like a
// failure, with timings stripped. It is a heuristic and it is documented as
// one. A green suite needs no heuristic; a suite that was red at baseline
// is compared line by line so pre-existing failures never block.
//
//   PRIME_DIRECTIVE_TEST_TIMEOUT_MS   default 600000
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const FAILURE_LINE = /\b(FAIL|FAILED|failed|not ok|AssertionError|Error:|Exception|✗|✕)\b/;
const GATED_AGENTS = /^(implementer|tester)$/i;

function readTestCommand(cwd) {
  const env = process.env.PRIME_DIRECTIVE_TEST_COMMAND;
  if (env && env.trim()) return env.trim();
  try {
    const md = fs.readFileSync(path.join(cwd, 'CLAUDE.md'), 'utf8');
    const m = /^-\s*Test:\s*`([^`]+)`/m.exec(md);
    if (m && !/[{}]/.test(m[1])) return m[1].trim();
  } catch (e) { /* no CLAUDE.md */ }
  return null;
}

function baselinePath(cwd) {
  return path.join(cwd, '.claude', 'baseline.json');
}

function signatures(output) {
  const seen = new Set();
  for (const raw of output.split(/\r?\n/)) {
    if (!FAILURE_LINE.test(raw)) continue;
    const line = raw
      .replace(/\x1b\[[0-9;]*m/g, '')
      .replace(/\b\d+(\.\d+)?\s*(ms|s|sec|seconds)\b/g, '')
      .replace(/\s+/g, ' ')
      .trim();
    if (line) seen.add(line);
  }
  return [...seen];
}

function runTests(cwd, command) {
  const timeout = Number(process.env.PRIME_DIRECTIVE_TEST_TIMEOUT_MS) || 600000;
  const r = spawnSync(command, { cwd, shell: true, encoding: 'utf8', timeout, maxBuffer: 64 * 1024 * 1024 });
  const output = (r.stdout || '') + (r.stderr || '');
  const exit = r.error && r.error.code === 'ETIMEDOUT' ? 124 : (r.status === null ? 1 : r.status);
  return { exit, output, signatures: signatures(output) };
}

function tail(output, n) {
  const lines = output.trim().split(/\r?\n/);
  return lines.slice(-n).join('\n');
}

function writeBaseline(cwd, command, result) {
  const p = baselinePath(cwd);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, JSON.stringify({
    command,
    exit: result.exit,
    signatures: result.signatures,
    recordedAt: new Date().toISOString(),
  }, null, 2) + '\n');
  return p;
}

function readBaseline(cwd) {
  try {
    return JSON.parse(fs.readFileSync(baselinePath(cwd), 'utf8').replace(/^\uFEFF/, ''));
  } catch (e) {
    return null;
  }
}

// Returns { verdict: 'pass' | 'block' | 'skip', message }
function compare(cwd, command) {
  const current = runTests(cwd, command);
  const base = readBaseline(cwd);

  if (current.exit === 0) {
    const note = base && base.exit !== 0 ? ' Baseline was red; the suite is now green.' : '';
    return { verdict: 'pass', message: `Regression gate: suite green (${command}).${note}` };
  }

  if (!base) {
    return {
      verdict: 'skip',
      message: `Regression gate: suite is failing (${current.signatures.length} failure signatures) but no baseline is recorded, ` +
        'so pre-existing failures cannot be told from new ones. Record one before changing code: ' +
        'node regression-gate.js --baseline. Last lines:\n' + tail(current.output, 15),
    };
  }

  if (base.exit === 0) {
    return {
      verdict: 'block',
      message: `Regression gate FAILED: the suite was green at baseline (${base.recordedAt}) and is now failing. ` +
        'This is a net-new failure. Fix it before reporting done. Failure signatures:\n' +
        current.signatures.slice(0, 20).join('\n') + '\nLast lines:\n' + tail(current.output, 20),
    };
  }

  const baseSet = new Set(base.signatures || []);
  const netNew = current.signatures.filter(s => !baseSet.has(s));
  if (netNew.length) {
    return {
      verdict: 'block',
      message: `Regression gate FAILED: ${netNew.length} failure signature(s) not present at baseline (${base.recordedAt}). ` +
        'Fix them before reporting done:\n' + netNew.slice(0, 20).join('\n') + '\nLast lines:\n' + tail(current.output, 20),
    };
  }
  return {
    verdict: 'pass',
    message: `Regression gate: suite still red, but every failure matches the baseline (${base.signatures.length} known). No net-new failures.`,
  };
}

function systemMessage(text) {
  process.stdout.write(JSON.stringify({ systemMessage: text }));
}

function cli(mode) {
  const cwd = process.cwd();
  const command = readTestCommand(cwd);
  if (!command) {
    console.log('Regression gate: no test command. Add "- Test: `command`" to CLAUDE.md or set PRIME_DIRECTIVE_TEST_COMMAND.');
    process.exit(0);
  }
  if (mode === '--baseline') {
    const r = runTests(cwd, command);
    const p = writeBaseline(cwd, command, r);
    console.log(`Baseline recorded at ${path.relative(cwd, p)}: exit ${r.exit}, ${r.signatures.length} failure signature(s).`);
    process.exit(0);
  }
  const c = compare(cwd, command);
  console.log(c.message);
  process.exit(c.verdict === 'block' ? 1 : 0);
}

function hook(raw) {
  let input = {};
  try { input = JSON.parse(raw.replace(/^\uFEFF/, '')); } catch (e) { process.exit(0); }
  const agent = String(input.agent_type || '');
  if (!GATED_AGENTS.test(agent)) process.exit(0);
  const cwd = input.cwd || process.cwd();
  const command = readTestCommand(cwd);
  if (!command) {
    systemMessage('Regression gate skipped: no test command in CLAUDE.md (- Test: `command`).');
    process.exit(0);
  }
  const c = compare(cwd, command);
  if (c.verdict === 'block') {
    if (input.stop_hook_active) {
      // Already blocked once this turn; do not loop the subagent forever.
      systemMessage(c.message + '\nThe gate already blocked once; escalating to the user instead of looping.');
      process.exit(0);
    }
    process.stderr.write(c.message);
    process.exit(2);
  }
  systemMessage(c.message);
  process.exit(0);
}

const arg = process.argv[2];
if (arg === '--baseline' || arg === '--check') {
  cli(arg);
} else {
  let buf = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', c => { buf += c; });
  process.stdin.on('end', () => hook(buf));
  process.stdin.on('error', () => process.exit(0));
}
