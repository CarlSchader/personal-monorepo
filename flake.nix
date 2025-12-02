{
  description = "main flake for all my configs";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    refresh-auth-sock = {
      url = "github:carlschader/refresh-auth-sock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cococrawl = {
      url = "github:carlschader/cococrawl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    log-server = {
      url = "github:carlschader/log-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # bitcoin-carl = {
    #   url = "github:CarlSchader/bitcoin-with-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { flake-utils, ... }@inputs:
    flake-utils.lib.meld inputs [
      ./nix/hardware
      ./nix/templates
      ./nix/overlays.nix
      ./nix/packages.nix
      ./repo-utils
      ./telegram
    ];
}
