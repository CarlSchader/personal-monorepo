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
    pyproject-nix,
    ...
  }@inputs:
  (flake-utils.lib.eachDefaultSystem (system: 
  let
    pkgs = nixpkgs.legacyPackages.${system};
    
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312; # python version

    personal-monorepo = python.pkgs.buildPythonPackage (project.renderers.buildPythonPackage { inherit python; } // { 
      # extras
    });
  in
  { # all systems
    devShells = { 
      default = pkgs.mkShell {
        buildInputs = [
          (python.withPackages (ps: [
            ps.build
            ps.pip
          ]))
        ];
      };
    };

    packages = {
      default = personal-monorepo;
      personal-monorepo = personal-monorepo;
    };
    

  })) // { # system specific
    darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./nix/modules/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carlschader = import ./nix/modules/home.nix;
        }
      ];
    };

    # work laptop
    darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ./nix/modules/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carlschader = import ./nix/modules/home.nix;
        }
      ];
    };

    nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        ./nix/hardware/ml-pc-configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carl = import ./nix/modules/home.nix;
          home-manager.users.connor = import ./nix/modules/home.nix;
          home-manager.users.saronic = import ./nix/modules/home.nix;
        }
        ({ config, pkgs, self, ... }: {
          environment.systemPackages = with pkgs; [
            self.packages.${config.nixpkgs.system}.personal-monorepo
          ];
        })
      ];
    };

    nixosConfigurations.lambda-carl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nix/hardware/lambda-configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carl = import ./nix/modules/home.nix;
          home-manager.users.saronic = import ./nix/modules/home.nix;
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
    
  };
}
