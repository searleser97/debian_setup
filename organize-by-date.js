#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const readline = require("readline");

try {
  execSync("exiftool -ver", { stdio: "ignore" });
} catch {
  console.error("Error: exiftool is not installed. Install it with: brew install exiftool");
  process.exit(1);
}

const folder = process.argv[2];

if (!folder) {
  console.error("Usage: node organize_by_date.js <folder>");
  process.exit(1);
}

if (!fs.existsSync(folder) || !fs.statSync(folder).isDirectory()) {
  console.error(`Error: Folder '${folder}' does not exist.`);
  process.exit(1);
}

const SKIP_EXTENSIONS = new Set([".bin"]);

const DATE_FOLDER_PATTERN = /^\d{4}_\d{2}_\d{2}$/;

function collectFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (DATE_FOLDER_PATTERN.test(entry.name)) continue;
      results.push(...collectFiles(fullPath));
    } else if (entry.isFile() && !SKIP_EXTENSIONS.has(path.extname(entry.name).toLowerCase())) {
      results.push(fullPath);
    }
  }
  return results;
}

const files = collectFiles(folder);

// Cache scanned metadata to avoid re-scanning on interrupted re-runs
const cacheFile = path.join(folder, ".organize-cache.json");
let cache = {};
try {
  cache = JSON.parse(fs.readFileSync(cacheFile, "utf-8"));
} catch {}

function getCacheKey(filePath) {
  const stat = fs.statSync(filePath);
  return `${path.basename(filePath)}|${stat.size}|${stat.mtimeMs}`;
}

function getCreationDate(filePath) {
  const key = getCacheKey(filePath);
  if (cache[key] !== undefined) return cache[key];

  let date = null;
  try {
    const output = execSync(
      `exiftool -s3 -CreateDate -DateTimeOriginal -FileModifyDate "${filePath}"`,
      { encoding: "utf-8" }
    ).trim().split("\n");
    date = output[0] || output[1] || output[2] || null;
  } catch {}

  // Strip timezone offset if present (e.g., "2025:12:20 14:21:22-08:00" -> "2025:12:20 14:21:22")
  if (date) date = date.replace(/[+-]\d{2}:\d{2}$/, "");

  cache[key] = date;
  return date;
}

function toFolderName(dateStr) {
  // "2026:02:08 22:48:28" -> "2026_02_08"
  const match = dateStr.match(/^(\d{4}):(\d{2}):(\d{2})/);
  return match ? `${match[1]}_${match[2]}_${match[3]}` : null;
}

