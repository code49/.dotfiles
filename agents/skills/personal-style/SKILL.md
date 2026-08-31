---
name: personal-style
description: Preserves and enforces David Chan's personal coding style, Nix architecture patterns, UI/CSS design language, shell scripting style, and writing voice across all codebases.
---

# Personal Style Guide (code49)

This skill documents and enforces David Chan's core design system, architectural patterns, scripting conventions, and writing voice across all projects (`.dotfiles`, `personalWebsite2`, `terminalTools`, etc.).

---

## 🎨 1. Aesthetic & UI Design Language

### Theme Palette (Base16 Dual-Mode)

Standardize all web applications, desktop configurations, and terminal UI components to inherit from the Base16 pastel dark/light color scheme:

- **Grayscale (Backgrounds, Panels, Text):**
  - `base00`: `#1d1f21` — Primary dark background
  - `base01`: `#282a2e` — Secondary background (cards, panels, input fields)
  - `base02`: `#373b41` — Borders, dividers, subtle strokes
  - `base03`: `#969896` — Muted text / captions
  - `base04`: `#b4b7b4` — Secondary muted text
  - `base05`: `#c5c8c6` — Secondary text
  - `base06` / `base07`: `#e0e0e0` / `#ffffff` — Primary white text
- **Dark Mode Accents:**
  - `base0D` (Primary Accent): `#bdb2ff` (soft periwinkle / lavender)
  - `base0B` (Secondary Accent): `#daa9ff` (soft magenta)
  - `base09` (Background Glow / Soft Red): `#f8cfd2`
  - `base0C` (Positive Delta / Success): `#caffbf` (mint pastel)
  - `base0A` (Highlight / Warning): `#fdffb6` (pastel yellow)
  - `base08` (Alert / Error): `#ffadad` (soft rose)
- **Light Mode Accents:**
  - Primary Accent: `#a32a2a` (semi-dark red)
  - Hover Accent: `#801b1b` (deeper red)
  - Soft Tint Background: `#fdf0f0` (tinted card background)
  - Dark Accent Contrast: `#661010`

### Typography & Casing Rules

1. **Monospace Font Stack:**
   - Default to `"JetBrains Mono"`, `"JetBrains Mono Nerd Font"`, or `font-family: monospace;`.
2. **Body & Headings:**
   - Use clean modern sans-serif fonts such as `Inter` or `Outfit`.
3. **Casing Convention:**
   - **All-Lowercase UI Text**: For non-prose metadata, button labels, tag badges, section titles, and navigation links (e.g., `career highlights`, `download resume (light)`, `read article →`, `visit main website`).
   - Standard sentence case for body prose and article paragraphs.

### Component Design & Responsive Patterns

- **Glassmorphism & Thin Borders:**
  - Use subtle background opacities (`rgba(128, 128, 128, 0.05)`) with thin `1px solid #373b41` or `#e0e0e0` borders.
  - Hover states feature soft glowing shadows matching the active theme accent (`box-shadow: 0 0 10px rgba(163, 42, 42, 0.3)` in Light Mode, `rgba(189, 178, 255, 0.3)` in Dark Mode).
- **Responsive View Swaps:**
  - When screen widths are narrow ($\le 650\text{px}$), automatically degrade complex graphical or side-by-side elements (e.g., interactive subway maps, 100vw train tracks with locomotives) into clean, traditional vertical list cards.

---

## ❄️ 2. NixOS & Flake Architectural Patterns

1. **Centralized Theme Argument:**
   - Declare theme tokens (`base00`–`base0F`, RGB equivalents) once inside `flake.nix` under `theme` and pass via `specialArgs` (`inherit inputs systemSettings userSettings theme;`).
2. **Flake Input Consistency:**
   - Always enforce `inputs.nixpkgs.follows = "nixpkgs"` on input submodules to prevent duplicate nixpkgs evaluations.
3. **Modular Directory Structure:**
   - `hosts/`: Hardware-specific profiles (e.g. `hosts/dchan-laptop/`) with explicit power management rules (e.g. udev rules for Framework Storage Expansion USB autosuspend).
   - `home/`: User-space environment declarations managed via `home-manager` (`home.nix` + application configs).
   - `scripts/`: System helper utilities (e.g. `nix-rebuild-nice.sh`).

---

## 🐚 3. Shell Scripting Style

1. **Safety & Execution Controls:**
   - Always set `set -euo pipefail` in Bash scripts, or `set -e` in POSIX `/bin/sh` scripts.
2. **Portability First:**
   - Write system-agnostic scripts with zero heavy dependencies so they execute portably on Linux and macOS.
   - Resolve script paths relative to source:
     ```bash
     TERMINAL_TOOLS_PATH="${TERMINAL_TOOLS_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tools}"
     ```
3. **CLI Interface & Output Formatting:**
   - Detect terminal output (`if [[ ! -t 1 ]]; then`) to disable ANSI color codes when output is piped.
   - Provide structured helper functions (`header()`, `info()`, `warn()`, `error()`, `usage()`).
   - Use multi-line heredocs (`cat <<EOF`) for clean CLI `--help` messages.
   - Include interactive fallbacks with default prompts when arguments are omitted in terminal sessions.

---

## ✍️ 4. Writing Voice & Style

1. **Tone & Style:**
   - Technical, concise, and direct. Avoid conversational filler, marketing hype, or passive fluff.
   - State the core motivation, technical solution, and implementation outcome clearly.
2. **Prose Structure:**
   - Use bold lead-ins for key parameters (`tools: bash, git, python`).
   - Keep bullet points concise and scannable.
   - Use exact technical terms (e.g., "PCIe Gen5/Gen6 links", "digital IC design", "SRAMs", "Nix Flake").
