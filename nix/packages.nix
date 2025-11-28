{ nixpkgs, flake-utils, ... }:
flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages.sops-export = pkgs.stdenv.mkDerivation {
      pname = "sops-export";
      version = "0.1.0";
      src = ../scripts;
      installPhase = ''
        mkdir -p $out/bin
        cp sops-export $out/bin/sops-export
        chmod +x $out/bin/sops-export
      '';
    };
  }
)
