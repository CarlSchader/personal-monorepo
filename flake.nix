{
  description = "main flake for all my configs";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    nixpkgs, 
    nix-darwin, 
    home-manager, 
    pyproject-nix,
    ...
  }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312; # python version

    personal-monorepo = python.pkgs.buildPythonPackage (project.renderers.buildPythonPackage { inherit python; } // { 
      # extras
    });
  in
  {
    packages.x86_64-linux.default = personal-monorepo;

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        (python.withPackages (ps: [
          ps.build
          ps.pip
        ]))
      ];
    };
      
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
      specialArgs = { inherit personal-monorepo; };
      modules = [
        ./nix/hardware/ml-pc-configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.carl = import ./nix/modules/home.nix;
          home-manager.users.connor = import ./nix/modules/home.nix;
          home-manager.users.saronic = import ./nix/modules/home.nix;
        }
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
