# home-manager configuration

{config, pkgs, ...}: 
let
  initExtraAllShells = ''
    export EDITOR="nvim"
    export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic-api-key)
    export OPENAI_API_KEY=$(cat ~/.secrets/openai-api-key)
  '';
  shellAliases = {
    n = "nvim";
    t = "tmux";
    ll = "ls -lhG";
    ls = "ls -G";
    l = "ls -G";
    g = "grep";
    k = "kubectl";

    # git aliases
    gfa = "git fetch --all";
    ga = "git add .";
    gca = "git add . && git commit -am";
    gpo = "git push origin";
    gpob = "git push origin $(git branch | grep \\* | awk '{ print $2 }')";
    gp = "git pull";
    gs = "git switch";
    gclean = "git branch -D $(git branch | grep -v \\* | grep -v main | grep -v master)";

    tarz = "tar --zstd";
    venv = "source .venv/bin/activate";
    necho = "echo -n";

    pwgen-secure = "pwgen -1cns 16";
  };
in {  
  home.packages = with pkgs; [ 
    ## user applications
    brave
    ledger # cli tool for accounting
    yubikey-manager

    ## dev tools
    git
    gnumake
    cmake
    tmux
    neovim
    wezterm
    ripgrep
    kubectl
    jq
    zstd
    unzip
    pigz
    ffmpeg
    nmap
    pnpm
    gnumake
    sops
    age
    pwgen
    watch
    binutils # linker, assembler, etc.
    openssh

    # ai tools
    zed-editor
    claude-code
    
    # bitcoin tools
    bitcoin-carl

    # libraries
    boost
    libfido2 # FIDO2 library for hardware security keys

    # databases
    postgresql
    mysql-shell

    # cloud tools
    flyctl
    awscli2
    google-cloud-sdk

    # # services
    # nginx

    # saronic
    mcap-cli

    ## compilers and runtimes
    nodejs
    bun
    rustc
    cargo
    python312
    lua
    go
    docker_28
    jdk23
    lean4

    ## lsps
    nixd
    rust-analyzer
    pyright
    python312Packages.python-lsp-server
    typescript-language-server
    lua-language-server
    sourcekit-lsp

    # linters
    ruff
    prettierd

    # packaging and project management 
    uv
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = initExtraAllShells + ''
      autoload -U colors && colors
      PS1="%{$fg[green]%}%n%{$reset_color%}@%{$fg[green]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% "
    '';
    shellAliases = shellAliases;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = shellAliases;
    initExtra = initExtraAllShells;
  };

  nix.registry.configs = {
    from = {
      id = "configs";
      type = "indirect";
    };
    to = {
      owner = "CarlSchader";
      repo = "personal-monorepo";
      type = "github";
    };
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
