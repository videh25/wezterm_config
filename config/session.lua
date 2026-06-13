-- Session persistence (resurrect.wezterm).
--
-- Saves workspace layout (windows/tabs/panes) + each pane's cwd. The
-- save/restore keybindings live in config/keys.lua:
--   Ctrl+Shift+S → save current workspace snapshot
--   Ctrl+Shift+D → fuzzy-pick a saved session and restore it (manual, optional)
--
-- Autosave runs in the background so a restore always has a recent snapshot.
-- NOTE: restores cwd + re-runs pane processes; it does NOT restore shell
-- scrollback, history, or in-flight commands (terminal limitation).
local resurrect = require 'plugins.resurrect'

return function(config)
  resurrect.state_manager.periodic_save({
    interval_seconds = 300,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
  })
end
