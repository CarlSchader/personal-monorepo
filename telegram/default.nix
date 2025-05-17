{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./all-systems.nix
  ./services.nix
  ./lib.nix
]
