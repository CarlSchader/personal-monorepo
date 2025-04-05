local wezterm = require 'wezterm'

local config = wezterm.config_builder()

wezterm.on('toggle-colorscheme', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.color_scheme then
    overrides.color_scheme = 'One Light (base16)'
  else
    overrides.color_scheme = nil
  end
  window:set_config_overrides(overrides)
end)

config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
    -- Switch color scheme
    {key="t", mods="OPT", action = wezterm.action.EmitEvent 'toggle-colorscheme',}
}

return config
