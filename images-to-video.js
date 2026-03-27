#!/usr/bin/env node

// images-to-video - Create a video from a list of images
//
// Dependencies:
//   Node.js    - Runtime                           - brew install node
//   ffmpeg     - Video encoding and image scaling   - brew install ffmpeg
//   libraw     - RAW to TIFF conversion (dcraw_emu) - brew install libraw

const fs = require("fs");
const path = require("path");
const os = require("os");
const { execSync, spawnSync } = require("child_process");

// --- Constants ---

const NATIVE_FORMATS = new Set([
  ".jpg",
  ".jpeg",
  ".png",
  ".bmp",
  ".tiff",
  ".tif",
  ".webp",
]);

const RAW_FORMATS = new Set([
  ".orf",
  ".cr2",
  ".cr3",
  ".nef",
  ".arw",
  ".dng",
  ".rw2",
  ".raf",
  ".srw",
  ".pef",
]);

const ALL_SUPPORTED = new Set([...NATIVE_FORMATS, ...RAW_FORMATS]);

const DEFAULT_DURATION = "3s";
const DEFAULT_RESOLUTION = "1920x1080";
const DEFAULT_OUTPUT = "output.mp4";

// --- Duration Parsing ---

function parseDuration(value) {
  const match = value.match(/^(\d+(?:\.\d+)?)\s*(ms|s|m)$/i);
  if (!match) {
    throw new Error(
      `Invalid duration "${value}". Use a number followed by a unit: ms, s, or m (e.g., 3s, 500ms, 1m)`
    );
  }
  const num = parseFloat(match[1]);
  const unit = match[2].toLowerCase();
  switch (unit) {
    case "ms":
      return num / 1000;
    case "s":
      return num;
    case "m":
      return num * 60;
  }
}

// --- CLI Argument Parsing ---

function printUsage() {
  console.log(`
Usage: images-to-video -i <file> [options]

Create a video from a list of images.

Required:
  -i, --input <file>              Text file with image paths (one per line)

Options:
  -o, --output <file>             Output video file (default: ${DEFAULT_OUTPUT})
  --duration-per-image <value>    Duration each image is shown (default: ${DEFAULT_DURATION})
                                  Supports: ms, s, m (e.g., 3s, 500ms, 1m)
  --total-duration <value>        Total video duration, divided evenly across images
                                  Mutually exclusive with --duration-per-image
  -r, --resolution <WxH>          Video resolution (default: ${DEFAULT_RESOLUTION})
  -h, --help                      Show this help message

Supported image formats: ${[...ALL_SUPPORTED].join(", ")}
RAW formats (${[...RAW_FORMATS].join(", ")}) are converted via LibRaw (dcraw_emu).
Requires: ffmpeg, dcraw_emu (LibRaw) for RAW formats
`);
}

function parseArgs(argv) {
  const args = {
    input: null,
    output: DEFAULT_OUTPUT,
    durationPerImage: null,
    totalDuration: null,
    resolution: DEFAULT_RESOLUTION,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        printUsage();
        process.exit(0);
      case "-i":
      case "--input":
        args.input = argv[++i];
        break;
      case "-o":
      case "--output":
        args.output = argv[++i];
        break;
      case "--duration-per-image":
        args.durationPerImage = argv[++i];
        break;
      case "--total-duration":
        args.totalDuration = argv[++i];
        break;
      case "-r":
      case "--resolution":
        args.resolution = argv[++i];
        break;
      default:
        throw new Error(`Unknown option: ${arg}`);
    }
  }

  if (!args.input) {
    throw new Error("Missing required option: -i / --input <file>");
  }

  if (args.durationPerImage && args.totalDuration) {
    throw new Error(
      "--duration-per-image and --total-duration are mutually exclusive. Use one or the other."
    );
  }

  const resMatch = args.resolution.match(/^(\d+)x(\d+)$/);
  if (!resMatch) {
    throw new Error(
      `Invalid resolution "${args.resolution}". Use WxH format (e.g., 1920x1080)`
    );
  }
  args.width = parseInt(resMatch[1], 10);
  args.height = parseInt(resMatch[2], 10);

  return args;
}

// --- Dependency Checks ---

function checkDependency(name) {
  try {
    execSync(`which ${name}`, { stdio: "ignore" });
  } catch {
    throw new Error(
      `"${name}" is not installed or not in PATH. Please install it and try again.`
    );
  }
}

// --- Image Reading ---

function readImageList(inputFile) {
  if (!fs.existsSync(inputFile)) {
    throw new Error(`Input file not found: ${inputFile}`);
  }

  const raw = fs.readFileSync(inputFile, "utf-8").trim();
  let lines;

  // Detect JSON format (from pick-images session file)
  if (raw.startsWith("{")) {
    try {
      const session = JSON.parse(raw);
      if (!session.favorites || session.favorites.length === 0) {
        throw new Error("JSON session file contains no favorites.");
      }
      lines = session.favorites;
    } catch (err) {
      if (err.message.includes("no favorites")) throw err;
      throw new Error(`Input file looks like JSON but failed to parse: ${err.message}`);
    }
  } else {
    // Plain text: one image path per line
    const inputDir = path.dirname(path.resolve(inputFile));
    lines = raw
      .split(/\r?\n/)
      .map((l) => l.trim())
      .filter((l) => l && !l.startsWith("#"))
      .map((l) => (path.isAbsolute(l) ? l : path.resolve(inputDir, l)));
  }

  if (lines.length === 0) {
    throw new Error("Input file contains no image paths.");
  }

  const images = [];
  for (const line of lines) {
    const resolved = line;

    if (!fs.existsSync(resolved)) {
      throw new Error(`Image not found: ${resolved} (from line: "${line}")`);
    }

    const ext = path.extname(resolved).toLowerCase();
    if (!ALL_SUPPORTED.has(ext)) {
      throw new Error(
        `Unsupported format "${ext}" for file: ${resolved}\nSupported: ${[...ALL_SUPPORTED].join(", ")}`
      );
    }

    images.push({ original: resolved, ext });
  }

  return images;
}

