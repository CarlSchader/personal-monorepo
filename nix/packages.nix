# packages sub-flake

{ nixpkgs, flake-utils, pyproject-nix, ... }:
flake-utils.lib.eachDefaultSystem (system: 
let
  pkgs = nixpkgs.legacyPackages.${system};

  decrypt-derivation = pkgs.stdenv.mkDerivation {
    name = "decrypt-script";
    src = ../scripts/decrypt-secrets.sh;
    dontUnpack = true;
    buildInputs = [ pkgs.age pkgs.sops ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/decrypt-script
      chmod +x $out/bin/decrypt-script
    '';
  };

  encrypt-derivation = pkgs.stdenv.mkDerivation {
    name = "encrypt-script";
    src = ../scripts/encrypt-secrets.sh;
    dontUnpack = true;
    buildInputs = [ pkgs.age pkgs.sops ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/encrypt-script
      chmod +x $out/bin/encrypt-script
    '';
  };

  remind-project = pyproject-nix.lib.project.loadPyproject {
    projectRoot = ../.;
  };

  python = pkgs.python312; # python version
in
{
  packages.remind = python.pkgs.buildPythonPackage (
    remind-project.renderers.buildPythonPackage { inherit python; } // { 
    # extras
  });

  packages.decrypt = pkgs.writeShellApplication {
    name = "decrypt-store";
    runtimeInputs = [ decrypt-derivation pkgs.age pkgs.sops ];
    text = "decrypt-script secrets.tar.gz.enc";
  };

  packages.encrypt = pkgs.writeShellApplication {
    name = "encrypt-store";
    runtimeInputs = [ encrypt-derivation pkgs.age pkgs.sops ];
    text = "encrypt-script secrets";
  };
})
