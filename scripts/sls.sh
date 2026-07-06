#!/usr/bin/env bash

# sls.sh - Super LS
# An improved ls wrapper that always shows hidden files and supports a split view.

show_help() {
    cat << EOF
Usage: $(basename "$0") [options] [directory]

An improved ls wrapper that displays directory contents grouped by subsections
(directories, symlinks, files, and their hidden counterparts) side-by-side.
Always includes hidden files (-A).

Options:
  -f, --flat     Disable split view (standard flat ls view)
  -s, --split    Enable split view (default)
  -t, -T, --tree Enable recursive tree view (defaults to depth 3)
                 You can optionally specify depth: -t [depth] (e.g., -t 2)
  -g, --git      Show 'git status' at the bottom of the output if in a git repository
  --help         Show this help message

All other flags (e.g., -l, -S, -h) are passed directly to the underlying commands.
In tree mode, passing -l and -h displays file permissions, owner, date, and sizes.
EOF
}

MODE="split"
TREE_DEPTH=3
GIT_STATUS=false
PARAMS=()
TARGET=""

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -f|--flat|--no-split)
            MODE="flat"
            shift
            ;;
        -s|--split)
            MODE="split"
            shift
            ;;
        -t|-T|--tree)
            MODE="tree"
            shift
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                TREE_DEPTH="$1"
                shift
            fi
            ;;
        -g|--git)
            GIT_STATUS=true
            shift
            ;;
        -*)
            PARAMS+=("$1")
            shift
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
            else
                PARAMS+=("$1")
            fi
            shift
            ;;
    esac
done

# Default to current directory if none specified
TARGET="${TARGET:-.}"