// --- RAW Conversion ---

function convertRawImages(images, tempDir) {
  const needsConversion = images.filter((img) => RAW_FORMATS.has(img.ext));

  if (needsConversion.length > 0) {
    checkDependency("dcraw_emu");
    console.log(
      `Converting ${needsConversion.length} RAW image(s) via LibRaw...`
    );
  }

  return images.map((img) => {
    if (!RAW_FORMATS.has(img.ext)) {
      return { ...img, path: img.original };
    }

    const baseName = path.basename(img.original);
    const convertedPath = path.join(tempDir, `${baseName}.tiff`);
    // dcraw_emu outputs <input_path>.tiff next to the source file
    const dcrawOutput = `${img.original}.tiff`;

    try {
      // -w: use camera white balance
      // -T: output TIFF
      // -o 1: sRGB color space
      // -q 3: AHD interpolation (high quality)
      execSync(
        `dcraw_emu -w -T -o 1 -q 3 "${img.original}"`,
        { stdio: "pipe" }
      );

      if (!fs.existsSync(dcrawOutput)) {
        throw new Error(`Expected output not found: ${dcrawOutput}`);
      }

      // Move to temp directory to avoid polluting the source directory
      fs.renameSync(dcrawOutput, convertedPath);
    } catch (err) {
      // Clean up in case of partial failure
      try { fs.unlinkSync(dcrawOutput); } catch {}
      try { fs.unlinkSync(convertedPath); } catch {}
      throw new Error(
        `Failed to convert ${img.original}: ${err.stderr?.toString() || err.message}`
      );
    }

    return { ...img, path: convertedPath, converted: true };
  });
}

// --- FFmpeg Video Creation ---

function buildVideo(images, durationPerImageSec, width, height, outputFile, tempDir) {
  // Build concat demuxer file
  const concatLines = images.map(
    (img) => `file '${img.path.replace(/'/g, "'\\''")}'\\nduration ${durationPerImageSec}`
  );
  // FFmpeg concat demuxer needs the last image repeated without duration
  concatLines.push(`file '${images[images.length - 1].path.replace(/'/g, "'\\''")}'`);

  const concatFile = path.join(tempDir, "concat.txt");
  const concatContent = images
    .map(
      (img) =>
        `file '${img.path.replace(/'/g, "'\\''")}'\nduration ${durationPerImageSec}`
    )
    .join("\n");
  // Append last image without duration (FFmpeg concat demuxer requirement)
  const lastLine = `\nfile '${images[images.length - 1].path.replace(/'/g, "'\\''")}'`;
  fs.writeFileSync(concatFile, concatContent + lastLine, "utf-8");

  // Scale filter: fit inside target resolution, pad with black bars
  const vf = `scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1`;

  const ffmpegArgs = [
    "-y",
    "-f", "concat",
    "-safe", "0",
    "-i", concatFile,
    "-vf", vf,
    "-c:v", "libx264",
    "-pix_fmt", "yuv420p",
    "-movflags", "+faststart",
    outputFile,
  ];

  console.log(`\nCreating video: ${outputFile}`);
  console.log(
    `  Resolution: ${width}x${height} | Duration per image: ${durationPerImageSec}s | Images: ${images.length}`
  );
  console.log(
    `  Total duration: ~${(durationPerImageSec * images.length).toFixed(1)}s\n`
  );

  const result = spawnSync("ffmpeg", ffmpegArgs, {
    stdio: ["ignore", "pipe", "pipe"],
  });

  if (result.status !== 0) {
    const stderr = result.stderr?.toString() || "";
    throw new Error(`FFmpeg failed (exit code ${result.status}):\n${stderr}`);
  }
}

// --- Cleanup ---

function cleanup(tempDir) {
  try {
    fs.rmSync(tempDir, { recursive: true, force: true });
  } catch {
    // Ignore cleanup errors
  }
}

// --- Main ---

function main() {
  let tempDir = null;

  try {
    const args = parseArgs(process.argv.slice(2));

    checkDependency("ffmpeg");

    const images = readImageList(args.input);
    console.log(`Found ${images.length} image(s) in ${args.input}`);

    // Calculate duration per image in seconds
    let durationPerImageSec;
    if (args.totalDuration) {
      const totalSec = parseDuration(args.totalDuration);
      durationPerImageSec = totalSec / images.length;
    } else {
      durationPerImageSec = parseDuration(
        args.durationPerImage || DEFAULT_DURATION
      );
    }

    if (durationPerImageSec <= 0) {
      throw new Error("Duration per image must be greater than 0.");
    }

    // Create temp directory for conversions
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "images-to-video-"));

    // Convert RAW images if needed
    const processedImages = convertRawImages(images, tempDir);

    // Build video
    buildVideo(
      processedImages,
      durationPerImageSec,
      args.width,
      args.height,
      args.output,
      tempDir
    );

    console.log(`\n✓ Video created: ${path.resolve(args.output)}`);
  } catch (err) {
    console.error(`\n✗ Error: ${err.message}`);
    process.exit(1);
  } finally {
    if (tempDir) cleanup(tempDir);
  }
}

main();
