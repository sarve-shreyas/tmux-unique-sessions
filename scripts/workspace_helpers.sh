#!/usr/bin/env bash
# Shared workspace helper functions.
# Source this file; do not execute it directly.

# get_workspace_path <session_name>
# Prints the directory from which the session was originally launched.
# Uses #{session_path} which is set at session creation and never changes with cd.
get_workspace_path() {
    tmux display-message -p -t "$1" '#{session_path}'
}

# get_best_session <strategy> <session1> [session2 ...]
# Picks the best session from the candidates according to the strategy.
#   most-recent  - highest session_last_attached timestamp (default)
#   oldest       - lowest  session_created timestamp
#   first        - first candidate, no ranking
get_best_session() {
    local strategy="$1"
    shift
    local sessions=("$@")

    # default to most-recent when strategy is empty or unrecognised
    : "${strategy:=$AUTO_SELECT_STRATEGY_MOST_RECENT}"

    if [[ "$strategy" == "$AUTO_SELECT_STRATEGY_FIRST" ]]; then
        printf '%s' "${sessions[0]}"
        return
    fi

    local best_session="${sessions[0]}"
    local best_ts

    if [[ "$strategy" == "$AUTO_SELECT_STRATEGY_OLDEST" ]]; then
        best_ts="$(tmux display-message -p -t "$best_session" '#{session_created}')"
        for s in "${sessions[@]:1}"; do
            local ts
            ts="$(tmux display-message -p -t "$s" '#{session_created}')"
            if (( ts < best_ts )); then
                best_ts="$ts"
                best_session="$s"
            fi
        done
    else
        # most-recent (default)
        best_ts="$(tmux display-message -p -t "$best_session" '#{session_last_attached}')"
        for s in "${sessions[@]:1}"; do
            local ts
            ts="$(tmux display-message -p -t "$s" '#{session_last_attached}')"
            if (( ts > best_ts )); then
                best_ts="$ts"
                best_session="$s"
            fi
        done
    fi

    printf '%s' "$best_session"
}

# get_registered_workspace <session_name>
# Returns the workspace path recorded for a session.
# Reads the stored session option first; falls back to #{session_path} when
# the option has not been set yet (e.g. sessions created outside this plugin).
get_registered_workspace() {
    local session="$1"
    local value
    value="$(tmux show-option -qv -t "$session" "$OPTION" 2>/dev/null)"
    if [[ -z "$value" ]]; then
        value="$(get_workspace_path "$session")"
    fi
    printf '%s' "$value"
}

# register_workspace <session_name> <workspace_path>
# Stores the workspace path as a session option so future sessions can detect
# that this workspace is already owned.
register_workspace() {
    local session="$1"
    local workspace="$2"
    tmux_work_log_info "register_workspace: session='$session' workspace='$workspace'"
    tmux set-option -t "$session" "$OPTION" "$workspace"
}
