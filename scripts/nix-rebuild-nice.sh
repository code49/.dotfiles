#!/bin/sh
#
# File for rebuilding + clearing older nix builds.
#

set -e # Exit immediately if a command exits with a non-zero status.

# Default values
ACTION="switch"
SAVE_GENERATIONS=10

show_help() {
    echo "Usage: $(basename "$0") [action] [generations]"
    echo ""
    echo "Rebuilds NixOS configuration and cleans up old generations."
    echo ""
    echo "Arguments:"
    echo "  action       The nixos-rebuild action to perform: 'switch', 'boot', or 'both'."
    echo "               'switch' (default) activates the configuration immediately."
    echo "               'boot' makes the configuration the default for the next boot."
    echo "               'both' is an alias for 'switch' (covers both boot and activation)."
    echo ""
    echo "  generations  Number of recent generations to keep during cleanup."
    echo "               Default: $SAVE_GENERATIONS"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message."
    echo ""
    echo "Example:"
    echo "  $(basename "$0") both 5    # Rebuild, switch, and keep 5 generations"
}

# Handle help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Parse Action
if [ -n "$1" ]; then
    case "$1" in
        switch|boot)
            ACTION="$1"
            ;;
        both)
            # 'switch' already covers 'boot' (updates bootloader and activates)
            ACTION="switch"
            ;;
        [0-9]*)
            # If first arg is a number, assume it's generations and keep default action
            SAVE_GENERATIONS="$1"
            ;;
        *)
            echo "Error: Invalid action '$1'. Must be 'switch', 'boot', or 'both'."
            show_help
            exit 1
            ;;
    esac
fi

# Parse Generations (if second arg provided)
if [ -n "$2" ]; then
    if echo "$2" | grep -qE '^[0-9]+$'; then
        SAVE_GENERATIONS="$2"
    else
        echo "Error: Generations must be a number. Received: '$2'"
        show_help
        exit 1
    fi
fi

echo "--- Starting NixOS rebuild ($ACTION) ---"

# Build and apply the configuration once
sudo nixos-rebuild "$ACTION" --flake ~/.dotfiles --upgrade-all

# attempt garbage collection
echo "--- Deleting generations older than the last $SAVE_GENERATIONS ---"
sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system "+$SAVE_GENERATIONS"

# Update bootloader with current generations (fast)
# This ensures that the boot menu accurately reflects the generations after GC
echo "--- Refreshing bootloader entries ---"
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot

echo "--- Bootloader entries (/boot/loader/entries) ---"
sudo ls -1 /boot/loader/entries/

echo "--- Generations after build ---"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

echo "Success: Rebuilt Nix, cleared older generations, and updated bootloader."
