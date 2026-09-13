#!/usr/bin/env node
// Prime Directive PreToolUse gate.
//
// Two checks on anything about to be written (Write, Edit, MultiEdit,
// NotebookEdit) or run (Bash): the house-style rule that forbids em dashes,
// and the rule that secrets live in Keeper and never in a file. A hit denies
// the tool call with a reason the agent can act on. The hook never edits.
//
// Per-session overrides, for the rare false positive:
//   PRIME_DIRECTIVE_STYLE_GATE=off     skip the em dash check
//   PRIME_DIRECTIVE_SECRETS_GATE=off   skip the secrets check
'use strict';

const EM_DASH = '\u2014';

const SECRET_PATTERNS = [
  ['AWS access key', /\bAKIA[0-9A-Z]{16}\b/],
  ['GitHub token', /\bgh[pousr]_[A-Za-z0-9]{36,}\b/],
  ['GitHub fine-grained token', /\bgithub_pat_[A-Za-z0-9_]{80,}\b/],
  ['Slack token', /\bxox[abprs]-[A-Za-z0-9-]{10,}\b/],
  ['Anthropic API key', /\bsk-ant-[A-Za-z0-9_-]{20,}\b/],
  ['Private key block', /-----BEGIN (?:RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY-----/],
  ['Azure storage key or SAS', /\b(?:AccountKey|SharedAccessSignature)=[A-Za-z0-9+/=%]{20,}/],
  ['Connection string password', /\b(?:Password|Pwd)=([^;\s'"]{8,})/i],
  ['Credential assignment', /\b(?:password|passwd|secret|token|api[_-]?key|client[_-]?secret)\b\s*[:=]\s*['"]([^'"\s]{8,})['"]/i],
];

// A captured value that looks like a placeholder is not a secret.
const PLACEHOLDER = /[{}$<>*]|example|changeme|placeholder|redacted|your[_-]|xxx|dummy|\bsample\b|\btest\b/i;

function off(name) {
  return String(process.env[name] || '').trim().toLowerCase() === 'off';
}

function textsToScan(toolName, input) {
  const out = [];
  if (!input) return out;
  if (typeof input.content === 'string') out.push(['content', input.content]);
  if (typeof input.new_string === 'string') out.push(['new_string', input.new_string]);
  if (typeof input.new_source === 'string') out.push(['new_source', input.new_source]);
  if (Array.isArray(input.edits)) {
    input.edits.forEach((e, i) => {
      if (e && typeof e.new_string === 'string') out.push([`edits[${i}]`, e.new_string]);
    });
  }
  if (toolName === 'Bash' && typeof input.command === 'string') out.push(['command', input.command]);
  return out;
}

function firstLineWith(text, test) {
  const lines = text.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    if (test(lines[i])) return i + 1;
  }
  return 0;
}

function styleFinding(field, text) {
  if (!text.includes(EM_DASH)) return null;
  const line = firstLineWith(text, l => l.includes(EM_DASH));
  return `House style: em dash (U+2014) in ${field} at line ${line}. ` +
    'Prime Directive forbids em dashes in generated content. Rewrite with a comma, colon, or period and retry.';
}

function secretFinding(field, text) {
  for (const [label, re] of SECRET_PATTERNS) {
    const m = re.exec(text);
    if (!m) continue;
    if (m[1] !== undefined && PLACEHOLDER.test(m[1])) continue;
    const line = firstLineWith(text, l => re.test(l));
    return `Secrets: ${label} in ${field} at line ${line}. ` +
      'Secrets live in Keeper and are injected at runtime; never write one to a file or a command. ' +
      'Replace it with an environment variable or a placeholder and retry.';
  }
  return null;
}

function deny(reason) {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: reason,
    },
  }));
  process.exit(0);
}

function main(raw) {
  let input;
  try {
    input = JSON.parse(raw.replace(/^\uFEFF/, ''));
  } catch (e) {
    process.exit(0); // unparseable payload: never block on our own bug
  }
  const toolName = input.tool_name || '';
  const texts = textsToScan(toolName, input.tool_input);
  const styleOn = !off('PRIME_DIRECTIVE_STYLE_GATE');
  const secretsOn = !off('PRIME_DIRECTIVE_SECRETS_GATE');
  for (const [field, text] of texts) {
    if (styleOn) {
      const f = styleFinding(field, text);
      if (f) deny(f);
    }
    if (secretsOn) {
      const f = secretFinding(field, text);
      if (f) deny(f);
    }
  }
  process.exit(0);
}

let buf = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => { buf += c; });
process.stdin.on('end', () => main(buf));
process.stdin.on('error', () => process.exit(0));
setTimeout(() => process.exit(0), 5000).unref();
