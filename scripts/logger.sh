#!/usr/bin/env bash

# Returns 0 (true) when logging is enabled via:  set -g @tmux_work_logging "1"
tmux_work_logging_enabled() {
    local value
    value="$(tmux show-option -gqv @tmux_work_logging 2>/dev/null || true)"
    [[ "$value" = "1" ]]
}

tmux_work_log_file() {
    printf '%s\n' "/tmp/tmux-work.log"
}

tmux_work_log() {
    local level="$1"
    shift
    local msg="$*"
    local file
    file="$(tmux_work_log_file)"
    mkdir -p "$(dirname "$file")"
    printf '[tmux-work][%s] %s\n' "$level" "$msg" >> "$file"
}

tmux_work_log_info() {
    tmux_work_logging_enabled || return 0
    tmux_work_log "INFO" "$*"
}

tmux_work_log_warn() {
    tmux_work_logging_enabled || return 0
    tmux_work_log "WARN" "$*"
}

# ERROR is always logged regardless of the logging option
tmux_work_log_error() {
    tmux_work_log "ERROR" "$*"
}

tmux_work_log_debug() {
    tmux_work_logging_enabled || return 0
    tmux_work_log "DEBUG" "$*"
}

