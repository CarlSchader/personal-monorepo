{ 
  nixpkgs, 
  flake-utils,
  pyproject-nix,
  ... 
}:
flake-utils.lib.eachDefaultSystem (system: 
let
  pkgs = import nixpkgs { inherit system; };
  project = pyproject-nix.lib.project.loadPyproject {
    projectRoot = ./.;
  };

  python = pkgs.python312;
in
rec {
  packages.repo-utils = python.pkgs.buildPythonPackage (
    (project.renderers.buildPythonPackage { inherit python; }) // {
      propagatedBuildInputs = [];
    }
  );

  # packages.commit-file = pkgs.writeShellApplication {
  #   name = "commit-file";
  #   runtimeInputs = [ packages.repo-utils ];
  #   text = "${packages.repo-utils}/bin/commit-file \"$@\"";
  # };

  apps.commit-file = {
    type = "app";
    program = "${packages.commit-file}/bin/commit-file";
  };

  packages.commit-secret-file = pkgs.stdenv.mkDerivation {
    name = "commit-secret-file";
    src = ./commit-secret-file.sh;
    dontUnpack = true;
    nativeBuildInputs = [ packages.repo-utils pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
    propagatedNativeBuildInputs = [ packages.repo-utils pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/commit-secret-file
      chmod +x $out/bin/commit-secret-file
    '';

  };

  packages.encrypt-store = pkgs.stdenv.mkDerivation {
    name = "encrypt-store";
    src = ./encrypt.sh;
    dontUnpack = true;
    propagatedBuildInputs = [ pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/encrypt-store
      chmod +x $out/bin/encrypt-store
    '';
  };

  packages.decrypt-store = pkgs.stdenv.mkDerivation {
    name = "decrypt-store";
    src = ./decrypt.sh;
    dontUnpack = true;
    propagatedBuildInputs = [ pkgs.gzip pkgs.gnutar pkgs.age pkgs.sops ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/decrypt-store
      chmod +x $out/bin/decrypt-store
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

  packages.decrypt = pkgs.writeShellApplication {
    name = "decrypt";
    runtimeInputs = [ packages.decrypt-store ];
    text = "decrypt-store secrets.tar.gz.enc";
  };

  packages.encrypt = pkgs.writeShellApplication {
    name = "encrypt";
    runtimeInputs = [ packages.encrypt-store ];
    text = "encrypt-store secrets";
  };
})
