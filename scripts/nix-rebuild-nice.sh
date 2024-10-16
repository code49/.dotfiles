#!/bin/sh
#
# File for rebuilding + clearing older than +5 generations of nix builds.
#

# NUMBER OF GENERATIONS TO SAVE
SAVE_GENERATIONS=5

# do initial rebuild
sudo nixos-rebuild switch --flake ~/.dotfiles --upgrade-all

# attempt garbage collection
sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system +$SAVE_GENERATIONS

# rebuild to make this actually show correctly on boot screen?
sudo nixos-rebuild switch --flake ~/.dotfiles --upgrade-all

# print message to remind that a reboot is likely required
echo "Rebuilt Nix, cleared older generations; the boot screen will be updated on reboot"
