local wezterm = require 'wezterm'
local config = wezterm.config_builder()

--local function get_current_os()
--  if package.config:sub(1, 1) ~= "/" then
--    return os_win
--  else
--    local output = os.exec("uname")
--    if string.find(output, "Darwin") then
--      return os_mac
--    else
--      return os_linux
--    end
--  end
--end

local os_win = "Windows"
local os_mac = "MacOS"
local os_linux = "Linux"
--local cur_os = get_current_os()

-- Resize the window (called by event handlers)
function resize_window(window, pane, cols, rows)
  local overrides = window:get_config_overrides() or {}
  overrides.initial_cols = cols
  overrides.initial_rows = rows
  window:set_config_overrides(overrides)
  window:perform_action(wezterm.action.ResetFontAndWindowSize, pane)
end

--- params: window, pane
local function refresh_config(window, _)
  if cur_os == os_mac then
    local overrides = window:get_config_overrides() or {}
    local macDisplay = wezterm.gui.screens().active.name == "Built-in Retina Display"
    local font_size = macDisplay and 16 or 15
    if window:effective_config().font_size ~= font_size then
      overrides.font_size = font_size
      window:set_config_overrides(overrides)
    end
  end
end

-- Resize window handlers
wezterm.on("resize-small", function(window, pane)
  resize_window(window, pane, 169, 49)
end)

wezterm.on("resize-large", function(window, pane)
  resize_window(window, pane, 201, 49)
end)

wezterm.on("gui-startup", function()
	local screen = wezterm.gui.screens().active
	local width, height = screen.width * 0.8, screen.height * 0.9
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {
		position = { x = (screen.width - width) / 2, y = (screen.height - height) / 2 + screen.height * 0.1 },
	})
	window:gui_window():set_inner_size(width, height)
end)
-- config.color_scheme = 'Monokai Remastered'
-- config.color_scheme = 'Monokai Vivid'
config.color_scheme = 'Monokai Dark (Gogh)'
-- config.color_scheme = 'Monokai Pro (Gogh)'

config.font = wezterm.font_with_fallback {
  "FiraMono Nerd Font Mono",
  "JetBrains Mono",
  "Cascadia Code",
  "Hack",
  "DejaVu Sans Mono",
  "Noto Mono",
  "monospace",
}
config.font_size = 15.0

config.audible_bell = 'Disabled'
config.front_end = "WebGpu"
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 90000
config.adjust_window_size_when_changing_font_size = true
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}
config.initial_rows = 30
config.initial_cols = 120

return config