# Handle Tree Mode
if [ "$MODE" = "tree" ]; then
    if ! command -v tree >/dev/null 2>&1; then
        echo "Error: 'tree' command is required for tree-view mode but is not installed." >&2
        exit 1
    fi

    # Parse formatting options
    HAS_L=false
    HAS_H=false
    TREE_PARAMS=()
    for p in "${PARAMS[@]}"; do
        if [[ "$p" =~ ^-[^-]*l || "$p" == "--format=long" || "$p" == "--format=verbose" ]]; then
            HAS_L=true
        elif [[ "$p" =~ ^-[^-]*h || "$p" == "--human-readable" ]]; then
            HAS_H=true
        else
            TREE_PARAMS+=("$p")
        fi
    done

    TREE_ARGS=(-L "$TREE_DEPTH" -a -C -F --dirsfirst)
    if [ "$HAS_L" = true ]; then
        TREE_ARGS+=(-p -u -g -D)
        if [ "$HAS_H" = true ]; then
            TREE_ARGS+=(-h)
        else
            TREE_ARGS+=(-s)
        fi
    elif [ "$HAS_H" = true ]; then
        TREE_ARGS+=(-s -h)
    fi

    # Get absolute path for relative targets to print in parentheses
    abs_target=""
    if [[ "$TARGET" != /* ]]; then
        abs_target=$(cd "$TARGET" 2>/dev/null && pwd)
    fi

    # Run tree and pipe its output to format the first line
    first=true
    tree "${TREE_ARGS[@]}" "${TREE_PARAMS[@]}" "$TARGET" | while IFS= read -r line; do
        if [ "$first" = true ]; then
            first=false
            if [ -n "$abs_target" ]; then
                echo "${line} ($abs_target)"
            else
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done
    EXIT_CODE=${PIPESTATUS[0]}

    if [ "$GIT_STATUS" = true ]; then
        if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            COLOR_TITLE="\e[1;34m"
            COLOR_RESET="\e[0m"
            echo
            echo -e "${COLOR_TITLE}== git status ==${COLOR_RESET}"
            git -C "$TARGET" -c color.status=always status
        fi
    fi
    exit $EXIT_CODE
fi

# Fallback: if split view is requested but target is not a directory
if [ "$MODE" = "split" ] && [ ! -d "$TARGET" ]; then
    ls -A --color=auto -F "${PARAMS[@]}" "$TARGET"
    EXIT_CODE=$?
    if [ "$GIT_STATUS" = true ]; then
        if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            COLOR_TITLE="\e[1;34m"
            COLOR_RESET="\e[0m"
            echo
            echo -e "${COLOR_TITLE}== git status ==${COLOR_RESET}"
            git -C "$TARGET" -c color.status=always status
        fi
    fi
    exit $EXIT_CODE
fi

# Determine SPLIT boolean for compatibility with split rendering logic below
if [ "$MODE" = "split" ]; then
    SPLIT=true
else
    SPLIT=false
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

    # Check if one-file-per-line is requested
    HAS_1=false
    for p in "${PARAMS[@]}"; do
        if [[ "$p" =~ ^-[^-]*1 ]]; then
            HAS_1=true
            break
        fi
    done

    # Helper function to print a section of the directory listing
    print_section() {
        local title="$1"
        shift
        local find_args=("$@")
        
        local items
        items=$(find "$TARGET" -maxdepth 1 -mindepth 1 "${find_args[@]}" -printf "%P\n" 2>/dev/null | sort)
        
        # If no items found, don't print the header or anything.
        if [ -z "$items" ]; then
            return
        fi
        
        echo -e "${COLOR_TITLE}== $title ==${COLOR_RESET}"
        
        (
            cd "$TARGET" || exit
            
            # Determine color mode
            local color_mode="always"
            for p in "${PARAMS[@]}"; do
                if [[ "$p" == --color=* ]]; then
                    color_mode=""
                    break
                fi
            done

            local ls_params=(-d -F)
            if [ -n "$color_mode" ]; then
                ls_params+=("--color=$color_mode")
            fi
            ls_params+=("${PARAMS[@]}")

            if [ "$HAS_L" = false ]; then
                ls_params+=(-1)
            fi
            
            if [[ "$title" == *symlinks* && "$HAS_L" = false ]]; then
                # Custom symlink formatting to show targets
                echo "$items" | while IFS= read -r item; do
                    [ -z "$item" ] && continue
                    local colored_link
                    colored_link=$(ls "${ls_params[@]}" "$item" 2>/dev/null)
                    colored_link="${colored_link%"${colored_link##*[![:space:]]}"}"
                    if [[ "$colored_link" == *@ ]]; then
                        colored_link="${colored_link%@}"
                    fi
                    
                    local target
                    target=$(readlink "$item" 2>/dev/null)
                    
                    local colored_target
                    colored_target=$(ls -d "${ls_params[@]}" "$target" 2>/dev/null)
                    if [ -n "$colored_target" ]; then
                        colored_target="${colored_target%"${colored_target##*[![:space:]]}"}"
                        if [[ "$colored_target" == *@ ]]; then colored_target="${colored_target%@}"; fi
                        if [[ "$colored_target" == */ ]]; then colored_target="${colored_target%/}"; fi
                        if [[ "$colored_target" == *\* ]]; then colored_target="${colored_target%\*}"; fi
                    else
                        colored_target="$target"
                    fi
                    
                    echo -e "$colored_link -> $colored_target"
                done
            else
                # Pass sorted names to ls for colored/formatted output
                echo "$items" | xargs -d '\n' ls "${ls_params[@]}" 2>/dev/null
            fi
        )
    }

    COLS=$(tput cols 2>/dev/null || echo 80)

    if command -v python3 >/dev/null 2>&1 && [ "$HAS_L" = false ] && [ "$HAS_1" = false ]; then
        {
            print_section "directories" -type d -not -name ".*"
            echo "---SLS-SECTION-SEPARATOR---"
            print_section "hidden directories" -type d -name ".*" -not -name "." -not -name ".."
            echo "---SLS-SECTION-SEPARATOR---"
            print_section "files" -not -type d -not -type l -not -name ".*"
            echo "---SLS-SECTION-SEPARATOR---"
            print_section "hidden files" -not -type d -not -type l -name ".*"
            echo "---SLS-SECTION-SEPARATOR---"
            print_section "symlinks" -type l -not -name ".*"
            echo "---SLS-SECTION-SEPARATOR---"
            print_section "hidden symlinks" -type l -name ".*"
        } | python3 -c '
import sys
import re
import shutil

ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")

def visual_len(s):
    return len(ansi_escape.sub("", s).expandtabs())

def main():
    content = sys.stdin.read()
    raw_sections = content.split("---SLS-SECTION-SEPARATOR---\n")
    sections = []
    
    for sec in raw_sections:
        sec = sec.strip("\n")
        if not sec:
            continue
        lines = sec.split("\n")
        title = lines[0]
        body = [l for l in lines[1:] if l]
        if body:
            sections.append((title, body))
            
    if not sections:
        return

    print() # Leading newline for output spacing

    try:
        term_width = int(sys.argv[1])
    except (IndexError, ValueError):
        term_width = shutil.get_terminal_size().columns

    col_widths = []
    for title, body in sections:
        w = max([visual_len(title)] + [visual_len(line) for line in body])
        col_widths.append(w)

    GAP = 4
    rows = []
    current_row = []
    current_width = 0
    
    for i, (title, body) in enumerate(sections):
        w = col_widths[i]
        if not current_row:
            current_row.append(i)
            current_width = w
        else:
            if current_width + GAP + w <= term_width:
                current_row.append(i)
                current_width += GAP + w
            else:
                rows.append(current_row)
                current_row = [i]
                current_width = w
    if current_row:
        rows.append(current_row)

    for row in rows:
        row_sections = [sections[idx] for idx in row]
        row_widths = [col_widths[idx] for idx in row]
        max_height = max(len(body) for title, body in row_sections) + 1
        
        for L in range(max_height):
            line_parts = []
            for col_idx, (title, body) in enumerate(row_sections):
                if L == 0:
                    text = title
                elif L - 1 < len(body):
                    text = body[L - 1]
                else:
                    text = ""
                
                text = text.expandtabs()
                if col_idx < len(row_sections) - 1:
                    w = row_widths[col_idx]
                    pad = w - visual_len(text)
                    line_parts.append(text + " " * pad)
                else:
                    line_parts.append(text)
            
            print((GAP * " ").join(line_parts))
        print()

