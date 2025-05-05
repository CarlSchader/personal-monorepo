# packages sub-flake

{ 
  nixpkgs, 
  flake-utils, 
  # telegram, 
  ... 
}:
flake-utils.lib.eachDefaultSystem (system: 
let
  pkgs = import nixpkgs { inherit system; };

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
in
{
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

  # packages.telegram = telegram.outputs.packages."${system}".default;
})
