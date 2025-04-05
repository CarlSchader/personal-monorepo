{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Allow unfree packages like cuda
        };
      in
      {
        devShell = pkgs.mkShell rec {
          buildInputs = with pkgs; [
            python312
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          shellHook = ''
            echo "activating shell"
            
            python -m venv ./.venv
            source ./.venv/bin/activate

            # Python with packages
            touch ./requirements.txt

            echo Done!
          '';
        };
      }
    );
}
