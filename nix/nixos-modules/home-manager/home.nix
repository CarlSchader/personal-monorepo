{ ... }:
{
  nixosModules.home = { pkgs, ... }:
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
      tokei

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
    programs.home-manager.enable = true;

    home.stateVersion = "25.05";
  };
}
