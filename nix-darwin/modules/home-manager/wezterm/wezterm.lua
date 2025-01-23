local wezterm = require("wezterm")

local config = {}

config.front_end = "WebGpu"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.font_size = 13

config.window_background_opacity = 0.9
config.macos_window_background_blur = 20

config.enable_tab_bar = false

config.window_frame = {
	font = wezterm.font("JetBrains Mono", { weight = "Medium" }),
	font_size = 10,
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.text_background_opacity = 0.75

--config.color_scheme = "Gruber Darker"

config.window_decorations = "RESIZE"

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
