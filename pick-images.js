#!/usr/bin/env node

// pick-images - Terminal image picker with session support
//
// Dependencies:
//   Node.js    - Runtime                          - brew install node
//   exiftool   - Extract RAW preview thumbnails   - brew install exiftool
//   ffmpeg     - Rotate images (EXIF orientation)  - brew install ffmpeg
//   libraw     - Fallback RAW preview (dcraw_half) - brew install libraw

const fs = require("fs");
const path = require("path");
const os = require("os");
const { execSync } = require("child_process");

// --- Constants ---

const SUPPORTED_FORMATS = new Set([
  ".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".tif", ".webp",
  ".orf", ".cr2", ".cr3", ".nef", ".arw", ".dng", ".rw2", ".raf", ".srw", ".pef",
]);

const RAW_FORMATS = new Set([
  ".orf", ".cr2", ".cr3", ".nef", ".arw", ".dng", ".rw2", ".raf", ".srw", ".pef",
]);

// --- CLI Parsing ---

function printUsage() {
  console.log(`
Usage: pick-images <folder1> [folder2 ...] -o <output-file>
       pick-images -o <existing-session-file>   (resume previous session)

Browse images from one or more folders and pick favorites.
Saves session state as JSON (folders, position, favorites).

Required:
  -o, --output <file>   Session/output file (JSON)

Options:
  <folders...>          Directories to scan (not needed when resuming)

Keyboard Controls:
  →  / l / n            Next image
  ←  / h / p            Previous image
  f  / Space            Toggle favorite ★
  e                     Toggle preview quality (fast/HQ)
  q  / Esc              Quit and save

Supported formats: ${[...SUPPORTED_FORMATS].join(", ")}
RAW formats use embedded preview extraction via exiftool.

The output JSON file can be passed directly to images-to-video via -i.
`);
}

function parseArgs(argv) {
  const folders = [];
  let output = null;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "-h" || arg === "--help") {
      printUsage();
      process.exit(0);
    } else if (arg === "-o" || arg === "--output") {
      output = argv[++i];
      if (!output) throw new Error("Missing value for -o / --output");
    } else if (arg.startsWith("-")) {
      throw new Error(`Unknown option: ${arg}`);
    } else {
      folders.push(arg);
    }
  }

  if (!output) {
    throw new Error("Missing required option: -o / --output <file>");
  }

  // Try to load existing session
  let session = null;
  if (fs.existsSync(output)) {
    try {
      session = JSON.parse(fs.readFileSync(output, "utf-8"));
    } catch {
      throw new Error(`Output file exists but is not valid JSON: ${output}`);
    }
  }

  if (session) {
    // Resuming: merge CLI folders with saved folders
    const allFolders = [...new Set([...(session.folders || []), ...folders.map((f) => path.resolve(f))])];
    for (const folder of allFolders) {
      if (!fs.existsSync(folder) || !fs.statSync(folder).isDirectory()) {
        throw new Error(`Not a valid directory: ${folder}`);
      }
    }
    return {
      folders: allFolders,
      output,
      resumeFavorites: new Set(session.favorites || []),
      resumePosition: session.position || 0,
    };
  }

  // New session: folders are required
  if (folders.length === 0) {
    throw new Error("No folders provided. Provide at least one folder to scan.");
  }

  for (const folder of folders) {
    const resolved = path.resolve(folder);
    if (!fs.existsSync(resolved) || !fs.statSync(resolved).isDirectory()) {
      throw new Error(`Not a valid directory: ${folder}`);
    }
  }

  return {
    folders: folders.map((f) => path.resolve(f)),
    output,
    resumeFavorites: null,
    resumePosition: 0,
  };
}

// --- Folder Scanning ---

function scanFolders(folders) {
  const images = [];

  for (const folder of folders) {
    const entries = fs.readdirSync(folder);
    for (const entry of entries) {
      const ext = path.extname(entry).toLowerCase();
      if (SUPPORTED_FORMATS.has(ext)) {
        images.push(path.join(folder, entry));
      }
    }
  }

  images.sort();

  if (images.length === 0) {
    throw new Error("No supported images found in the provided folders.");
  }

  return images;
}

// --- Orientation Handling ---

