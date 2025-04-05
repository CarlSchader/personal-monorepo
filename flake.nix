{
  description = "main flake for all my configs";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    nix-darwin, 
    home-manager, 
    flake-utils, 
    pyproject-nix 
  }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312; # python version
    in 
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Carls-MacBook-Pro-2
    darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./nix/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carlschader = import ./nix/home.nix;
          # home-manager.sharedModules = [
          #   nixvim.homeManagerModules.nixvim
          # ];
        }
      ];
    };

    # work laptop
    darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./nix/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carlschader = import ./nix/home.nix;
          # home-manager.sharedModules = [
          #   nixvim.homeManagerModules.nixvim
          # ];
        }
      ];
    };

    nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./x86/ml-pc-configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carl = import ./nix/home.nix;
          home-manager.users.connor = import ./nix/home.nix;
          home-manager.users.saronic = import ./nix/home.nix;
          # home-manager.sharedModules = [
          #   nixvim.homeManagerModules.nixvim
          # ];
        }
      ];
    };

    nixosConfigurations.lambda-carl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nix/x86/lambda-configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carl = import ./nix/home.nix;
          home-manager.users.saronic = import ./nix/home.nix;
          # home-manager.sharedModules = [
          #   nixvim.homeManagerModules.nixvim
          # ];
        }
      ];
    };

    templates = {
      venv = {
        path = ./nix/templates/python;
        description = "Python virutal environment project template";
        welcomeText = ''
          # Nix and python
          - $ nix develop
          - you're in a python virtual environment
          - use pip like normal
        '';
      };

      ml = {
        path = ./nix/templates/python-cuda;
        description = "Cuda python environment project template";
        welcomeText = ''
          # Nix and python
          - $ nix develop
          - you're in a python cuda virtual environment
          - use pip like normal
        '';
      };
    };

    
    devShell = pkgs.mkShell {
        buildInputs = [
          (python.withPackages (ps: [
            ps.build
            ps.pip
          ]))
        ];
      };

    packages.remind = 
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
