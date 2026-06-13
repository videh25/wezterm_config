-- General terminal behaviour: graphics, notifications, scrollback.

return function(config)
  -- ─── Inline image support (the reason you're here) ─────────────────────────
  config.enable_kitty_graphics = true

  -- Show desktop notifications when a task completes.
  config.notification_handling = 'AlwaysShow'

  -- How often update-status fires (ms); also paces the focus tracker.
  config.status_update_interval = 200

  -- ─── Scrollback ────────────────────────────────────────────────────────────
  -- Terminator defaults to 500 lines; bump this to something more useful.
  config.scrollback_lines = 10000
end
