-- Window
config.window_decorations = "RESIZE"
config.enable_wayland = false
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.80
config.text_background_opacity = 1.0
config.max_fps = 144
config.animation_fps = 60

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"

-- Tab bar
config.enable_tab_bar = false

-- Scrollback
config.scrollback_lines = 10000

-- Bell
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 150,
  target = "CursorColor",
}

return config