// EXIF orientation to ffmpeg transpose mapping
// See: https://exiftool.org/TagNames/EXIF.html (Orientation)
function getTransposeFilter(orientation) {
  switch (orientation) {
    case 2: return "hflip";
    case 3: return "transpose=1,transpose=1";  // 180°
    case 4: return "vflip";
    case 5: return "transpose=0,hflip";
    case 6: return "transpose=1";               // 90° CW
    case 7: return "transpose=1,hflip";
    case 8: return "transpose=2";               // 270° CW
    default: return null;                       // 1 = normal, no rotation
  }
}

function getOrientation(imagePath) {
  try {
    const result = execSync(
      `exiftool -n -Orientation -s3 "${imagePath}"`,
      { stdio: ["ignore", "pipe", "pipe"], encoding: "utf-8" }
    ).trim();
    return parseInt(result, 10) || 1;
  } catch {
    return 1;
  }
}

function applyRotation(inputPath, outputPath, orientation) {
  const filter = getTransposeFilter(orientation);
  if (!filter) return inputPath;

  try {
    execSync(
      `ffmpeg -y -v quiet -i "${inputPath}" -vf "${filter}" -q:v 2 "${outputPath}"`,
      { stdio: "pipe" }
    );
    return outputPath;
  } catch {
    return inputPath;
  }
}

// --- Thumbnail / Preview ---

function getDisplayPath(imagePath, tempDir, hqMode) {
  const ext = path.extname(imagePath).toLowerCase();
  const baseName = path.basename(imagePath);
  const suffix = hqMode ? ".hq" : ".preview";
  const previewPath = path.join(tempDir, `${baseName}${suffix}.jpg`);

  if (fs.existsSync(previewPath)) {
    return previewPath;
  }

  const orientation = getOrientation(imagePath);

  if (!RAW_FORMATS.has(ext)) {
    if (orientation === 1) return imagePath;
    return applyRotation(imagePath, previewPath, orientation);
  }

  let extractedPath = path.join(tempDir, `${baseName}${suffix}.extracted.jpg`);

  if (hqMode) {
    // High-quality: half-size RAW decode with camera white balance, sRGB
    try {
      execSync(`dcraw_emu -h -w -T -o 1 "${imagePath}"`, { stdio: "pipe" });
      const tiffPath = `${imagePath}.tiff`;
      if (fs.existsSync(tiffPath)) {
        execSync(
          `ffmpeg -y -v quiet -i "${tiffPath}" -q:v 2 "${extractedPath}"`,
          { stdio: "pipe" }
        );
        try { fs.unlinkSync(tiffPath); } catch {}
      }
    } catch {}
  } else {
    // Fast: extract embedded JPEG preview
    try {
      execSync(
        `exiftool -b -PreviewImage "${imagePath}" > "${extractedPath}"`,
        { stdio: ["ignore", "ignore", "pipe"], shell: true }
      );
      if (!fs.existsSync(extractedPath) || fs.statSync(extractedPath).size === 0) {
        throw new Error("Empty preview");
      }
    } catch {
      // Fallback to dcraw_half
      try {
        execSync(`dcraw_half "${imagePath}"`, { stdio: "pipe" });
        const ppmPath = `${imagePath}.ppm`;
        if (fs.existsSync(ppmPath)) {
          execSync(
            `ffmpeg -y -v quiet -i "${ppmPath}" -vf "scale=1280:-1" -q:v 5 "${extractedPath}"`,
            { stdio: "pipe" }
          );
          try { fs.unlinkSync(ppmPath); } catch {}
        }
      } catch {}
    }
  }

  if (!fs.existsSync(extractedPath) || fs.statSync(extractedPath).size === 0) {
    return null;
  }

  // Apply rotation (only for fast mode — dcraw_emu -h handles rotation internally)
  if (!hqMode && orientation !== 1) {
    applyRotation(extractedPath, previewPath, orientation);
    try { fs.unlinkSync(extractedPath); } catch {}
  } else {
    fs.renameSync(extractedPath, previewPath);
  }

  return fs.existsSync(previewPath) ? previewPath : null;
}

