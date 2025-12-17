{ ... }:
{
  nixosModules.home = { pkgs, ... }:
  let
    initExtraAllShells = ''
      export EDITOR="nvim"
      export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic-api-key)
      export OPENAI_API_KEY=$(cat ~/.secrets/openai-api-key)
      export GEMINI_API_KEY=$(cat ~/.secrets/gemini-api-key)
      export GPG_TTY=$(tty)
      export SOPS_EDITOR="vim"
    '';

    initExtraZsh = initExtraAllShells + ''
      source <(ssh-agent)
      ssh-add
      ssh-add ~/.ssh/id_ed25519_sk_rk
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
      gpob = "git push origin $(git branch | grep \\* | awk '{ print $2 }')";
      gp = "git pull";
      gs = "git switch";

      tarz = "tar --zstd";
      venv = "source .venv/bin/activate";
      necho = "echo -n";

      pwgen-secure = "pwgen -1cns 16";
    };
  in
  {
    home.packages = with pkgs; [
      ## user applications
      ledger # cli tool for accounting
      yubikey-manager

      ## dev tools
      git
      gnumake
      cmake
      tmux
      vim
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
      nix-index
      lsof
      direnv
      ncdu
      netcat
      nload
      gdb
      jwt-cli
      xclip
      mdbook
      gh

      # encryption
      sops
      age
      gnupg
      openssh
      opkssh

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

      # saronic
      mcap-cli

      ## compilers and runtimes
      nodejs_24
      deno
      bun
      python312
      luajitPackages.luarocks-nix
      lua51Packages.lua
      go

      # linters
      ruff
      prettierd
      nixfmt-tree

      # packaging and project management
      uv
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;

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

    programs.home-manager.enable = true;

    home.stateVersion = "25.05";
  };
}
