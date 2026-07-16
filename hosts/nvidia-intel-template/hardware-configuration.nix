# ❄️ Hardware Configuration Placeholder
#
# Replace the contents of this file with the output generated on your system:
# sudo nixos-generate-config --show-hardware-config > ~/.dotfiles/hosts/<your-host-name>/hardware-configuration.nix
#
# If you chose disk encryption (LUKS) during installation, ensure your luks mount devices
# (e.g. boot.initrd.luks.devices.*) are copied into this file.

{ config, lib, pkgs, modulesPath, ... }:

{
  # Template / Placeholder structure
  imports = [ ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { };
  fileSystems."/boot" = { };
  swapDevices = [ ];
}
