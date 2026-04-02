#!/usr/bin/env bash
# Routes the choose-tree selection to either confirm_attach or deny_attach.
# Called automatically by the choose-tree template in tmux_rename.sh.
#
# Usage: choose_handler.sh <selected_session> <current_session>

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/logger.sh"

SELECTED_SESSION="$1"
CURRENT_SESSION="$2"

tmux_work_log_info "choose_handler: selected='$SELECTED_SESSION' current='$CURRENT_SESSION'"

if [[ "$SELECTED_SESSION" == "$CURRENT_SESSION" ]]; then
    # User picked the ★ NEW entry — stay, just register
    tmux_work_log_info "choose_handler: user chose new session, delegating to deny_attach"
    exec "$CURRENT_DIR/deny_attach.sh" "$SELECTED_SESSION" "$CURRENT_SESSION"
else
    # User picked an existing session — attach (and honour delete strategy)
    tmux_work_log_info "choose_handler: user chose existing session '$SELECTED_SESSION', delegating to confirm_attach"
    exec "$CURRENT_DIR/confirm_attach.sh" "$SELECTED_SESSION" "$CURRENT_SESSION"
fi