function toDateTimeSuffix(dateStr) {
  // "2026:02:08 22:48:28" -> "20260208_224828"
  const match = dateStr.match(/^(\d{4}):(\d{2}):(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/);
  return match ? `${match[1]}${match[2]}${match[3]}_${match[4]}${match[5]}${match[6]}` : null;
}

// Build plan: map each file to its target date folder
const plan = new Map(); // folderName -> [{ filePath, dateStr }, ...]
const unknownFiles = [];

console.log("Scanning metadata...\n");

files.forEach((filePath, i) => {
  const date = getCreationDate(filePath);
  const folderName = date ? toFolderName(date) : null;

  if (folderName) {
    if (!plan.has(folderName)) plan.set(folderName, []);
    plan.get(folderName).push({ filePath, dateStr: date });
  } else {
    unknownFiles.push(filePath);
  }

  const done = i + 1;
  const pct = Math.round((done / files.length) * 100);
  const barWidth = 30;
  const filled = Math.round((done / files.length) * barWidth);
  const bar = "█".repeat(filled) + "░".repeat(barWidth - filled);
  process.stdout.write(`\r  [${bar}] ${pct}% (${done}/${files.length})`);
});

// Save cache after scan so re-runs skip exiftool calls
fs.writeFileSync(cacheFile, JSON.stringify(cache, null, 2));

console.log("\n");

// Show plan
const sortedDates = [...plan.keys()].sort();
sortedDates.forEach((date) => {
  console.log(`  ${date}/ (${plan.get(date).length} files)`);
});
if (unknownFiles.length > 0) {
  console.log(`  Unknown date: ${unknownFiles.length} file(s) (will be skipped)`);
  unknownFiles.forEach((f) => {
    const size = fs.statSync(f).size;
    const label = size === 0 ? "0 bytes" : size < 1024 ? `${size} B` : size < 1048576 ? `${(size / 1024).toFixed(1)} KB` : `${(size / 1048576).toFixed(1)} MB`;
    console.log(`    - ${path.relative(folder, f)} (${label})`);
  });
}
console.log(`\nTotal: ${files.length - unknownFiles.length} file(s) into ${sortedDates.length} folder(s)`);

if (sortedDates.length === 0) {
  console.log("Nothing to organize.");
  try { fs.unlinkSync(cacheFile); } catch {}
  process.exit(0);
}

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
rl.question("\nProceed with moving files? (y/n): ", (answer) => {
  rl.close();
  if (answer.toLowerCase() !== "y") {
    console.log("Skipped.");
    try { fs.unlinkSync(cacheFile); } catch {}
    return;
  }

  const total = files.length - unknownFiles.length;
  let moved = 0;
  let renamed = 0;
  const failedDeletes = [];
  const barWidth = 30;

  sortedDates.forEach((date) => {
    const destDir = path.join(folder, date);
    fs.mkdirSync(destDir, { recursive: true });

    // Track used filenames to handle duplicates within this destination
    const usedNames = new Set(
      fs.readdirSync(destDir).map((n) => n.toLowerCase())
    );

    plan.get(date).forEach(({ filePath, dateStr }) => {
      // Skip files already in the correct destination folder
      if (path.dirname(filePath) === destDir) {
        moved++;
        return;
      }

      const baseName = path.basename(filePath);
      let destName = baseName;

      if (usedNames.has(destName.toLowerCase())) {
        const ext = path.extname(baseName);
        const stem = path.basename(baseName, ext);
        const suffix = toDateTimeSuffix(dateStr) || String(Date.now());
        destName = `${stem}_${suffix}${ext}`;

        let counter = 2;
        while (usedNames.has(destName.toLowerCase())) {
          destName = `${stem}_${suffix}_${counter}${ext}`;
          counter++;
        }
        renamed++;
      }

      usedNames.add(destName.toLowerCase());
      const destPath = path.join(destDir, destName);

      // If destination already exists with the same size, the previous run
      // was interrupted after copy but before delete — just remove the source
      if (fs.existsSync(destPath) && fs.statSync(filePath).size === fs.statSync(destPath).size) {
        fs.unlinkSync(filePath);
        moved++;
        return;
      }

      try {
        fs.renameSync(filePath, destPath);
      } catch (err) {
        if (err.code === "EPERM" || err.code === "EXDEV") {
          fs.copyFileSync(filePath, destPath);
          try {
            fs.unlinkSync(filePath);
          } catch (unlinkErr) {
            if (unlinkErr.code === "EPERM") {
              failedDeletes.push(filePath);
            } else {
              throw unlinkErr;
            }
          }
        } else {
          throw err;
        }
      }

      moved++;
      const pct = Math.round((moved / total) * 100);
      const filled = Math.round((moved / total) * barWidth);
      const bar = "█".repeat(filled) + "░".repeat(barWidth - filled);
      process.stdout.write(`\r  [${bar}] ${pct}% (${moved}/${total})`);
    });
  });

  console.log(`\n\nMoved ${moved} file(s) into ${sortedDates.length} folder(s).`);
  if (renamed > 0) {
    console.log(`Renamed ${renamed} file(s) to avoid duplicates.`);
  }
  if (failedDeletes.length > 0) {
    console.log(`\n⚠️  Could not delete ${failedDeletes.length} source file(s) (permission denied).`);
    console.log(`   Files were copied successfully but originals remain on the source drive.`);
  }

  // Clean up empty directories left behind
  removeEmptyDirs(folder, new Set(sortedDates.map((d) => path.join(folder, d))));

  // Remove cache file after successful completion
  try { fs.unlinkSync(cacheFile); } catch {}
});

function removeEmptyDirs(dir, protectedDirs) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const fullPath = path.join(dir, entry.name);
    removeEmptyDirs(fullPath, protectedDirs);
    if (!protectedDirs.has(fullPath) && fs.readdirSync(fullPath).length === 0) {
      fs.rmdirSync(fullPath);
      console.log(`  Removed empty directory: ${path.relative(folder, fullPath)}/`);
    }
  }
}
