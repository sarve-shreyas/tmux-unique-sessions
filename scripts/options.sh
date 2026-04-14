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

## workspace root anchoring strategy
## set via: tmux set-option -g @workspace_root_strategy "git,package"
## values (comma-separated, tried in order; first match wins):
##   git          - anchor to the nearest ancestor containing .git
##   package      - anchor to the nearest ancestor containing package.json
##   session_path - use the raw session path as-is (always the final fallback)
WORKSPACE_ROOT_STRATEGY_OPTION="@workspace_root_strategy"

## auto-rename session to workspace basename
## set via: tmux set-option -g @workspace_auto_rename "1"
## When enabled, a newly registered session is renamed according to
## @workspace_rename_strategy.  If the resulting name is already taken by
## another session, a numeric suffix is appended: nvim, nvim-2, nvim-3, …
WORKSPACE_AUTO_RENAME_OPTION="@workspace_auto_rename"

## rename strategy — controls how the session name is derived from the
## workspace path.  Only applies when @workspace_auto_rename is "1".
## set via: tmux set-option -g @workspace_rename_strategy "basename"
## values:
##   basename        - directory name only            (~/.config/nvim → nvim)
##   parent-basename - parent/name, useful in monorepos (packages/ui → packages/ui)
##   git-branch      - name:branch when inside a git repo (myapp:feature/login);
##                     falls back to basename outside a git repo
##   relative        - path relative to $HOME         (projects/myapp → projects/myapp);
##                     falls back to basename when path is outside $HOME
##   workspace-root  - basename of the project root resolved via
##                     @workspace_root_strategy (e.g. git root → myapp);
##                     falls back to basename when no root anchor matches
WORKSPACE_RENAME_STRATEGY_OPTION="@workspace_rename_strategy"
WORKSPACE_RENAME_STRATEGY_BASENAME="basename"
WORKSPACE_RENAME_STRATEGY_PARENT_BASENAME="parent-basename"
# WORKSPACE_RENAME_STRATEGY_GIT_BRANCH="git-branch"
WORKSPACE_RENAME_STRATEGY_RELATIVE="relative"
WORKSPACE_RENAME_STRATEGY_WORKSPACE_ROOT="workspace-root"

