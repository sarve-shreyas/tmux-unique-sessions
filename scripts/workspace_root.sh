#!/usr/bin/env bash
# Workspace root anchoring helpers.
# Source this file; do not execute it directly.
# Requires: options.sh, logger.sh

# _find_ancestor_with <start_dir> <marker>
# Walks up the directory tree from <start_dir> looking for a directory that
# contains <marker> (a file or directory name).  Prints the first match, or
# nothing if not found.
_find_ancestor_with() {
    local dir="$1"
    local marker="$2"
    while [[ "$dir" != "/" ]]; do
        [[ -e "$dir/$marker" ]] && { printf '%s' "$dir"; return 0; }
        dir="$(dirname "$dir")"
    done
    [[ -e "/$marker" ]] && { printf '/'; return 0; }
    return 1
}

# _marker_for <strategy_name>
# Maps a strategy name to the corresponding filesystem marker.
_marker_for() {
    case "$1" in
        git)     printf '.git'         ;;
        package) printf 'package.json' ;;
    esac
}

# resolve_workspace_root <path>
# Applies @workspace_root_strategy to anchor <path> to the nearest project
# root.  Strategy is a comma-separated list of named anchors tried in order:
#   git          → nearest ancestor containing .git
#   package      → nearest ancestor containing package.json
#   session_path → use <path> as-is (implicit final fallback)
# Falls back to <path> unchanged when no anchor matches.
resolve_workspace_root() {
    local path="$1"
    local strategy
    strategy="$(tmux show-option -gqv "$WORKSPACE_ROOT_STRATEGY_OPTION" 2>/dev/null)"
    if [[ -z "$strategy" ]]; then
        printf '%s' "$path"
        return
    fi

    local root
    IFS=',' read -ra _strategies <<< "$strategy"
    for s in "${_strategies[@]}"; do
        s="${s// /}"  # trim whitespace
        [[ "$s" == "session_path" ]] && break
        local marker
        marker="$(_marker_for "$s")"
        [[ -z "$marker" ]] && continue
        root="$(_find_ancestor_with "$path" "$marker")"
        if [[ -n "$root" ]]; then
            tmux_work_log_info "resolve_workspace_root: '$path' → '$root' (via $s)"
            printf '%s' "$root"
            return
        fi
    done

    printf '%s' "$path"
}
