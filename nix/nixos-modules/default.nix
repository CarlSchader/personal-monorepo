{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./aarch64-darwin
  ./all-systems
  ./x86_64-linux
]
