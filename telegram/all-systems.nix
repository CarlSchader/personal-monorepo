{ self, nixpkgs, pyproject-nix, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };   
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312;
  in 
  rec {
    packages.telegram = python.pkgs.buildPythonPackage (
      (project.renderers.buildPythonPackage { inherit python; }) // {
        propagatedBuildInputs = [ 
          pkgs.ledger
          self.packages."${system}".network-decrypt 
          self.packages."${system}".commit-secret-file
        ];
      }
    );

    apps.telegram-server = {
      type = "app";
      program = "${packages.telegram}/bin/server";
    };

    apps.remind = {
      type = "app";
      program = "${packages.telegram}/bin/remind";
    };
    
    apps.register-webhook = {
      type = "app";
      program = "${packages.telegram}/bin/register-webhook";
    };

    apps.unregister-webhook = {
      type = "app";
      program = "${packages.telegram}/bin/unregister-webhook";
    };

    devShells.telegram = pkgs.mkShell {
      buildInputs = [ 
        python
        self.packages."${system}".network-decrypt 
        self.packages."${system}".commit-secret-file
      ];
    };
  })
