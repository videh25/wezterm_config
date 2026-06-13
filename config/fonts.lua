-- Font stack with explicit fallbacks for icons, media glyphs, and emoji.

local wezterm = require 'wezterm'

return function(config)
  config.font = wezterm.font_with_fallback({
    'UbuntuSansMono Nerd Font Mono',   -- primary: text + powerline / nerd icons (no ligatures)
    'Symbola',                         -- media-control glyphs: ⏵ ⏸ ⏺ (Claude Code mode indicators, U+23F4–F7)
    'Noto Color Emoji',                -- color emoji: ✅ ⚠️ 🚀
  })
end
