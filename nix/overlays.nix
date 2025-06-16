{ bitcoin-carl, flake-utils, ... }:
flake-utils.lib.eachDefaultSystem (system: 
  {
    overlays.bitcoin-carl = final: prev: {
      bitcoin-carl = bitcoin-carl.packages.${system}.default; 
    };
  }
)
