-- Single source of truth for this config's custom commands.
--
-- Each command is defined ONCE here (key + mods + action + palette label),
-- and both consumers derive from it:
--   * config/keys.lua            appends {key, mods, action} to config.keys
--   * events/command_palette.lua builds palette entries, auto-formatting the
--                                key/mods into the label via format_key()
--
-- So a rebind only needs editing here — the keymap and the palette stay in
-- sync automatically. (The palette shows the shortcut inside the label text
-- rather than its native right-hand column, because WezTerm only key-matches
-- its own built-in commands for that column; augmented entries don't get it.)
--
-- require() caches modules, so every requirer shares the identical action
-- objects below.

local wezterm = require 'wezterm'
local act = wezterm.action
local resurrect = require 'plugins.resurrect'   -- session save/restore

local M = {}

-- ── Action bodies ────────────────────────────────────────────────────────────

-- Reset terminal (RIS — Reset to Initial State; keeps scrollback).
local reset_terminal = act.SendString '\x1bc'

-- Rename the active tab via a prompt.
local rename_tab = act.PromptInputLine {
  description = 'Rename tab:',
  action = wezterm.action_callback(function(window, _, line)
    if line then window:active_tab():set_title(line) end
  end),
}

-- Save the CURRENT WINDOW (its tabs/panes) as a named snapshot. Other open
-- WezTerm windows are not included. Type a name to keep multiple sessions
-- side by side; leave blank to save under the window title; Esc to cancel.
local save_session = act.PromptInputLine {
  description = 'Save window as (blank = window title):',
  action = wezterm.action_callback(function(win, pane, line)
    if line == nil then return end   -- Esc cancels
    local state = resurrect.window_state.get_window_state(pane:window())
    local name = (line ~= '' and line) or state.title
    if name == nil or name == '' then
      name = wezterm.mux.get_active_workspace()
    end
    resurrect.state_manager.save_state(state, name)
    win:toast_notification('WezTerm', 'Window saved: ' .. name, nil, 2000)
  end),
}

-- Fuzzy-pick a saved session and restore it (Esc to cancel).
local restore_session = wezterm.action_callback(function(win, pane)
  resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
    local type = string.match(id, '^([^/]+)')   -- workspace | window | tab
    id = string.match(id, '([^/]+)$')            -- strip directory
    id = string.match(id, '(.+)%..+$')           -- strip .json extension
    local opts = {
      relative = true,
      restore_text = true,
      on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    }
    local state = resurrect.state_manager.load_state(id, type)
    if type == 'workspace' then
      resurrect.workspace_state.restore_workspace(state, opts)
    elseif type == 'window' then
      resurrect.window_state.restore_window(pane:window(), state, opts)
    elseif type == 'tab' then
      resurrect.tab_state.restore_tab(pane:tab(), state, opts)
    end
  end)
end)

-- Fuzzy-pick a saved session and DELETE it (Esc cancels).
local delete_session = wezterm.action_callback(function(win, pane)
  resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
    resurrect.state_manager.delete_state(id)
  end, {
    title = 'Delete Session',
    description = 'Select a session to DELETE — Enter = delete, Esc = cancel, / = filter',
    fuzzy_description = 'Search session to delete: ',
    is_fuzzy = true,
  })
end)

-- ── Command specs (the single source of truth) ───────────────────────────────
-- Fields: key, mods, action, brief, icon (icon optional).
M.commands = {
  {
    key = 'r', mods = 'CTRL|SHIFT',
    action = reset_terminal,
    brief = 'Reset terminal (RIS, keep scrollback)',
    icon = 'md_restart',
  },
  {
    key = 'F2', mods = 'NONE',
    action = rename_tab,
    brief = 'Rename tab',
    icon = 'md_rename_box',
  },
  {
    key = 's', mods = 'CTRL|SHIFT',
    action = save_session,
    brief = 'Session: save current window',
    icon = 'md_content_save',
  },
  {
    key = 'b', mods = 'CTRL|SHIFT',
    action = restore_session,
    brief = 'Session: restore (fuzzy pick)',
    icon = 'md_history',
  },
  {
    key = 'd', mods = 'CTRL|SHIFT',
    action = delete_session,
    brief = 'Session: delete (fuzzy pick)',
    icon = 'md_delete',
  },
}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local MOD_LABELS = { CTRL = 'Ctrl', SHIFT = 'Shift', ALT = 'Alt', SUPER = 'Super' }

-- Format a (mods, key) pair into a human label, e.g. ('CTRL|SHIFT', 'r') →
-- 'Ctrl+Shift+R'. Single-character keys are upper-cased; named keys (F2,
-- Space, …) are kept verbatim.
function M.format_key(mods, key)
  local parts = {}
  if mods and mods ~= 'NONE' and mods ~= '' then
    for token in string.gmatch(mods, '[^|]+') do
      table.insert(parts, MOD_LABELS[token] or token)
    end
  end
  table.insert(parts, #key == 1 and string.upper(key) or key)
  return table.concat(parts, '+')
end

return M
