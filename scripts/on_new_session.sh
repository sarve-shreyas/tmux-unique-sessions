#!/usr/bin/env bash
# Entry point: find ALL sessions that own this workspace and show them via
# choose-tree so the user gets the native session preview (like prefix + s).

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/logger.sh"
source "$CURRENT_DIR/options.sh"
source "$CURRENT_DIR/workspace_helpers.sh"

CURRENT_SESSION_NAME="$1"
CURRENT_WORKSPACE="$(get_workspace_path "$CURRENT_SESSION_NAME")"
tmux_work_log_info "current workspace: $CURRENT_WORKSPACE"

# ── collect ALL sessions registered to this workspace (excluding current) ────
FOUND_SESSIONS=()
for s in $(tmux list-sessions -F '#{session_name}'); do
    [[ "$s" == "$CURRENT_SESSION_NAME" ]] && continue
    value="$(tmux show-option -qv -t "$s" "$OPTION")"
    tmux_work_log_info "session=$s workspace=$value"
    if [[ "$value" == "$CURRENT_WORKSPACE" ]]; then
        FOUND_SESSIONS+=("$s")
    fi
done

# ── no match: register current session and exit ──────────────────────────────
if [[ ${#FOUND_SESSIONS[@]} -eq 0 ]]; then
    tmux_work_log_info "no session found for workspace: $CURRENT_WORKSPACE"
    register_workspace "$CURRENT_SESSION_NAME" "$CURRENT_WORKSPACE"
    exit 0
fi

tmux_work_log_info "found ${#FOUND_SESSIONS[@]} session(s) for workspace: $CURRENT_WORKSPACE"

# ── register now so the session is tracked even if user detaches mid-picker ──
register_workspace "$CURRENT_SESSION_NAME" "$CURRENT_WORKSPACE"

# ── attach strategy: skip picker and attach immediately if set to always ──────
attach_strategy="$(tmux show-option -gqv "$ATTACH_SESSION_STRATEGY_OPTION")"
: "${attach_strategy:=$ATTACH_STRATEGY_ASK}"
tmux_work_log_info "attach strategy='$attach_strategy'"

if [[ "$attach_strategy" == "$ATTACH_STRATEGY_ALWAYS" ]]; then
    auto_select_strategy="$(tmux show-option -gqv "$AUTO_SELECT_STRATEGY_OPTION")"
    : "${auto_select_strategy:=$AUTO_SELECT_STRATEGY_MOST_RECENT}"
    best_session="$(get_best_session "$auto_select_strategy" "${FOUND_SESSIONS[@]}")"
    tmux_work_log_info "auto-attaching to '$best_session' (attach=always, select=$auto_select_strategy)"
    exec "$CURRENT_DIR/confirm_attach.sh" "$best_session" "$CURRENT_SESSION_NAME"
fi

# ── build nested OR filter so choose-tree only shows relevant sessions ────────
# Includes found sessions + current session (shown as ★ NEW so user can stay).
# Filter syntax: #{||:cond_a,cond_b} — nested for 3+ sessions.
build_filter() {
    local sessions=("$@")
    if [[ ${#sessions[@]} -eq 1 ]]; then
        printf '#{==:#{session_name},%s}' "${sessions[0]}"
    else
        local first="${sessions[0]}"
        local rest=("${sessions[@]:1}")
        printf '#{||:#{==:#{session_name},%s},%s}' "$first" "$(build_filter "${rest[@]}")"
    fi
}

all_sessions=("${FOUND_SESSIONS[@]}" "$CURRENT_SESSION_NAME")
filter="$(build_filter "${all_sessions[@]}")"

# ── format: mark the new (current) session with ★ ───────────────────────────
# #{session_name} and #{session_windows} are expanded by tmux at display time.
format="#{?#{==:#{session_name},$CURRENT_SESSION_NAME},★ NEW ,      }  #{session_name}  (#{session_windows} windows)"

# ── show choose-tree ─────────────────────────────────────────────────────────
# -Z  zoom the pane (full screen, like prefix + s)
# -s  start at session level
# -f  filter — only show matching sessions
# -F  format string for each row
# template: #{session_name} is expanded by tmux to the selected session's name
tmux choose-tree -Zs \
    -f "$filter" \
    -F "$format" \
    "run-shell '$CURRENT_DIR/choose_handler.sh #{session_name} $CURRENT_SESSION_NAME'"

