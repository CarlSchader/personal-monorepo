{ bitcoin-carl, flake-utils, ... }:
flake-utils.lib.eachDefaultSystem (system: 
  {
    overlays.bitcoin-carl = final: prev: {
      bitcoin-carl = bitcoin-carl.packages.${system}.default; 
    };

    overlays.darwin-packages = final: prev: {
      binutils = prev.darwin.binutils;
    };
  }
)
