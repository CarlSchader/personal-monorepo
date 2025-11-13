# home-manager configuration

{config, pkgs, ...}: 
let
  initExtraAllShells = ''
    export EDITOR="nvim"
    export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic-api-key)
    export OPENAI_API_KEY=$(cat ~/.secrets/openai-api-key)
    export GPG_TTY=$(tty)
    export SOPS_EDITOR="vim"
    source <(ssh-agent)
    ssh-add
  '';

  initExtraZsh = initExtraAllShells + ''
    eval "$(direnv hook zsh)"
    # nu # activate nushell
  '';

  initExtraBash = initExtraAllShells + ''
    eval "$(direnv hook bash)"
    # nu # activate nushell
  '';

  initExtraNuShell = ''
    $env.EDITOR = "nvim"
    $env.ANTHROPIC_API_KEY = (cat ~/.secrets/anthropic-api-key)
    $env.OPENAI_API_KEY = (cat ~/.secrets/openai-api-key)
  '';

  shellAliases = {
    n = "nvim";
    t = "tmux";
    ll = "ls --color=auto -lhG";
    ls = "ls --color=auto -G";
    l = "ls --color=auto -G";
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

    # r2 = "aws --profile=r2 --endpoint-url https://$(cat ~/.secrets/r2-account-id).r2.cloudflarestorage.com --region wnam s3";
  };

  nuShellAliases = {
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
    gca = "git add . and git commit -am";
    gpo = "git push origin";
    # gpob = "git push origin $(git branch | grep \\* | awk '{ print $2 }')";
    gp = "git pull";
    gs = "git switch";
    # gclean = "git branch -D $(git branch | grep -v \\* | grep -v main | grep -v master)";

    tarz = "tar --zstd";
    venv = "source .venv/bin/activate";
    necho = "echo -n";

    pwgen-secure = "pwgen -1cns 16";

    # r2 = "aws --profile=r2 --endpoint-url https://$(cat ~/.secrets/r2-account-id).r2.cloudflarestorage.com --region wnam s3";
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
    vim
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
    pwgen
    watch
    binutils # linker, assembler, etc.
    nix-index
    lsof
    refresh-auth-sock
    direnv
    ncdu
    gdb
    jwt-cli
    xclip

    # encryption
    sops
    age
    gnupg
    openssh

    # ai tools
    claude-code
    codex
    opencode

    # libraries
    boost
    libfido2 # FIDO2 library for hardware security keys

    # databases
    postgresql

    # cloud tools
    flyctl
    awscli2
    google-cloud-sdk

    # # services
    # nginx

    # saronic
    mcap-cli

    ## compilers and runtimes
    nodejs_24
    deno
    bun
    # rustc
    (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ];})
    # cargo
    # rustup
    python312
    luajitPackages.luarocks-nix
    lua51Packages.lua
    go
    docker_28
    docker-compose
    jdk23

    ## lsps
    nixd
    rust-analyzer
    pyright
    python312Packages.python-lsp-server
    typescript-language-server
    lua-language-server
    sourcekit-lsp
    ccls

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
    enableCompletion = false;

    initContent = initExtraZsh + ''
      autoload -Uz compinit
      compinit -u
      autoload -U colors && colors
      PS1="%{$fg[green]%}%n%{$reset_color%}@%{$fg[green]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% "
    '';
    shellAliases = shellAliases;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = shellAliases;
    initExtra = initExtraBash;
  };

  programs.nushell = {
    enable = false;
    shellAliases = nuShellAliases;
    extraConfig = initExtraNuShell;
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