// Pre-resize image to fit within terminal pixel dimensions
function fitToTerminal(imagePath, tempDir) {
  if (!cellSize) return imagePath;

  const termCols = process.stdout.columns || 80;
  const termRows = process.stdout.rows || 24;
  const maxRows = termRows - STATUS_BAR_LINES - TOP_MARGIN_LINES;
  const maxW = termCols * cellSize.cellWidth;
  const maxH = maxRows * cellSize.cellHeight;

  const dims = getImageDimensions(imagePath);
  if (!dims) return imagePath;

  // Check if image already fits
  if (dims.width <= maxW && dims.height <= maxH) return imagePath;

  const tag = `${maxW}x${maxH}`;
  const baseName = path.basename(imagePath);
  const resizedPath = path.join(tempDir, `${baseName}.fit${tag}.jpg`);

  if (fs.existsSync(resizedPath)) return resizedPath;

  try {
    execSync(
      `ffmpeg -y -v quiet -i "${imagePath}" -vf "scale='min(${maxW},iw)':'min(${maxH},ih)':force_original_aspect_ratio=decrease" -q:v 2 "${resizedPath}"`,
      { stdio: "pipe" }
    );
    return resizedPath;
  } catch {
    return imagePath;
  }
}

// --- iTerm2 Inline Image Protocol (WezTerm compatible) ---

const STATUS_BAR_LINES = 3;
const TOP_MARGIN_LINES = 2;

const dimsCache = new Map();
function getImageDimensions(imagePath) {
  if (dimsCache.has(imagePath)) return dimsCache.get(imagePath);
  try {
    const result = execSync(
      `ffprobe -v quiet -show_entries stream=width,height -of csv=p=0 "${imagePath}"`,
      { encoding: "utf-8", stdio: ["ignore", "pipe", "pipe"] }
    ).trim();
    const [w, h] = result.split(",").map(Number);
    if (w > 0 && h > 0) {
      const dims = { width: w, height: h };
      dimsCache.set(imagePath, dims);
      return dims;
    }
  } catch {}
  dimsCache.set(imagePath, null);
  return null;
}

