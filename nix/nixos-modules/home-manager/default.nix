{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./home.nix
  ./rust-overlay-home.nix
  ./saronic-opk.nix
  ./wezterm.nix
]
