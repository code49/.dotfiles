#!/usr/bin/env bash
#
# Setup script to clone and initialize ~/personal-work repositories.
#

set -euo pipefail

# ANSI color codes
if [[ -t 1 ]]; then
    COLOR_RESET="\033[0m"
    COLOR_BOLD="\033[1m"
    COLOR_PURPLE="\033[38;2;189;178;255m"
    COLOR_GREEN="\033[38;2;202;255;191m"
    COLOR_YELLOW="\033[38;2;253;255;182m"
    COLOR_RED="\033[38;2;255;173;173m"
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_PURPLE=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""
fi

header() {
    printf "\n%b==>%b %b%s%b\n" "$COLOR_PURPLE" "$COLOR_RESET" "$COLOR_BOLD" "$1" "$COLOR_RESET"
}

info() {
    printf "%b[INFO]%b %s\n" "$COLOR_GREEN" "$COLOR_RESET" "$1"
}

warn() {
    printf "%b[WARN]%b %s\n" "$COLOR_YELLOW" "$COLOR_RESET" "$1"
}

error() {
    printf "%b[ERROR]%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$1" >&2
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Clones and initializes all personal work repositories into ~/personal-work.

Options:
  --https       Use HTTPS clone URLs (default uses SSH: git@github.com:code49/...)
  -h, --help    Show this help message

Repositories:
  - cardDashboard
  - code49
  - displayThingy
  - logoImage
  - personalWebsite2
  - resume
  - spotifySorter
  - streamSilencer
EOF
}

USE_HTTPS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --https)
            USE_HTTPS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

TARGET_DIR="${HOME}/personal-work"
GITHUB_USER="code49"

REPOS=(
    "cardDashboard"
    "code49"
    "displayThingy"
    "logoImage"
    "personalWebsite2"
    "resume"
    "spotifySorter"
    "streamSilencer"
)

header "Setting up personal-work environment"

if [[ ! -d "$TARGET_DIR" ]]; then
    info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
else
    info "Target directory exists: $TARGET_DIR"
fi

cd "$TARGET_DIR"

for repo in "${REPOS[@]}"; do
    if [[ "$USE_HTTPS" == true ]]; then
        REPO_URL="https://github.com/${GITHUB_USER}/${repo}.git"
    else
        REPO_URL="git@github.com:${GITHUB_USER}/${repo}.git"
    fi

    if [[ -d "$repo" ]]; then
        if [[ -d "$repo/.git" ]]; then
            info "Repository '${repo}' already exists. Fetching updates..."
            git -C "$repo" fetch --prune || warn "Fetch failed for ${repo}. Check network or credentials."
        else
            warn "Directory '${repo}' exists but is not a Git repository. Skipping."
        fi
    else
        info "Cloning '${repo}' from ${REPO_URL}..."
        git clone "$REPO_URL" "$repo" || error "Failed to clone ${repo}."
    fi
done

header "Setup complete!"
info "All repositories configured in ${TARGET_DIR}."
