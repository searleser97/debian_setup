# Debian Setup Repository

This repository contains configuration files and setup scripts for a Debian development environment.

## Configuration Files

### Claude Code Settings
**File**: `claude-settings.json`

This file contains Claude Code permissions configuration that minimizes permission prompts.

**To use:**
```bash
cp claude-settings.json ~/.claude/settings.json
```

**What it includes:**
- File editing permissions (`Edit:*`, `Write:*`)
- Common development tools (npm, pip, docker, etc.)
- Git commands
- File operations and text processing tools

### GitHub Copilot Instructions
**File**: `copilot-instructions.md`

Custom instructions for GitHub Copilot to use `rg` and `fd` commands for searching.

## Setup

1. Clone this repository
2. Copy the configuration files to their respective locations
3. Run setup scripts as needed

## Notes

- The Claude settings file allows common development operations without requiring repeated permission prompts
- Keep these files in sync with your active configurations as you make changes
