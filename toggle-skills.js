#!/usr/bin/env node

// Temporarily disable / re-enable the skills synced from this repo.
//
//   node toggle-skills.js off      # stash this repo's skill symlinks aside
//   node toggle-skills.js on       # restore them
//   node toggle-skills.js status   # show what's currently on/off
//
// Only symlinks pointing back into THIS repo are touched — unrelated skills
// (real dirs or symlinks from elsewhere) are left alone. Stashed links are
// moved to a sibling "<skills>-off" folder, which sits OUTSIDE the scanned
// skills dir, so Claude Code stops discovering them. Start a fresh session
// for the change to take effect.

const fs = require("fs");
const path = require("path");
const os = require("os");

const SKILLS_DIR = __dirname;

const TARGETS = [
  path.join(os.homedir(), ".claude", "skills"),
  path.join(os.homedir(), ".codex", "skills"),
  path.join(os.homedir(), ".agents", "skills"),
];

const stashFor = (target) => target + "-off";

// A dest entry "belongs to us" if it's a symlink resolving inside this repo.
function pointsIntoRepo(entryPath) {
  try {
    if (!fs.lstatSync(entryPath).isSymbolicLink()) return false;
    const resolved = fs.realpathSync(entryPath);
    return resolved === SKILLS_DIR || resolved.startsWith(SKILLS_DIR + path.sep);
  } catch {
    return false;
  }
}

function move(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.renameSync(src, dest);
}

function disable(target) {
  if (!fs.existsSync(target)) return { skipped: true };
  const stash = stashFor(target);
  const moved = [];
  for (const name of fs.readdirSync(target)) {
    const entry = path.join(target, name);
    if (pointsIntoRepo(entry)) {
      move(entry, path.join(stash, name));
      moved.push(name);
    }
  }
  return { moved };
}

function enable(target) {
  const stash = stashFor(target);
  if (!fs.existsSync(stash)) return { moved: [] };
  const moved = [];
  for (const name of fs.readdirSync(stash)) {
    move(path.join(stash, name), path.join(target, name));
    moved.push(name);
  }
  try {
    fs.rmdirSync(stash);
  } catch {
    /* not empty / already gone — leave it */
  }
  return { moved };
}

function status(target) {
  const on = fs.existsSync(target)
    ? fs.readdirSync(target).filter((n) => pointsIntoRepo(path.join(target, n)))
    : [];
  const stash = stashFor(target);
  const off = fs.existsSync(stash) ? fs.readdirSync(stash) : [];
  return { on, off };
}

const cmd = (process.argv[2] || "status").toLowerCase();

if (!["on", "off", "status"].includes(cmd)) {
  console.error(`Usage: node toggle-skills.js [on|off|status]`);
  process.exit(1);
}

for (const target of TARGETS) {
  if (!fs.existsSync(target) && !fs.existsSync(stashFor(target))) continue;
  console.log(target);

  if (cmd === "off") {
    const { skipped, moved } = disable(target);
    if (skipped) console.log("  (not found)");
    else if (moved.length === 0) console.log("  nothing to disable");
    else console.log(`  disabled ${moved.length}: ${moved.join(", ")}`);
  } else if (cmd === "on") {
    const { moved } = enable(target);
    if (moved.length === 0) console.log("  nothing stashed");
    else console.log(`  re-enabled ${moved.length}: ${moved.join(", ")}`);
  } else {
    const { on, off } = status(target);
    console.log(`  on  (${on.length}): ${on.join(", ") || "—"}`);
    console.log(`  off (${off.length}): ${off.join(", ") || "—"}`);
  }
  console.log();
}

if (cmd !== "status") {
  console.log("Start a fresh Claude Code session for changes to take effect.");
}
