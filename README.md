# ❄️ code49's NixOS Dotfiles

A premium, customized NixOS Flake & Home Manager configuration designed for daily productivity. This repository is tailored specifically for a **Framework 13 laptop** powered by the **AMD Ryzen AI 9 / Radeon 890M** platform, running the **Hyprland** tiling window manager.

---

## 🖥️ System & Hardware Profile

*   **Machine:** Framework Laptop 13 (AMD Ryzen AI 9 / Radeon 890M integrated graphics)
*   **Processor Architecture:** `x86_64-linux` (utilizing AMD-specific microcode and `kvm-amd`)
*   **Video Driver:** `amdgpu` (fully Wayland-compatible)
*   **Monitor Configuration:** Tailored in [hosts/dchan-laptop/configuration.nix](hosts/dchan-laptop/configuration.nix):
    *   **Internal Screen (`eDP-1`):** 2880x1920 @ 60Hz (scaled at 1.67 for high-DPI comfort)
    *   **External Screens (`DP-1` / `DP-2`):** Multi-monitor arrangements for home/office desks (scaled at 1.00)

---

## 🎨 Aesthetics & Theme

This configuration uses a sleek, customized theme based on a grayscale palette with rich **Violet, Purple, and Magenta** highlights:
*   **Cursor Theme:** `GoogleDot-Violet` (size 12)
*   **Palette:**
    *   `base00` - `base07`: Seamless dark-mode grayscale background and text tones.
    *   `base0D`: **Purple** as the primary accent color.
    *   `base0B`: **Magenta** as the secondary accent color.
    *   `base09`: **Light Pink/Red** as the tertiary/background accent.
*   **Dark Mode:** Standardized across GTK (Adwaita-dark), Qt (adwaita-dark), and Gnome interfaces.

---

## 🛠️ Software Stack & Key Features

*   **Window Manager:** [Hyprland](home/hyprland/hyprland.nix) (with smooth animations, workspace bindings, and custom column layouts)
*   **Shell:** [Zsh](home/home.nix) paired with [Starship](home/starship/starship.nix) prompt and [Zoxide](home/home.nix) (`cd` replacement)
*   **Terminal Emulator:** [Kitty](home/kitty/kitty.nix) (configured with custom fonts and subtle transparency)
*   **Text Editors:** [Helix](home/helix/helix.nix) and [VS Code](home/vscode/vscode.nix)
*   **System Bar & Notifications:** [Waybar](home/waybar/waybar.nix) (custom layout with battery, network, audio, and clock indicators) & [Mako](home/mako/mako.nix)
*   **Application Launcher:** [Wofi](home/wofi/wofi.nix)
*   **Lockscreen / Idle:** [Swaylock](home/swaylock/swaylock.nix) & [Swayidle](configuration.nix)
*   **CJK Language Support:** Full Chinese, Japanese, and Korean input support via Fcitx5 configured with `qt5`, `qt6`, and `gtk` IM modules.

---

## 📦 Custom Scripts & Submodules

### `terminalTools` Submodule
Tracked at [terminalTools/](terminalTools/), this submodule points to [terminalTools](https://github.com/code49/terminalTools.git) and contains several lightweight, dependency-free utilities:
*   **`sls` (Smart LS):** A terminal-based directory lister featuring split columns, recursive tree mode, and Git status support (aliased to `lss`).
*   **`ff` (Firefox Launcher):** A script wrapper offering an interactive `fzf` prompt to search bookmarks, shortcuts, or history and launch Firefox containers directly.
*   **`gitac`:** Quick wrapper to add all changes and commit with a message (`gitac "commit message"`).

### Rebuilder Script
*   **`nix-rebuild-nice.sh`:** Located in [scripts/nix-rebuild-nice.sh](scripts/nix-rebuild-nice.sh) and aliased to `nix-reb`.
    *   Rebuilds and activates the NixOS configuration using the local flake.
    *   Automatically cleans up old system generations (keeps the last **25** generations by default).
    *   Cleans and updates GDM bootloader entries immediately after garbage collection.
    *   Supports interactive choice between `switch` and `boot` mode, or running directly with CLI parameters.

---

## 📂 Repository Structure

```
.
├── flake.nix                  # Flake entry point, defines inputs, outputs, system settings
├── configuration.nix          # System-level configurations, services, default packages, inputs
├── INSTALLATION.md            # Walkthrough guide for setting up this configuration
├── hosts/
│   ├── dchan-laptop/          # Host-specific settings for Framework 13 AMD
│   │   ├── configuration.nix  # Host monitor scaling and networking overrides
│   │   └── hardware-configuration.nix # Local hardware layout & kernel modules (generated)
│   └── nvidia-intel-template/ # Template configuration for Intel CPU + NVIDIA GPU systems
│       ├── configuration.nix  # Pre-configured proprietary drivers, Prime, and graphics overrides
│       └── hardware-configuration.nix # Template hardware-configuration file
├── home/                      # User-level packages and configurations (Home Manager)
│   ├── home.nix               # Main Home Manager entry point (packages, environment, aliases)
│   └── [apps]/                # App configs (hyprland, waybar, kitty, helix, vscode, etc.)
├── terminalTools/             # Submodule containing custom portable utilities (sls, ff, gitac)
└── scripts/                   # System helper scripts (e.g., nix-rebuild-nice.sh)
```

---

## 🚀 Getting Started

If you are setting up this configuration on a new device, please refer to the detailed step-by-step setup guide in **[INSTALLATION.md](INSTALLATION.md)**.
