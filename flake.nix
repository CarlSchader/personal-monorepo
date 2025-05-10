{
  description = "main flake for all my configs";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    repo-utils = {
      url = "path:./repo-utils";
      inputs.flake-utils.follows = "flake-utils";
    };
    telegram = {
      url = "path:./telegram";
      inputs.repo-utils.follows = "repo-utils";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { flake-utils, ... }@inputs:
  flake-utils.lib.meld inputs [
    ./nix/hardware
    ./nix/templates
    ./nix/packages.nix
  ];
}
