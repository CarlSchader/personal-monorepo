{
  description = "utils used across the entire repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { 
    nixpkgs, 
    flake-utils, 
    ... 
  }:
  flake-utils.lib.eachDefaultSystem (system: 
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages.encrypt = pkgs.stdenv.mkDerivation {
      name = "encrypt";
      src = ./encrypt.sh;
      dontUnpack = true;
      propagatedBuildInputs = [ pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/encrypt
        chmod +x $out/bin/encrypt
      '';
    };

    packages.decrypt = pkgs.stdenv.mkDerivation {
      name = "decrypt";
      src = ./decrypt.sh;
      dontUnpack = true;
      propagatedBuildInputs = [ pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/decrypt
        chmod +x $out/bin/decrypt
      '';
    };

    packages.network-decrypt = pkgs.stdenv.mkDerivation {
      name = "network-decrypt";
      src = ./network-decrypt.sh;
      dontUnpack = true;
      propagatedBuildInputs = [ pkgs.gzip pkgs.gnutar pkgs.curl pkgs.age pkgs.sops ];
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/network-decrypt
        chmod +x $out/bin/network-decrypt
      '';
    };
  });
}
