{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./saronic-awscli.nix
  ./home.nix
  ./rust-overlay-home.nix
  ./saronic-opk.nix
  ./wezterm.nix
]
