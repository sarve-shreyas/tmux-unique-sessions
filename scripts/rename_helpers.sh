#!/usr/bin/env bash
# Session rename helpers.
# Source this file; do not execute it directly.
# Requires: options.sh, logger.sh, workspace_root.sh

# _session_exists <name>
# Returns 0 when a session with exactly that name exists, 1 otherwise.
_session_exists() {
    tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -qxF "$1"
}

# _unique_session_name <base>
# Returns <base> if no session uses it, otherwise <base>-2, <base>-3, …
_unique_session_name() {
    local base="$1"
    local name="$base"
    local i=2
    while _session_exists "$name"; do
        name="${base}-${i}"
        (( i++ ))
    done
    printf '%s' "$name"
}

# _session_base_name <raw_path>
# Derives the desired session name from the raw #{session_path} using
# @workspace_rename_strategy.  Prints the base name (without uniqueness suffix).
# Receives the un-resolved path so strategies like parent-basename reflect where
# the session was actually opened.  workspace-root resolves internally.
_session_base_name() {
    local raw_path="$1"
    local strategy
    strategy="$(tmux show-option -gqv "$WORKSPACE_RENAME_STRATEGY_OPTION" 2>/dev/null)"
    : "${strategy:=$WORKSPACE_RENAME_STRATEGY_BASENAME}"
    tmux_work_log_info "_session_base_name: raw_path='$raw_path' strategy='$strategy'"

    case "$strategy" in
        "$WORKSPACE_RENAME_STRATEGY_PARENT_BASENAME")
            local parent base
            parent="$(basename "$(dirname "$raw_path")")"
            base="$(basename "$raw_path")"
            if [[ "$parent" == "." || "$parent" == "/" ]]; then
                printf '%s' "$base"
            else
                printf '%s/%s' "$parent" "$base"
            fi
            ;;

        "$WORKSPACE_RENAME_STRATEGY_GIT_BRANCH")
            local base branch
            base="$(basename "$raw_path")"
            branch="$(git -C "$raw_path" rev-parse --abbrev-ref HEAD 2>/dev/null)"
            if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
                branch="${branch//\//-}"
                printf '%s:%s' "$base" "$branch"
            else
                printf '%s' "$base"
            fi
            ;;

        "$WORKSPACE_RENAME_STRATEGY_RELATIVE")
            local home_prefix="$HOME/"
            if [[ "$raw_path" == "$HOME" ]]; then
                printf '%s' "home"
            elif [[ "$raw_path" == "${home_prefix}"* ]]; then
                printf '%s' "${raw_path#"$home_prefix"}"
            else
                printf '%s' "$(basename "$raw_path")"
            fi
            ;;

        "$WORKSPACE_RENAME_STRATEGY_WORKSPACE_ROOT")
            local root
            root="$(resolve_workspace_root "$raw_path")"
            tmux_work_log_info "_session_base_name: workspace-root resolved='$root'"
            printf '%s' "$(basename "$root")"
            ;;

        *) # basename (default)
            printf '%s' "$(basename "$raw_path")"
            ;;
    esac
}

# auto_rename_session <session_name> <workspace_path>
# When @workspace_auto_rename is "1", renames the session according to
# @workspace_rename_strategy (with a numeric suffix if the name is taken).
# Always prints the final session name (renamed or original).
auto_rename_session() {
    local session="$1"
    local workspace="$2"
    local enabled
    enabled="$(tmux show-option -gqv "$WORKSPACE_AUTO_RENAME_OPTION" 2>/dev/null)"
    tmux_work_log_info "auto_rename_session: session='$session' workspace='$workspace' enabled='$enabled'"
    if [[ "$enabled" != "1" ]]; then
        tmux_work_log_info "auto_rename_session: disabled, keeping name '$session'"
        printf '%s' "$session"
        return 0
    fi

    local raw_path base new_name
    raw_path="$(tmux display-message -p -t "$session" '#{session_path}' 2>/dev/null)"
    tmux_work_log_info "auto_rename_session: raw_path='$raw_path'"
    base="$(_session_base_name "$raw_path")"
    new_name="$(_unique_session_name "$base")"
    tmux_work_log_info "auto_rename_session: base='$base' candidate='$new_name'"
    if [[ "$new_name" != "$session" ]]; then
        tmux_work_log_info "auto_rename_session: renaming '$session' → '$new_name'"
        tmux rename-session -t "$session" "$new_name"
    else
        tmux_work_log_info "auto_rename_session: name unchanged '$session'"
    fi
    printf '%s' "$new_name"
}
