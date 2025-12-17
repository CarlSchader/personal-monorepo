{ ... }:
{
  nixosModules.wezterm = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wezterm
    ];

    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local config = wezterm.config_builder()

        local dark_color_scheme = 'deep'
        local light_color_scheme = 'dayfox'

        wezterm.on('toggle-colorscheme', function(window, pane)
          local overrides = window:get_config_overrides() or {}
          if not overrides.color_scheme or overrides.color_scheme == dark_color_scheme then
            overrides.color_scheme = light_color_scheme
          else
            overrides.color_scheme = dark_color_scheme
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
      '';
    };
  };
}
