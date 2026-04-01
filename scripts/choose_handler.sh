#!/usr/bin/env bash
# Routes the choose-tree selection to either confirm_attach or deny_attach.
# Called automatically by the choose-tree template in tmux_rename.sh.
#
# Usage: choose_handler.sh <selected_session> <current_session>

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SELECTED_SESSION="$1"
CURRENT_SESSION="$2"

if [[ "$SELECTED_SESSION" == "$CURRENT_SESSION" ]]; then
    # User picked the ★ NEW entry — stay, just register
    exec "$CURRENT_DIR/deny_attach.sh" "$SELECTED_SESSION" "$CURRENT_SESSION"
else
    # User picked an existing session — attach (and honour delete strategy)
    exec "$CURRENT_DIR/confirm_attach.sh" "$SELECTED_SESSION" "$CURRENT_SESSION"
fi
