-- BEGIN task-dashboard
-- This loader line originated from the notif_dash profile (install.sh
-- --wezterm). It loads every *.lua that notif_dash drops into the
-- notif_dash/ folder beside this file (currently the focus tracker). An
-- absent or empty folder is a no-op, so this stays safe even on a machine
-- where notif_dash is not installed.
local _nd = require 'wezterm'
for _, _f in ipairs(_nd.glob(_nd.config_dir .. '/notif_dash/*.lua')) do
    dofile(_f)
end
-- END task-dashboard

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
--   events/command_palette.lua  adds custom actions to the command palette
--   plugins/resurrect.lua  shared resurrect.wezterm plugin handle
--
-- Each config/* module returns a function(config) that mutates the shared
-- config builder. WezTerm puts ~/.config/wezterm on package.path, so the
-- dotted require paths below resolve to the files above.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Event handlers (registered on load).
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
