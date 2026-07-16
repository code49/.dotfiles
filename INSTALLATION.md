# ❄️ NixOS Installation & Setup Guide

This guide walks you through installing and applying this dotfiles configuration. It is tailored for the **Framework Laptop 13 (AMD Ryzen AI 9)** under the host profile `dchan-laptop`, but can be adapted for similar AMD-based configurations by replacing the `hardware-configuration.nix` file.

---

## 💾 Step 1: Create the Installer USB

### On another machine:
1. Download the Graphical ISO image (GNOME version) from the [NixOS Download Page](https://nixos.org/download/#nixos-iso).
2. Insert your USB drive and identify its device path using `lsblk` (e.g., `/dev/sda` or `/dev/nvmeX`).
3. Ensure the drive is unmounted:
   ```bash
   sudo umount /dev/sdX*
   ```
4. Flash the ISO to the USB drive:
   ```bash
   sudo dd if=path-to-nixos-image.iso of=/dev/sdX bs=4M conv=fsync status=progress
   ```
   *(Replace `/dev/sdX` with your actual USB device, e.g. `/dev/sda`—do not target a partition like `/dev/sda1`)*

---

## 💿 Step 2: Install NixOS on the Device

1. Boot your Framework 13 from the USB installer.
2. Connect to Wi-Fi using the system tray/settings menu.
3. Open the graphical installer and follow the instructions. Pay attention to the following recommendations:
    *   **Desktop Environment:** Choose **"No Desktop"** (we will install and run Hyprland directly from our flake config).
    *   **Unfree Software:** Check the box to allow unfree packages.
    *   **Partitioning:** Choose **"Erase disk"** and create a swap partition (ideally with hibernation support).
    *   **Encryption:** Check the box to **"Encrypt disk"** (highly recommended for portable laptops).

---

## ⚙️ Step 3: Bootstrap the Initial System

Once the installation completes and you reboot into the fresh NixOS install:

1. Connect to the internet using the NetworkManager interactive CLI:
   ```bash
   nmtui
   ```
2. Open the default configuration file for editing:
   ```bash
   sudoedit /etc/nixos/configuration.nix
   ```
3. Add `vim` and `git` to your system profile packages so we can clone and edit the dotfiles:
   ```nix
   environment.systemPackages = with pkgs; [
     vim
     git
   ];
   ```
4. Save and exit, then rebuild your system to apply these packages:
   ```bash
   sudo nixos-rebuild switch
   ```
5. Upgrade your system channel to track unstable:
   ```bash
   sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
   sudo nixos-rebuild switch --upgrade-all
   ```

---

## ❄️ Step 4: Clone and Setup the Configuration

Now we can pull down our custom dotfiles and apply them.

1. Clone this repository to your home directory at `~/.dotfiles`:
   ```bash
   git clone https://github.com/code49/.dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```
2. Initialize and download all Git submodules (this is required to fetch `terminalTools`):
   ```bash
   git submodule update --init --recursive
   ```
3. Copy the hardware configuration file generated during your specific install to replace the default profile:
   ```bash
   cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hosts/dchan-laptop/hardware-configuration.nix
   ```
4. **Luks Encryption Support:** If you chose to encrypt your disk in Step 2, look at your generated `/etc/nixos/configuration.nix` file. Look for lines resembling:
   ```nix
   boot.initrd.luks.devices."luks-UUID".device = "/dev/disk/by-uuid/UUID";
   ```
   Copy these lines and paste them inside the configuration block of your new `~/.dotfiles/hosts/dchan-laptop/hardware-configuration.nix` file.

---

## ✏️ Step 5: Customize Your Settings

Before rebuilding, make sure to customize the configuration for your own details:

1. **System Preferences:** In [flake.nix](flake.nix):
    *   Change `systemSettings.timezone` if you live in a different timezone.
    *   Update `userSettings.username` and `userSettings.name` to match your account.
2. **Git Credentials:** Near the bottom of [home/home.nix](home/home.nix), update your Git name and email address:
   ```nix
   programs.git = {
     enable = true;
     settings = {
       user.name = "Your Name";
       user.email = "your.email@example.com";
       init.defaultBranch = "master";
     };
   };
   ```

---

## 🚀 Step 6: Build & Switch to the Flake

1. Apply the configuration (make sure you are in `~/.dotfiles`):
   ```bash
   sudo nixos-rebuild switch --flake .#dchan-laptop --upgrade-all
   ```
2. Reboot your laptop.
3. You will boot into GDM (Gnome Display Manager). Select your user account and log in.
4. You will boot straight into Hyprland!
    *   Press `SUPER + Q` to open the Kitty terminal.
    *   Press `SUPER + M` to exit Hyprland.

---

## 🛠️ Step 7: Post-Install Configuration & Maintenance

### Changing Themes
All colors are configured globally in [flake.nix](flake.nix) under the `theme` variable inside the outputs block. We utilize a Base16 structure (`base00` to `base0F`). Changing these colors will automatically propagate to Kitty, Waybar, Wofi, Swaylock, and Hyprland upon the next system rebuild.

### System Updates
To rebuild and update your configurations in the future, use the nice rebuilder script:
```bash
nix-reb
```
*(This is an alias for `~/.dotfiles/scripts/nix-rebuild-nice.sh` which activates changes, cleans system generations keeping the last 25, and refreshes the GDM bootloader).*
