-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.color_scheme = 'Monokai Remastered'
-- config.color_scheme = 'Monokai Vivid'
config.color_scheme = 'Monokai Dark (Gogh)'
-- config.color_scheme = 'Monokai Pro (Gogh)'

config.font = wezterm.font 'FiraMono Nerd Font Mono'

return config