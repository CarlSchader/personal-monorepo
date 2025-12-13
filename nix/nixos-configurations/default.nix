{ flake-utils, ... }@inputs:
flake-utils.lib.meld inputs [
  ./ml-pc
]
