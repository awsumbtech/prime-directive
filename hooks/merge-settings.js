#!/usr/bin/env node
// Registers the Prime Directive hooks in a Claude Code settings.json.
//
//   node merge-settings.js <settings.json> <installed hooks dir>
//
// Reads settings.hooks.json next to this script, substitutes the installed
// hooks directory, and merges the entries into the settings file. Existing
// Prime Directive entries (recognized by script name) are replaced, so the
// merge is idempotent; every other hook and setting is left untouched. The
// settings file is backed up first. Both installers call this.
'use strict';

const fs = require('fs');
const path = require('path');

const [settingsPath, hooksDir] = process.argv.slice(2);
if (!settingsPath || !hooksDir) {
  console.error('usage: merge-settings.js <settings.json> <hooks dir>');
  process.exit(1);
}

const OURS = /\b(write-gate|regression-gate)\.js\b/;
const dir = path.resolve(hooksDir).replace(/\\/g, '/');

const template = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'settings.hooks.json'), 'utf8').replace(/\{HOOKS_DIR\}/g, dir)
);

let settings = {};
if (fs.existsSync(settingsPath)) {
  const raw = fs.readFileSync(settingsPath, 'utf8').replace(/^\uFEFF/, '');
  settings = raw.trim() ? JSON.parse(raw) : {};
  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+/, '');
  fs.copyFileSync(settingsPath, `${settingsPath}.bak-${stamp}`);
}

settings.hooks = settings.hooks || {};
for (const [event, entries] of Object.entries(template.hooks)) {
  const existing = Array.isArray(settings.hooks[event]) ? settings.hooks[event] : [];
  const kept = existing.filter(entry =>
    !(Array.isArray(entry.hooks) && entry.hooks.some(h => OURS.test(String(h.command || ''))))
  );
  settings.hooks[event] = kept.concat(entries);
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log(`Registered Prime Directive hooks in ${settingsPath} (hooks dir: ${dir}).`);
