# tmux-workspaces

> Prevents duplicate tmux sessions — detects when a workspace is already open and routes you to it.

When you create a new tmux session inside a directory that is already owned by another session, `tmux-workspaces` intercepts and presents the existing session(s) so you can switch to them instead of ending up with duplicates.

---

## How it works

1. A new session is created → the plugin fires via the `after-new-session` hook
2. It checks all existing sessions to find any that were launched from the same directory
3. **No match** → the new session is registered and you continue as normal
4. **Match found** → depending on your `@workspace_attach_strategy`:
   - `ask` — a full-screen `choose-tree` picker appears (like `prefix + s`) showing only the relevant sessions with a live preview. The new session is marked **★ NEW** so you can always tell it apart
   - `always` — silently attaches to the best matching session using your `@workspace_auto_select_strategy`
5. After attaching, `@workspace_delete_strategy` decides whether the new (now abandoned) session is kept or killed

---

## Installation

### Using [tpm](https://github.com/tmux-plugins/tpm)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'sarve-shreyas/tmux-unique-sessions'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/sarve-shreyas/tmux-unique-sessions \
    ~/.config/tmux-plugins/tmux-unique-sessions
```

Add to `~/.tmux.conf`:

```tmux
run '~/.config/tmux-plugins/tmux-unique-sessions/workspace_sessions.tmux'
```

Then reload: `tmux source ~/.tmux.conf`

---

## Configuration

All options are set globally in `~/.tmux.conf` with `set -g`.

### `@workspace_attach_strategy`

Controls whether the picker is shown or the plugin attaches silently.

| Value | Behaviour | Default |
|---|---|---|
| `ask` | Show the `choose-tree` picker | ✓ |
| `always` | Auto-attach without prompting, using `@workspace_auto_select_strategy` | |

```tmux
set -g @workspace_attach_strategy "ask"
```

---

### `@workspace_auto_select_strategy`

Only applies when `@workspace_attach_strategy` is `always`. Determines which session is picked when multiple sessions match the workspace.

| Value | Behaviour | Default |
|---|---|---|
| `most-recent` | Session most recently attached to | ✓ |
| `oldest` | Session that has existed the longest |  |
| `first` | First matching session found, no ranking |  |

```tmux
set -g @workspace_auto_select_strategy "most-recent"
```

---

### `@workspace_delete_strategy`

Controls what happens to the new session after switching away from it.

| Value | Behaviour | Default |
|---|---|---|
| `never` | Keep the new session alive | ✓ |
| `always` | Kill the new session after switching |  |
| `greater:N` | Kill the new session only when total session count exceeds `N` |  |

```tmux
set -g @workspace_delete_strategy "never"

# examples
set -g @workspace_delete_strategy "always"
set -g @workspace_delete_strategy "greater:5"
```

---

### `@tmux_work_logging`

Enable debug logging to `/tmp/tmux-work.log`. `ERROR` level is always written regardless of this setting.

```tmux
set -g @tmux_work_logging "1"   # enable
# unset or "0"                  # disable (default)
```

---

## Example config

```tmux
set -g @plugin 'your-username/tmux-workspaces'

# Show picker when a duplicate workspace is detected
set -g @workspace_attach_strategy     "ask"

# When auto-attaching, prefer the most recently used session
set -g @workspace_auto_select_strategy "most-recent"

# Kill the new session after switching if there are more than 5 sessions open
set -g @workspace_delete_strategy     "greater:5"
```

---

## File structure

```
workspace_sessions.tmux      # plugin entry point — loaded by tpm or run directly
scripts/
  on_new_session.sh          # after-new-session hook; finds matches and shows picker
  confirm_attach.sh          # called when user confirms attach
  deny_attach.sh             # called when user chooses to stay
  choose_handler.sh          # routes choose-tree selection to confirm/deny
  workspace_helpers.sh       # shared functions (get_workspace_path, register_workspace, get_best_session)
  options.sh                 # all @workspace_* option names and constants
  logger.sh                  # levelled logging (INFO, WARN, ERROR, DEBUG)
```

---

## License

MIT
