{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./bluetooth.nix
  ./dockerd.nix
  ./experimental-featurs.nix
  ./git-server.nix
  ./git-shared-server.nix
  ./gnome.nix
  ./motd.nix
  ./nginx-reverse-proxy.nix
  ./nix-ld.nix
  ./openssh.nix
  ./parallelism.nix
  ./rust-overlay-module.nix
  ./saronic-builders.nix
  ./tailscaled.nix
]
