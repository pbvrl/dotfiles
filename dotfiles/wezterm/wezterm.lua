local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.window_decorations = 'INTEGRATED_BUTTONS | RESIZE'
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

local title_font_size = 11
local edge = '#5c6370'
local bar = os.getenv 'WEZTERM_TITLEBAR' == 'light' and { bg = '#ebebeb', fg = '#2e3436' } or {}
config.window_frame = {
  font = wezterm.font { family = 'JetBrains Mono', weight = 'Bold' },
  font_size = title_font_size,
  border_left_width = '1px', border_right_width = '1px', border_top_height = '1px', border_bottom_height = '1px',
  border_left_color = edge, border_right_color = edge, border_top_color = edge, border_bottom_color = edge,
  active_titlebar_bg = bar.bg, inactive_titlebar_bg = bar.bg, active_titlebar_fg = bar.fg, inactive_titlebar_fg = bar.fg,
}
wezterm.on('update-status', function(window)
  local title = window:active_workspace()
  local dims = window:get_dimensions()
  local cols = dims.pixel_width / (0.6 * title_font_size * dims.dpi / 72)
  window:set_left_status(wezterm.pad_left(title, (cols + #title) // 2))
end)
config.freetype_load_target = 'Light'
config.text_min_contrast_ratio = 4.5
config.font_rules = {
  { intensity = 'Half', italic = false, font = wezterm.font 'JetBrains Mono' },
  { intensity = 'Half', italic = true, font = wezterm.font('JetBrains Mono', { italic = true }) },
}
-- config.window_background_opacity = 0.9
config.colors = {
  background = '#282c34',
  foreground = '#f8f8f2',
  ansi = { '#282c34', '#ff5555', '#50fa7b', '#f1fa8c', '#bd93f9', '#ff79c6', '#8be9fd', '#f8f8f2' },
  brights = { '#545c6e', '#ff6e6e', '#69ff94', '#ffffa5', '#d6acff', '#ff92df', '#a4ffff', '#ffffff' },
  tab_bar = { background = bar.bg },
}

config.keys = {
  { key = 'f', mods = 'ALT', action = act.ActivateCopyMode },
}
if wezterm.gui then
  local function append(list, items)
    return table.move(items, 1, #items, #list + 1, list)
  end
  local start_search = act.Multiple { act.CopyMode 'ClearPattern', act.CopyMode 'EditPattern' }
  config.key_tables = wezterm.gui.default_key_tables()
  append(config.key_tables.copy_mode, {
    { key = 'Enter', action = act.Multiple { act.CopyTo 'ClipboardAndPrimarySelection', act.ScrollToBottom, act.CopyMode 'Close' } },
    { key = 'Escape', action = act.CopyMode 'ClearSelectionMode' },
    { key = 'v', mods = 'ALT', action = act.CopyMode { SetSelectionMode = 'Block' } },
    { key = '/', action = start_search },
    { key = '?', action = start_search },
    { key = '?', mods = 'SHIFT', action = start_search },
    { key = 'n', action = act.CopyMode 'PriorMatch' },
    { key = 'N', action = act.CopyMode 'NextMatch' },
  })
  append(config.key_tables.search_mode, {
    { key = 'Enter', action = act.CopyMode 'AcceptPattern' },
    { key = 'Escape', action = act.Multiple { act.CopyMode 'ClearPattern', act.CopyMode 'AcceptPattern' } },
  })
end

return config
