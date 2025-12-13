{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./system-packages.nix
  ./users.nix
]
