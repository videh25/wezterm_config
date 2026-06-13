-- Shared handle to the resurrect.wezterm plugin.
--
-- wezterm.plugin.require clones the repo once and caches the loaded module,
-- so requiring this file from multiple places (config/session.lua for the
-- autosave timer, config/keys.lua for the save/restore bindings) returns the
-- same plugin object rather than re-fetching.
local wezterm = require 'wezterm'

return wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
