-- WezTerm configuration entry point.
--
-- This file stays thin: it builds the config object, registers event
-- handlers, and applies each settings module in turn. The actual settings
-- live in the module tree:
--
--   config/general.lua     graphics, notifications, scrollback
--   config/fonts.lua       font stack + fallbacks
--   config/appearance.lua  tab bar / window chrome
--   config/keys.lua        Terminator-compatible keybindings
--   config/mouse.lua       mouse bindings
--   config/session.lua     session persistence (resurrect.wezterm autosave)
--   config/custom_commands.lua  single source of truth: custom commands
--                          (key+action+label) shared by keys + palette
--   events/focus.lua       task-dashboard focus tracker (notif-dash)
--   events/command_palette.lua  adds custom actions to the command palette
--   plugins/resurrect.lua  shared resurrect.wezterm plugin handle
--
-- Each config/* module returns a function(config) that mutates the shared
-- config builder. WezTerm puts ~/.config/wezterm on package.path, so the
-- dotted require paths below resolve to the files above.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Event handlers (registered on load; required for notif-dash to work).
require 'events.focus'
require 'events.command_palette'   -- adds custom actions to the command palette

-- Settings modules, applied in order.
for _, mod in ipairs({
  'general',
  'fonts',
  'appearance',
  'keys',
  'mouse',
  'session',
}) do
  require('config.' .. mod)(config)
end

return config