// Query cell pixel size from the terminal via ESC[16t
// Must be called after stdin is in raw mode
function queryCellPixelSize() {
  return new Promise((resolve) => {
    const timeout = setTimeout(() => resolve(null), 500);
    let buf = "";

    function onData(d) {
      buf += d.toString();
      const m = buf.match(/\x1b\[6;(\d+);(\d+)t/);
      if (m) {
        clearTimeout(timeout);
        process.stdin.removeListener("data", onData);
        resolve({ cellHeight: parseInt(m[1]), cellWidth: parseInt(m[2]) });
      }
    }

    process.stdin.on("data", onData);
    process.stdout.write("\x1b[16t");
  });
}

let cellSize = null;

function displayImage(imagePath) {
  const data = fs.readFileSync(imagePath);
  const base64 = data.toString("base64");
  const size = data.length;

  const termCols = process.stdout.columns || 80;
  const termRows = process.stdout.rows || 24;
  const maxRows = termRows - STATUS_BAR_LINES - TOP_MARGIN_LINES;

  // Clear screen and move cursor to top
  process.stdout.write("\x1b[2J\x1b[H");

  // Add top margin
  process.stdout.write("\n".repeat(TOP_MARGIN_LINES));

  // Calculate centering — image is pre-resized so dims = rendered size
  let padCols = 0;
  const dims = getImageDimensions(imagePath);

  if (dims && cellSize) {
    const renderedCols = Math.ceil(dims.width / cellSize.cellWidth);
    padCols = Math.max(0, Math.floor((termCols - renderedCols) / 2));
  }

  if (padCols > 0) {
    process.stdout.write(`\x1b[${padCols}C`);
  }

  // Display at native size — image is already pre-resized to fit
  process.stdout.write(
    `\x1b]1337;File=inline=1;size=${size};preserveAspectRatio=1;width=auto;height=auto:${base64}\x07`
  );
  process.stdout.write("\n");
}

function displayStatusBar(index, total, imagePath, isFavorite, hq) {
  const name = path.basename(imagePath);
  const favoriteLabel = isFavorite ? "\x1b[33m★ FAVORITE\x1b[0m" : "☆";
  const qualityLabel = hq ? "\x1b[36m[HQ]\x1b[0m" : "\x1b[2m[fast]\x1b[0m";
  const counter = `[${index + 1}/${total}]`;
  const termRows = process.stdout.rows || 24;

  // Move cursor to fixed bottom position
  process.stdout.write(`\x1b[${termRows - 1};1H`);
  process.stdout.write(`\x1b[K ${counter}  ${name}  ${favoriteLabel}  ${qualityLabel}\n`);
  process.stdout.write(`\x1b[K \x1b[2m← → navigate  |  f/space: favorite  |  e: toggle quality  |  q: quit & save\x1b[0m`);
}

// --- Main Loop ---

async function main() {
  let tempDir = null;

  try {
    const args = parseArgs(process.argv.slice(2));

    // Check dependencies
    try {
      execSync("which exiftool", { stdio: "ignore" });
    } catch {
      throw new Error(
        '"exiftool" is not installed. Install with: brew install exiftool'
      );
    }

    const images = scanFolders(args.folders);
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "pick-images-"));

    const favorites = args.resumeFavorites || new Set();
    let currentIndex = Math.min(args.resumePosition, images.length - 1);
    let hqMode = false;

    if (args.resumeFavorites) {
      console.log(`Resuming session: ${favorites.size} favorite(s), position ${currentIndex + 1}/${images.length}`);
    }

    function saveSession() {
      const session = {
        folders: args.folders,
        position: currentIndex,
        favorites: [...favorites].sort(),
      };
      fs.writeFileSync(args.output, JSON.stringify(session, null, 2) + "\n", "utf-8");
    }

    function showCurrent() {
      const imagePath = images[currentIndex];
      let displayPath = getDisplayPath(imagePath, tempDir, hqMode);

      if (!displayPath) {
        process.stdout.write("\x1b[2J\x1b[H");
        process.stdout.write(`\n  ⚠ Could not generate preview for:\n  ${imagePath}\n`);
      } else {
        displayPath = fitToTerminal(displayPath, tempDir);
        displayImage(displayPath);
      }

      displayStatusBar(
        currentIndex,
        images.length,
        imagePath,
        favorites.has(imagePath),
        hqMode
      );
    }

    function saveAndExit() {
      // Restore terminal
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.stdout.write("\x1b[2J\x1b[H");

      saveSession();

      const favoritesList = [...favorites].sort();

      console.log(`\n✓ Saved ${favoritesList.length} favorite(s) to ${args.output}`);
      if (favoritesList.length > 0) {
        console.log(`\nFavorites:`);
        for (const fav of favoritesList) {
          console.log(`  ★ ${path.basename(fav)}`);
        }
      }

      // Cleanup
      try {
        fs.rmSync(tempDir, { recursive: true, force: true });
      } catch {}

      process.exit(0);
    }

    // Setup raw stdin for key handling
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.setEncoding("utf8");

    // Query cell pixel size once at startup for centering
    cellSize = await queryCellPixelSize();

    // Show first image
    showCurrent();

    // Re-display on terminal resize
    process.stdout.on("resize", () => showCurrent());

    process.stdin.on("data", (key) => {
      // Ctrl+C
      if (key === "\x03") {
        saveAndExit();
        return;
      }

      // Escape
      if (key === "\x1b" && key.length === 1) {
        saveAndExit();
        return;
      }

      // Arrow keys (escape sequences)
      if (key === "\x1b[C" || key === "l" || key === "n") {
        // Right / next
        if (currentIndex < images.length - 1) {
          currentIndex++;
          saveSession();
          showCurrent();
        }
        return;
      }

      if (key === "\x1b[D" || key === "h" || key === "p") {
        // Left / previous
        if (currentIndex > 0) {
          currentIndex--;
          saveSession();
          showCurrent();
        }
        return;
      }

      if (key === "f" || key === " ") {
        // Toggle favorite
        const imagePath = images[currentIndex];
        if (favorites.has(imagePath)) {
          favorites.delete(imagePath);
        } else {
          favorites.add(imagePath);
        }
        saveSession();
        showCurrent();
        return;
      }

      if (key === "e") {
        // Toggle preview quality
        hqMode = !hqMode;
        showCurrent();
        return;
      }

      if (key === "q") {
        saveAndExit();
        return;
      }
    });
  } catch (err) {
    console.error(`\n✗ Error: ${err.message}`);
    if (tempDir) {
      try { fs.rmSync(tempDir, { recursive: true, force: true }); } catch {}
    }
    process.exit(1);
  }
}

main();
