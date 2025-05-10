# packages sub-flake

{ 
  flake-utils, 
  nixpkgs,
  utils, 
  ... 
}:
flake-utils.lib.eachDefaultSystem (system: 
let
  pkgs = import nixpkgs { inherit system; };
in 
rec {
  packages.decrypt = pkgs.writeShellApplication {
    name = "decrypt";
    runtimeInputs = [ utils.packages."${system}".decrypt ];
    text = "decrypt secrets.tar.gz.enc";
  };

  packages.encrypt = pkgs.writeShellApplication {
    name = "encrypt";
    runtimeInputs = [ utils.packages."${system}".encrypt ];
    text = "encrypt secrets";
  };

  apps.decrypt = { type = "app"; program = "${packages.decrypt}/bin/decrypt"; }; 

  apps.encrypt = { type = "app"; program = "${packages.encrypt}/bin/encrypt"; };
})
