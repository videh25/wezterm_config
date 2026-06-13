-- Terminator-compatible keybindings.
--
-- Terminator → WezTerm mapping reference:
--   Ctrl+Shift+O       → Split horizontal (pane below)
--   Ctrl+Shift+E       → Split vertical (pane to the right)
--   Ctrl+Shift+W       → Close current pane
--   Ctrl+Shift+Q       → Close current tab
--   Ctrl+Shift+T       → New tab
--   Ctrl+Shift+I       → New window
--   Alt+Up/Down/Left/Right → Move focus between panes
--   Ctrl+PageDown      → Next tab
--   Ctrl+PageUp        → Previous tab
--   Ctrl+Shift+N       → Next pane (cycle)
--   Ctrl+Shift+P       → Prev pane (cycle)
--   Ctrl+Shift+X       → Zoom/maximise current pane (toggle)
--   Ctrl+Shift+Z       → Zoom current pane (scaled, same as X in WezTerm)
--   Ctrl+Shift+F       → Find / search scrollback
--   Ctrl+Shift+C       → Copy
--   Ctrl+Shift+V       → Paste
--   Ctrl+Shift+R       → Reset terminal (RIS; keeps scrollback)
--   Ctrl+Shift+G       → Clear terminal (reset + clear scrollback)
--   Ctrl++ / Ctrl+-    → Increase / decrease font size
--   Ctrl+0             → Reset font size
--   Ctrl+Shift+ArrowKey → Resize pane (replaces Terminator dragbar keys)
--   Super+R            → Rotate panes clockwise
--   Super+Shift+R      → Rotate panes counter-clockwise
--   Ctrl+Shift+Alt+A   → Hide window (minimise)
--   Ctrl+Shift+K       → Command palette (searchable action/keybinding list)
--
-- Session persistence (resurrect.wezterm; see config/session.lua):
--   Ctrl+Shift+S       → Save current window as a named snapshot
--   Ctrl+Shift+B       → Fuzzy-pick and restore a saved session
--   Ctrl+Shift+D       → Fuzzy-pick and delete a saved session

local wezterm = require 'wezterm'
local act = wezterm.action
local custom = require 'config.custom_commands'   -- single source of truth for custom commands (also feed the palette)