if __name__ == "__main__":
    main()
' "$COLS"
    else
        # Fallback to vertical layout using original ls formatting
        FIRST_SECTION=true
        print_section_vertical() {
            local title="$1"
            shift
            local find_args=("$@")
            
            local items
            items=$(find "$TARGET" -maxdepth 1 -mindepth 1 "${find_args[@]}" -printf "%P\n" 2>/dev/null | sort)
            
            if [ -z "$items" ]; then
                return
            fi
            
            if [ "$FIRST_SECTION" = true ]; then
                echo
                FIRST_SECTION=false
            fi
            echo -e "${COLOR_TITLE}== $title ==${COLOR_RESET}"
            (
                cd "$TARGET" || exit
                local ls_params=(-d --color=auto -F)
                ls_params+=("${PARAMS[@]}")
                
                if [[ "$title" == *symlinks* && "$HAS_L" = false ]]; then
                    # Custom symlink formatting to show targets
                    local ls_params_sls=(-d -F --color=always)
                    ls_params_sls+=("${PARAMS[@]}")
                    echo "$items" | while IFS= read -r item; do
                        [ -z "$item" ] && continue
                        local colored_link
                        colored_link=$(ls "${ls_params_sls[@]}" "$item" 2>/dev/null)
                        colored_link="${colored_link%"${colored_link##*[![:space:]]}"}"
                        if [[ "$colored_link" == *@ ]]; then
                            colored_link="${colored_link%@}"
                        fi
                        
                        local target
                        target=$(readlink "$item" 2>/dev/null)
                        
                        local colored_target
                        colored_target=$(ls -d "${ls_params_sls[@]}" "$target" 2>/dev/null)
                        if [ -n "$colored_target" ]; then
                            colored_target="${colored_target%"${colored_target##*[![:space:]]}"}"
                            if [[ "$colored_target" == *@ ]]; then colored_target="${colored_target%@}"; fi
                            if [[ "$colored_target" == */ ]]; then colored_target="${colored_target%/}"; fi
                            if [[ "$colored_target" == *\* ]]; then colored_target="${colored_target%\*}"; fi
                        else
                            colored_target="$target"
                        fi
                        
                        echo -e "$colored_link -> $colored_target"
                    done
                else
                    if [ "$HAS_L" = false ] && [ "$HAS_1" = false ]; then
                        ls_params+=(-C)
                    fi
                    echo "$items" | xargs -d '\n' ls "${ls_params[@]}" 2>/dev/null
                fi
            )
            echo
        }
        
        print_section_vertical "directories" -type d -not -name ".*"
        print_section_vertical "hidden directories" -type d -name ".*" -not -name "." -not -name ".."
        print_section_vertical "files" -not -type d -not -type l -not -name ".*"
        print_section_vertical "hidden files" -not -type d -not -type l -name ".*"
        print_section_vertical "symlinks" -type l -not -name ".*"
        print_section_vertical "hidden symlinks" -type l -name ".*"
    fi
else
    # Default behavior: always show hidden (-A), group directories first
    ls -A --group-directories-first --color=auto -F "${PARAMS[@]}" "$TARGET"
    EXIT_CODE=$?
fi

# Print git status if requested and target is in a git repository
if [ "$GIT_STATUS" = true ]; then
    if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Default to blue title color if not already defined (flat mode / tree mode)
        COLOR_TITLE="${COLOR_TITLE:-\e[1;34m}"
        COLOR_RESET="${COLOR_RESET:-\e[0m}"
        echo
        echo -e "${COLOR_TITLE}== git status ==${COLOR_RESET}"
        git -C "$TARGET" -c color.status=always status
    fi
fi

if [ -n "$EXIT_CODE" ]; then
    exit $EXIT_CODE
fi
