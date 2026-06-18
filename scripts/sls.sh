#!/usr/bin/env bash

# sls.sh - Super LS
# An improved ls wrapper that always shows hidden files and supports a split view.

show_help() {
    cat << EOF
Usage: $(basename "$0") [options] [directory]

An improved ls wrapper that always shows hidden files and supports a split view.
Always includes hidden files (-A) and groups directories first.

Options:
  -s, --split    Enable split view (Groups: Directories, Symlinks, Files)
  -h, --help     Show this help message

All other flags (e.g., -l, -t, -S, -h) are passed directly to the 'ls' command.

In split view, symlinks are displayed with their targets:
  link -> /path/to/target
EOF
}

SPLIT=false
PARAMS=()
TARGET=""

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--split)
            SPLIT=true
            ;;
        -*)
            PARAMS+=("$arg")
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$arg"
            else
                PARAMS+=("$arg")
            fi
            ;;
    esac
done

# Default to current directory if none specified
TARGET="${TARGET:-.}"

# If split view is requested but target is not a directory, fall back to normal ls
if [ "$SPLIT" = true ] && [ ! -d "$TARGET" ]; then
    exec ls -A --color=auto -F "${PARAMS[@]}" "$TARGET"
fi

if [ "$SPLIT" = true ]; then
    COLOR_TITLE="\e[1;34m" # Bold Blue
    COLOR_RESET="\e[0m"

    # Check if long listing is requested
    HAS_L=false
    for p in "${PARAMS[@]}"; do
        if [[ "$p" =~ ^-[^-]*l || "$p" == "--format=long" || "$p" == "--format=verbose" ]]; then
            HAS_L=true
            break
        fi
    done

    # Helper function to print a section of the directory listing
    print_section() {
        local title="$1"
        shift
        local find_args=("$@")
        
        local items
        items=$(find "$TARGET" -maxdepth 1 -mindepth 1 "${find_args[@]}" -printf "%P
" 2>/dev/null | sort)
        
        # If no items found, don't print the header or anything.
        if [ -z "$items" ]; then
            return
        fi
        
        echo -e "${COLOR_TITLE}== $title ==${COLOR_RESET}"
        
        (
            cd "$TARGET" || exit
            local ls_params=(-d --color=auto -F)
            ls_params+=("${PARAMS[@]}")

            # When not using a long list format, force multi-column output.
            # This provides a more horizontal, `ls`-like view.
            if [ "$HAS_L" = false ]; then
                # The GNU ls `-C` flag forces column output.
                ls_params+=(-C)
            fi
            
            # Pass sorted names to ls for colored/formatted output
            echo "$items" | xargs -d '
' ls "${ls_params[@]}" 2>/dev/null
        )
        echo
    }

    print_section "Directories" -type d -not -name ".*"
    print_section "Hidden Directories" -type d -name ".*" -not -name "." -not -name ".."
    print_section "Symlinks" -type l -not -name ".*"
    print_section "Hidden Symlinks" -type l -name ".*"
    print_section "Files" -not -type d -not -type l -not -name ".*"
    print_section "Hidden Files" -not -type d -not -type l -name ".*"
else
    # Default behavior: always show hidden (-A), group directories first
    exec ls -A --group-directories-first --color=auto -F "${PARAMS[@]}" "$TARGET"
fi
