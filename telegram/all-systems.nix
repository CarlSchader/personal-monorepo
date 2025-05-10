{ nixpkgs, pyproject-nix, flake-utils, repo-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };   
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312;
  in 
  rec {
    packages.default = python.pkgs.buildPythonPackage (
      (project.renderers.buildPythonPackage { inherit python; }) // {
        propagatedBuildInputs = [ repo-utils.packages."${system}".network-decrypt ];
      }
    );

    apps.default = apps.server;

    apps.server = {
      type = "app";
      program = "${packages.default}/bin/server";
    };

    apps.remind = {
      type = "app";
      program = "${packages.default}/bin/remind";
    };
    
    apps.register-webhook = {
      type = "app";
      program = "${packages.default}/bin/register-webhook";
    };

    apps.unregister-webhook = {
      type = "app";
      program = "${packages.default}/bin/unregister-webhook";
    };
  })
