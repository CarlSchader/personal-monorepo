{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pyproject-nix }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      
      project = pyproject-nix.lib.project.loadPyproject {
        projectRoot = ./.;
      };

      python = pkgs.python312; # python version
    in {
      devShell = pkgs.mkShell {
        buildInputs = [
          (python.withPackages (ps: [
            ps.build
            ps.pip
          ]))
        ];
      };

      packages.default = 
      let
        # returns attr set that can passed to buildPythonPackage
        attrs = project.renderers.buildPythonPackage { inherit python; }; 
      in
      python.pkgs.buildPythonPackage (attrs // {
        # extra attributes added here
        # env = { BOT_TOKEN = "replace-me"; };
      });
    });

}
