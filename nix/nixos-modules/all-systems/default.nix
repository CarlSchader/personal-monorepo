{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./experimental-featurs.nix
  ./git-server.nix
  ./git-shared-server.nix
  ./motd.nix
  ./nginx-reverse-proxy.nix
  ./rust-overlay-module.nix
  ./saronic-builders.nix
  ./tailscaled.nix
]
