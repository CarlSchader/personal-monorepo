{ flake-utils, refresh-auth-sock, ... }:
flake-utils.lib.eachDefaultSystem (system: 
  {
    # overlays.bitcoin-carl = final: prev: {
    #   bitcoin-carl = bitcoin-carl.packages.${system}.default; 
    # };

    overlays.refresh-auth-sock = final: prev: {
      refresh-auth-sock = refresh-auth-sock.packages.${system}.default; 
    };

    overlays.darwin-packages = final: prev: {
      binutils = prev.darwin.binutils;
    };
  }
)
