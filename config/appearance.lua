-- Tab bar and window appearance.

return function(config)
  -- ─── Tab bar ───────────────────────────────────────────────────────────────
  -- Keep the tab bar; it replaces Terminator's tab strip.
  -- Set to false if you only ever use a single tab.
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false   -- classic compact bar, closer to Terminator
end
