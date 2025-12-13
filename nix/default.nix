{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./common
  ./darwin-configurations
  ./nixos-configurations
  ./nixos-modules
]
