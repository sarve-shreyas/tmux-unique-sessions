#!/usr/bin/env bash
# Called when the user chooses NOT to attach to the found session.
# Keeps the current session intact and just logs the decision.
#
# Usage: deny_attach.sh <found_session> <current_session>

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/logger.sh"
source "$CURRENT_DIR/options.sh"
source "$CURRENT_DIR/workspace_helpers.sh"

FOUND_SESSION="$1"
CURRENT_SESSION="$2"

CURRENT_WORKSPACE="$(get_workspace_path "$CURRENT_SESSION")"

tmux_work_log_info "deny_attach: staying in '$CURRENT_SESSION' (found='$FOUND_SESSION' was ignored)"
register_workspace "$CURRENT_SESSION" "$CURRENT_WORKSPACE"
