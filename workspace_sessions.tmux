#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOOK_CMD="run-shell '$CURRENT_DIR/scripts/on_new_session.sh #{session_name}'"

# Find the index of our hook if it is already registered.
# show-hooks output: after-new-session[0] = "run-shell '...'"
existing_index="$(tmux show-hooks -g 2>/dev/null \
    | grep "on_new_session.sh" \
    | sed "s/after-new-session\[\([0-9]*\)\].*/\1/" \
    | head -1)"

if [[ -n "$existing_index" ]]; then
    tmux set-hook -g "after-new-session[$existing_index]" "$HOOK_CMD"
else
    tmux set-hook -ag after-new-session "$HOOK_CMD"
fi

