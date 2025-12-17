{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./aarch64-darwin
  ./all-systems
  ./home-manager
  ./x86_64-linux
]
