# WezTerm Configuration

A modular [WezTerm](https://wezterm.org) configuration built as a **Terminator-compatible** terminal: it reproduces Terminator's keybindings and copy-on-select behavior while adding inline image support, session persistence, and a task-completion notification hook.

## Highlights

- **Terminator-style keybindings** — splits, pane navigation, tabs, copy/paste, zoom, and resize all use the muscle-memory shortcuts from GNOME Terminator.
- **Inline images** — Kitty graphics protocol enabled, so tools that emit images render them directly in the terminal.
- **Session persistence** — save/restore/delete window layouts (tabs, panes, working directories) via [`resurrect.wezterm`](https://github.com/MLFlexer/resurrect.wezterm), with automatic background autosave every 5 minutes.
- **Task-completion notifications** — desktop notifications when a long-running command finishes, with a focus tracker that lets an external task-dashboard suppress notifications for the pane you're actively watching.
- **Carefully layered font stack** — Nerd Font for text/icons, Symbola for media-control glyphs, Noto Color Emoji for emoji.
- **10,000-line scrollback** (vs. Terminator's 500-line default).

## Repository layout

The entry point stays thin — it builds the config object, registers event handlers, then applies each settings module in order. Each `config/*.lua` module returns a `function(config)` that mutates the shared config builder.

```
wezterm.lua              Entry point: builds config, wires modules + events
config/
  general.lua            Graphics, notifications, status interval, scrollback
  fonts.lua              Font stack with icon/emoji fallbacks
  appearance.lua         Tab bar / window chrome
  keys.lua               Terminator-compatible keybindings + session bindings
  mouse.lua              Copy-on-select / open-link mouse binding
  session.lua            resurrect.wezterm periodic autosave
events/
  focus.lua              Active-pane / window-focus tracker for task-dashboard
plugins/
  resurrect.lua          Shared resurrect.wezterm plugin handle
```

WezTerm puts `~/.config/wezterm` on `package.path`, so the dotted `require` paths (`config.general`, `events.focus`, `plugins.resurrect`) resolve to the files above.

## Keybindings

> Bindings below reflect the **actual configured behavior** in `config/keys.lua`. A few diverge from older comments in the file (noted inline).

### Splits & panes

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+O` | Split horizontally — new pane **below** (50%) |
| `Ctrl+Shift+E` | Split vertically — new pane to the **right** (50%) |
| `Alt+↑ / ↓ / ← / →` | Move focus to the adjacent pane in that direction |
| `Ctrl+Shift+N` | Focus next pane |
| `Ctrl+Shift+P` | Focus previous pane |
| `Ctrl+Shift+X` | Toggle zoom/maximise current pane |
| `Ctrl+Shift+Z` | Toggle zoom (same as `Ctrl+Shift+X` in WezTerm) |
| `Ctrl+Shift+↑ / ↓ / ← / →` | Resize current pane (5 cells in that direction) |
| `Super+R` | Rotate panes clockwise |
| `Super+Shift+R` | Rotate panes counter-clockwise |
| `Ctrl+Shift+W` | Close current pane (no confirmation) |

### Tabs & windows

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+PageDown` | Next tab |
| `Ctrl+PageUp` | Previous tab |
| `Ctrl+Shift+Q` | Close current tab (no confirmation) |
| `Ctrl+Shift+I` | New window |
| `F2` | Rename current tab (prompt) |
| `F3` | Show tab navigator |
| `Ctrl+Shift+Alt+A` | Hide/minimise window (closest WezTerm equivalent to Terminator's global hide) |

### Copy / paste / search

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+C` | Copy to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+Shift+F` | Search scrollback |
| `Ctrl+Shift+Space` | Enter copy mode |
| Left-click drag | Select and copy to clipboard + primary selection; clicking a link opens it |

### Font size

| Shortcut | Action |
| --- | --- |
| `Ctrl++` / `Ctrl+=` | Increase font size |
| `Ctrl+-` | Decrease font size |
| `Ctrl+0` | Reset font size |

### Reset / clear

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+G` | Reset terminal **and** clear scrollback |

> Note: Terminator's standalone reset on `Ctrl+Shift+R` was intentionally dropped — that key now **restores a session** (see below).

### Session persistence

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+S` | Save the current window (its tabs/panes) as a named snapshot |
| `Ctrl+Shift+R` | Fuzzy-pick a saved session and restore it |
| `Ctrl+Shift+D` | Fuzzy-pick a saved session and **delete** it |

## Features in detail

### Inline image support

`config.enable_kitty_graphics = true` (`config/general.lua`) turns on the Kitty graphics protocol, letting image-emitting tools render pictures inline in the terminal.

### Notifications & focus tracking

- `config.notification_handling = 'AlwaysShow'` shows desktop notifications when a task completes.
- `config.status_update_interval = 200` (ms) controls how often `update-status` fires and paces the focus tracker.
- `events/focus.lua` registers two event handlers (`update-status` and `window-focus-changed`) that write a single line — `<active_pane_id> <window_focused 0|1>` — to a focus file, atomically (write-to-temp + rename) and deduplicated so periodic ticks don't churn the file.

**Focus file location:** `$TASK_DASHBOARD_DIR/focus`, defaulting to `~/.local/share/task-dashboard/focus`.

This is consumed by an **external** companion (`shell/task-dashboard.bash`, not part of this repo): a bash `precmd` hook reads the focus file at command-end to decide whether to suppress a "task done" notification for the pane you're already watching. The WezTerm side here only *produces* the focus signal; install the shell hook separately to use it.

### Session persistence (resurrect.wezterm)

- `plugins/resurrect.lua` holds a single shared handle to the plugin (cloned and cached once by `wezterm.plugin.require`), so the autosave timer and the keybindings share one plugin object.
- `config/session.lua` registers a **periodic autosave every 300 seconds** covering workspaces, windows, and tabs — so a restore always has a recent snapshot available.
- Saved state captures the layout and each pane's working directory, and re-runs pane processes on restore.

**Limitation:** restore brings back cwd and re-launches pane processes, but it does **not** restore shell scrollback, command history, or in-flight commands — a fundamental terminal limitation.

### Fonts

`config/fonts.lua` defines a fallback stack:

1. **UbuntuSansMono Nerd Font Mono** — primary text plus powerline/Nerd Font icons (no ligatures).
2. **Symbola** — media-control glyphs `⏵ ⏸ ⏺` (e.g. Claude Code mode indicators, U+23F4–F7).
3. **Noto Color Emoji** — color emoji such as ✅ ⚠️ 🚀.

### Appearance

`config/appearance.lua` keeps the tab bar enabled but uses the **classic compact** bar (`use_fancy_tab_bar = false`) for a look closer to Terminator. Set `enable_tab_bar = false` if you only ever use a single tab.

### Scrollback

`config.scrollback_lines = 10000` — far above Terminator's 500-line default.

## Requirements & dependencies

- **WezTerm** (recent build; uses `config_builder`, Kitty graphics, `wezterm.plugin`).
- **Fonts:** `UbuntuSansMono Nerd Font`, `Symbola`, and `Noto Color Emoji` installed for the full glyph coverage above. Missing fonts fall back to WezTerm defaults but lose icons/emoji fidelity.
- **resurrect.wezterm plugin** — fetched automatically over the network on first load via `wezterm.plugin.require`. The first launch needs connectivity to `github.com`.
- **(Optional) task-dashboard shell hook** — `shell/task-dashboard.bash` (external) to consume the focus file for notification suppression.

## Customising

- **Single-tab users:** set `config.enable_tab_bar = false` in `config/appearance.lua`.
- **Autosave cadence:** change `interval_seconds` in `config/session.lua`.
- **Scrollback depth:** change `config.scrollback_lines` in `config/general.lua`.
- **Keybindings:** edit `config/keys.lua`; each binding is a plain table in `config.keys`.
- WezTerm hot-reloads the config on save, so most changes apply without restarting.
