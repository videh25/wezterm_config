-- Mouse bindings.

local wezterm = require 'wezterm'
local act = wezterm.action

return function(config)
  -- Terminator copies on selection; WezTerm can do the same.
  config.mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
    },
  }
end