return function(config)
  config.keys = {

    -- ── Splits ────────────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+O → split horizontally (new pane below)
    {
      key = 'o', mods = 'CTRL|SHIFT',
      action = act.SplitPane {
        direction = 'Down',
        size = { Percent = 50 },
      },
    },
    -- Terminator: Ctrl+Shift+E → split vertically (new pane to the right)
    {
      key = 'e', mods = 'CTRL|SHIFT',
      action = act.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },

    -- ── Close ─────────────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+W → close current terminal
    {
      key = 'w', mods = 'CTRL|SHIFT',
      action = act.CloseCurrentPane { confirm = false },
    },
    -- Terminator: Ctrl+Shift+Q → close current tab
    {
      key = 'q', mods = 'CTRL|SHIFT',
      action = act.CloseCurrentTab { confirm = false },
    },

    -- ── Tabs ──────────────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+T → new tab
    {
      key = 't', mods = 'CTRL|SHIFT',
      action = act.SpawnTab 'CurrentPaneDomain',
    },
    -- Terminator: Ctrl+PageDown → next tab
    {
      key = 'PageDown', mods = 'CTRL',
      action = act.ActivateTabRelative(1),
    },
    -- Terminator: Ctrl+PageUp → previous tab
    {
      key = 'PageUp', mods = 'CTRL',
      action = act.ActivateTabRelative(-1),
    },

    -- ── New window ────────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+I → new window
    {
      key = 'i', mods = 'CTRL|SHIFT',
      action = act.SpawnCommandInNewWindow {},
    },

    -- ── Pane focus (Alt+Arrow) ─────────────────────────────────────────────────
    -- Terminator: Alt+Up/Down/Left/Right → move to adjacent terminal
    {
      key = 'UpArrow', mods = 'ALT',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'DownArrow', mods = 'ALT',
      action = act.ActivatePaneDirection 'Down',
    },
    {
      key = 'LeftArrow', mods = 'ALT',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'RightArrow', mods = 'ALT',
      action = act.ActivatePaneDirection 'Right',
    },

    -- ── Pane cycling ──────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+N → next pane
    {
      key = 'n', mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Next',
    },
    -- Terminator: Ctrl+Shift+P → previous pane
    {
      key = 'p', mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Prev',
    },

    -- ── Zoom / maximise ────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+X → maximise current terminal (toggle)
    -- Terminator: Ctrl+Shift+Z → zoom current terminal (same in WezTerm)
    {
      key = 'x', mods = 'CTRL|SHIFT',
      action = act.TogglePaneZoomState,
    },
    {
      key = 'z', mods = 'CTRL|SHIFT',
      action = act.TogglePaneZoomState,
    },

    -- ── Resize panes (replaces Terminator's dragbar Ctrl+Shift+Arrow) ──────────
    -- Terminator: Ctrl+Shift+Right → move dragbar right (expand current pane)
    {
      key = 'RightArrow', mods = 'CTRL|SHIFT',
      action = act.AdjustPaneSize { 'Right', 5 },
    },
    {
      key = 'LeftArrow', mods = 'CTRL|SHIFT',
      action = act.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = 'UpArrow', mods = 'CTRL|SHIFT',
      action = act.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = 'DownArrow', mods = 'CTRL|SHIFT',
      action = act.AdjustPaneSize { 'Down', 5 },
    },

    -- ── Rotate panes ──────────────────────────────────────────────────────────
    -- Super+R → rotate clockwise
    {
      key = 'r', mods = 'SUPER',
      action = act.RotatePanes 'Clockwise',
    },
    -- Super+Shift+R → rotate counter-clockwise
    {
      key = 'r', mods = 'SUPER|SHIFT',
      action = act.RotatePanes 'CounterClockwise',
    },

    -- ── Copy / Paste ───────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+C → copy
    {
      key = 'c', mods = 'CTRL|SHIFT',
      action = act.CopyTo 'Clipboard',
    },
    -- Terminator: Ctrl+Shift+V → paste
    {
      key = 'v', mods = 'CTRL|SHIFT',
      action = act.PasteFrom 'Clipboard',
    },

    -- ── Search scrollback ──────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+F → find
    {
      key = 'f', mods = 'CTRL|SHIFT',
      action = act.Search { CaseSensitiveString = '' },
    },

    -- ── Reset / Clear ──────────────────────────────────────────────────────────
    -- Ctrl+Shift+R → reset terminal (RIS; keeps scrollback) is defined in
    -- config/custom_commands.lua and appended below.
    -- Terminator: Ctrl+Shift+G → reset + clear scrollback
    {
      key = 'g', mods = 'CTRL|SHIFT',
      action = act.Multiple {
        act.SendString '\x1bc',
        act.ClearScrollback 'ScrollbackOnly',
      },
    },

    -- ── Font size ──────────────────────────────────────────────────────────────
    -- Terminator: Ctrl++ / Ctrl+= → increase font size
    {
      key = '+', mods = 'CTRL',
      action = act.IncreaseFontSize,
    },
    {
      key = '=', mods = 'CTRL',
      action = act.IncreaseFontSize,
    },
    -- Terminator: Ctrl+- → decrease font size
    {
      key = '-', mods = 'CTRL',
      action = act.DecreaseFontSize,
    },
    -- Terminator: Ctrl+0 → reset font size
    {
      key = '0', mods = 'CTRL',
      action = act.ResetFontSize,
    },

    -- ── Hide window ────────────────────────────────────────────────────────────
    -- Terminator: Ctrl+Shift+Alt+A → hide/show window
    -- Note: WezTerm can't truly hide itself from within a keybinding the way
    -- Terminator does (it's an X11 global). Use your WM/compositor instead.
    -- Mapped here to minimise as the closest equivalent.
    {
      key = 'a', mods = 'CTRL|SHIFT|ALT',
      action = act.Hide,
    },

    -- ── Misc ───────────────────────────────────────────────────────────────────
    -- (F2 → rename tab is defined in config/custom_commands.lua, appended below.)
    { key = 'F3', mods = 'NONE',
      action = act.ShowTabNavigator,
    },

    -- Ctrl+Shift+K → command palette (searchable list of actions + their keys).
    -- Overrides WezTerm's default ClearScrollback on this key; Ctrl+Shift+G
    -- already covers reset+clear, so nothing is lost.
    { key = 'k', mods = 'CTRL|SHIFT',
      action = act.ActivateCommandPalette,
    },

    -- { key = 'j', mods = 'CTRL|SHIFT', action = act.ScrollByLine(1) },
    -- { key = 'k', mods = 'CTRL|SHIFT', action = act.ScrollByLine(-1) },
    -- { key = 'u', mods = 'CTRL|SHIFT', action = act.ScrollByPage(-0.5) },
    -- { key = 'd', mods = 'CTRL|SHIFT', action = act.ScrollByPage(0.5) },
    { key = 'Space', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },

    -- ── Session persistence (resurrect.wezterm) ────────────────────────────────
    -- Ctrl+Shift+S → save the CURRENT WINDOW (its tabs/panes) as a named
    -- snapshot — other open WezTerm windows are not included.
    -- Type a name to keep multiple sessions side by side; leave blank to save
    -- under the window title; Esc to cancel.
    -- Names appear in the Ctrl+Shift+B restore picker (under 'window').
    -- Save (Ctrl+Shift+S), restore (Ctrl+Shift+B) and delete (Ctrl+Shift+D)
    -- are defined in config/custom_commands.lua and appended below, so they
    -- stay in sync with their command-palette entries.

  }

  -- Append the custom commands (defined once in custom_commands.lua) to the
  -- keymap. The same specs feed the command palette via
  -- events/command_palette.lua, so a rebind there updates both.
  for _, c in ipairs(custom.commands) do
    table.insert(config.keys, { key = c.key, mods = c.mods, action = c.action })
  end
end
