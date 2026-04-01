#!/usr/bin/env bash

## option we will set for session
OPTION="@workspace_dir"

## attach session strategy option
## set via: tmux set-option -g @workspace_attach_strategy "always"  (or "ask")
## values:
##   ask    - show the choose-tree picker so the user decides (default)
##   always - silently attach to the best session using auto_select_strategy
ATTACH_SESSION_STRATEGY_OPTION="@workspace_attach_strategy"
ATTACH_STRATEGY_ASK="ask"
ATTACH_STRATEGY_ALWAYS="always"

## auto-select strategy — used when attach_strategy=always to pick which
## session to attach to when multiple sessions match the workspace.
## set via: tmux set-option -g @workspace_auto_select_strategy "most-recent"
## values:
##   most-recent - attach to the session most recently used/attached (default)
##   oldest      - attach to the session that has existed the longest
##   first       - attach to whichever session was found first (no ranking)
AUTO_SELECT_STRATEGY_OPTION="@workspace_auto_select_strategy"
AUTO_SELECT_STRATEGY_MOST_RECENT="most-recent"
AUTO_SELECT_STRATEGY_OLDEST="oldest"
AUTO_SELECT_STRATEGY_FIRST="first"

## delete session strategy option
## set via: tmux set-option -g @workspace_delete_strategy "always"
##           tmux set-option -g @workspace_delete_strategy "never"
##           tmux set-option -g @workspace_delete_strategy "greater:5"
## values:
##   always      - always kill the current session after switching
##   never       - keep the current session alive after switching (default)
##   greater:N   - kill the current session only when the total number of
##                 sessions is greater than N  (e.g. "greater:5")
DELETE_SESSION_STRATEGY_OPTION="@workspace_delete_strategy"
DELETE_STRATEGY_ALWAYS="always"
DELETE_STRATEGY_NEVER="never"
DELETE_STRATEGY_GREATER_PREFIX="greater:"

