#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const readline = require("readline");
const { execSync } = require("child_process");

const [origin, target] = process.argv.slice(2);

try {
  execSync("exiftool -ver", { stdio: "ignore" });
} catch {
  console.error("Error: exiftool is not installed. Install it with: brew install exiftool");
  process.exit(1);
}

if (!origin || !target) {
  console.error("Usage: node compare_folders.js <origin_folder> <target_folder>");
  process.exit(1);
}

if (!fs.existsSync(origin) || !fs.statSync(origin).isDirectory()) {
  console.error(`Error: Origin folder '${origin}' does not exist.`);
  process.exit(1);
}

if (!fs.existsSync(target) || !fs.statSync(target).isDirectory()) {
  console.error(`Error: Target folder '${target}' does not exist.`);
  process.exit(1);
}

const SKIP_EXTENSIONS = new Set([".bin"]);

function collectFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...collectFiles(fullPath));
    } else if (entry.isFile() && !SKIP_EXTENSIONS.has(path.extname(entry.name).toLowerCase())) {
      results.push(fullPath);
    }
  }
  return results;
}

const originFiles = collectFiles(origin);
console.log(`Total files found in origin: ${originFiles.length}\n`);

// Group by filename — multiple files can share the same name from different subfolders
const originLookup = new Map();
originFiles.forEach((f) => {
  const name = path.basename(f);
  const size = fs.statSync(f).size;
  if (!originLookup.has(name)) originLookup.set(name, []);
  originLookup.get(name).push({ fullPath: f, size, found: false });
});

let remaining = originFiles.length;

function scanTarget(dir) {
  if (remaining === 0) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (remaining === 0) return;
    if (entry.isFile() && originLookup.has(entry.name)) {
      const targetSize = fs.statSync(path.join(dir, entry.name)).size;
      const entries = originLookup.get(entry.name);
      const unmatched = entries.find((e) => !e.found && e.size === targetSize);
      if (unmatched) {
        unmatched.found = true;
        remaining--;
      }
    } else if (entry.isDirectory()) {
      scanTarget(path.join(dir, entry.name));
    }
  }
}

scanTarget(target);

const missing = [];
for (const entries of originLookup.values()) {
  for (const entry of entries) {
    if (!entry.found) missing.push(entry.fullPath);
  }
}

console.log(`Missing files in target: ${missing.length}\n`);

function getCreationDate(filePath) {
  try {
    const output = execSync(
      `exiftool -s3 -CreateDate -DateTimeOriginal "${filePath}"`,
      { encoding: "utf-8" }
    ).trim().split("\n");
    // CreateDate is first, DateTimeOriginal is second
    return output[0] || output[1] || "Unknown";
  } catch {
    return "Unknown";
  }
}

missing.forEach((f) => {
  const date = getCreationDate(f);
  console.log(`  ${path.relative(origin, f)}  (Created: ${date})`);
});

if (missing.length > 0) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl.question("Copy missing files to target? (y/n): ", (answer) => {
    rl.close();
    if (answer.toLowerCase() !== "y") {
      console.log("Skipped.");
      return;
    }

    const destDir = path.join(target, "MISSING_FROM_ORIGIN");
    fs.mkdirSync(destDir, { recursive: true });

    const usedNames = new Set(
      fs.readdirSync(destDir).map((n) => n.toLowerCase())
    );

    const total = missing.length;
    const barWidth = 30;

    missing.forEach((f, i) => {
      const baseName = path.basename(f);
      let destName = baseName;

      if (usedNames.has(destName.toLowerCase())) {
        const ext = path.extname(baseName);
        const stem = path.basename(baseName, ext);
        let counter = 2;
        destName = `${stem}_${counter}${ext}`;
        while (usedNames.has(destName.toLowerCase())) {
          counter++;
          destName = `${stem}_${counter}${ext}`;
        }
      }

      usedNames.add(destName.toLowerCase());
      fs.copyFileSync(f, path.join(destDir, destName));
      const done = i + 1;
      const pct = Math.round((done / total) * 100);
      const filled = Math.round((done / total) * barWidth);
      const bar = "█".repeat(filled) + "░".repeat(barWidth - filled);
      process.stdout.write(`\r  [${bar}] ${pct}% (${done}/${total})`);
    });

    console.log(`\n\nCopied ${total} file(s) to ${destDir}`);
  });
}
