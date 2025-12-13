{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./x86_64-linux.nix
  ./aarch64-darwin.nix
]
