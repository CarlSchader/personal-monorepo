{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ...}: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = (with pkgs; [
          python312
        ]);

        shellHook = ''
          export PATH="$PWD/scripts:$PATH"
          
          # check for .venv dir and create if it doesn't exist
          if [ ! -d ".venv" ]; then
            python -m venv .venv
            source .venv/bin/activate
            pip install -r requirements.txt
            echo "Created virtual environment in .venv"
          else
            source .venv/bin/activate
          fi
        '';
      };
    }
  );
}
