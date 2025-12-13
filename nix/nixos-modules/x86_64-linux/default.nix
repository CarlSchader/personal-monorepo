{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./users.nix
]
