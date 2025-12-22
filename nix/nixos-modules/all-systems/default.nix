{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./dockerd.nix
  ./experimental-featurs.nix
  ./git-server.nix
  ./git-shared-server.nix
  ./motd.nix
  ./nginx-reverse-proxy.nix
  ./nix-ld.nix
  ./openssh.nix
  ./parallelism.nix
  ./rust-overlay-module.nix
  ./saronic-builders.nix
  ./shell-configs.nix
  ./tailscaled.nix
]
