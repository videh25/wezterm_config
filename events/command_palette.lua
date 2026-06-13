-- Add this config's custom commands to the command palette (Ctrl+Shift+K).
--
-- WezTerm's palette only lists its own built-in commands, so anonymous Lua
-- actions (session save/restore/delete, reset, tab rename) never show up on
-- their own. The augment-command-palette event injects them.
--
-- Both the entries here and the keymap in config/keys.lua are generated from
-- the SAME spec list in config/custom_commands.lua, so there's a single
-- source of truth — rebinding a key there updates the keymap and this label
-- together. The shortcut is appended to the label text because WezTerm only
-- fills its native right-hand shortcut column for built-in commands.
--
-- Usage from wezterm.lua:
--     require 'events.command_palette'

local wezterm = require 'wezterm'
local custom = require 'config.custom_commands'

wezterm.on('augment-command-palette', function(_window, _pane)
  local entries = {}
  for _, c in ipairs(custom.commands) do
    table.insert(entries, {
      brief = c.brief .. '  ·  ' .. custom.format_key(c.mods, c.key),
      icon = c.icon,
      action = c.action,
    })
  end
  return entries
end)

return {}
