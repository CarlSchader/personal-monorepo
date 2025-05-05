{
  description = "all the telegram bullshit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pyproject-nix, flake-utils, ... }:
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
      project.renderers.buildPythonPackage { inherit python; }
    );

    apps.default = apps.server;

    apps.server = {
      type = "app";
      program = "${packages.default}/bin/server";
    };
    
    apps.register-webhook = {
      type = "app";
      program = "${packages.default}/bin/register-webhook";
    };

    apps.unregister-webhook = {
      type = "app";
      program = "${packages.default}/bin/unregister-webhook";
    };
  });
}
