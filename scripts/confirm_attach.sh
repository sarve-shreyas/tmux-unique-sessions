#!/usr/bin/env bash
# Called when the user confirms they want to attach to the found session.
# Switches the client to FOUND_SESSION, then honours @workspace_delete_strategy
# to decide whether to kill CURRENT_SESSION.
#
# Usage: confirm_attach.sh <found_session> <current_session>

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/logger.sh"
source "$CURRENT_DIR/options.sh"
source "$CURRENT_DIR/workspace_helpers.sh"

FOUND_SESSION="$1"
CURRENT_SESSION="$2"

tmux_work_log_info "confirm_attach: attaching to '$FOUND_SESSION' (current='$CURRENT_SESSION')"

# ── attach ───────────────────────────────────────────────────────────────────
tmux switch-client -t "$FOUND_SESSION"

# ── delete strategy ──────────────────────────────────────────────────────────
delete_strategy="$(tmux show-option -gqv "$DELETE_SESSION_STRATEGY_OPTION")"
: "${delete_strategy:=$DELETE_STRATEGY_NEVER}"   # default: never

tmux_work_log_info "confirm_attach: delete strategy='$delete_strategy'"

should_delete=false

if [[ "$delete_strategy" == "$DELETE_STRATEGY_ALWAYS" ]]; then
    should_delete=true
elif [[ "$delete_strategy" == ${DELETE_STRATEGY_GREATER_PREFIX}* ]]; then
    # extract the threshold number after "greater:"
    threshold="${delete_strategy#"$DELETE_STRATEGY_GREATER_PREFIX"}"
    total_sessions="$(tmux list-sessions | wc -l | tr -d ' ')"
    tmux_work_log_info "confirm_attach: greater strategy threshold=$threshold total=$total_sessions"
    if (( total_sessions > threshold )); then
        should_delete=true
    fi
fi

if [[ "$should_delete" == true ]]; then
    tmux_work_log_info "confirm_attach: killing session '$CURRENT_SESSION' (strategy: $delete_strategy)"
    tmux kill-session -t "$CURRENT_SESSION"
else
    tmux_work_log_info "confirm_attach: keeping session '$CURRENT_SESSION' (strategy: $delete_strategy)"
fi
