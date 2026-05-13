#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

const SKILLS_DIR = __dirname;

const TARGETS = [
  path.join(os.homedir(), ".claude", "skills"),
  path.join(os.homedir(), ".codex", "skills"),
  path.join(os.homedir(), ".agents", "skills"),
];

function isSkill(entry) {
  if (!entry.isDirectory()) return false;
  const skillFile = path.join(SKILLS_DIR, entry.name, "SKILL.md");
  return fs.existsSync(skillFile);
}

function ensureSymlink(src, dest) {
  let stat;
  try {
    stat = fs.lstatSync(dest);
  } catch {
    fs.symlinkSync(src, dest);
    return "linked";
  }

  if (stat.isSymbolicLink()) {
    const current = fs.readlinkSync(dest);
    if (current === src) return "skipped (already linked)";
    fs.unlinkSync(dest);
    fs.symlinkSync(src, dest);
    return "relinked";
  }

  return "skipped (non-symlink entry exists)";
}

const skills = fs.readdirSync(SKILLS_DIR, { withFileTypes: true }).filter(isSkill);

if (skills.length === 0) {
  console.log("No skills found in", SKILLS_DIR);
  process.exit(0);
}

console.log(`Found ${skills.length} skill(s): ${skills.map((s) => s.name).join(", ")}\n`);

for (const target of TARGETS) {
  if (!fs.existsSync(target)) {
    console.log(`${target} — not found, skipping`);
    continue;
  }

  console.log(`${target}`);
  for (const skill of skills) {
    const src = path.join(SKILLS_DIR, skill.name);
    const dest = path.join(target, skill.name);
    try {
      const result = ensureSymlink(src, dest);
      console.log(`  ${skill.name}: ${result}`);
    } catch (err) {
      console.log(`  ${skill.name}: error — ${err.message}`);
    }
  }
  console.log();
}
