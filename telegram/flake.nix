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

    repo-utils = {
      url = "path:../repo-utils";
    };
  };

  outputs = { flake-utils, ... }@inputs:
  flake-utils.lib.meld inputs [
    ./all-systems.nix
    ./services.nix
  ];
}
