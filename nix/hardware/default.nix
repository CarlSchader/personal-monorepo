# hardware nix configs sub-flake

{ 
  nixpkgs, 
  nix-darwin, 
  home-manager, 
  ...
}@inputs:
let
  personal-monorepo-package = (import ../packages.nix inputs).personal-monorepo-package;
in 
{
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
    specialArgs = { inherit personal-monorepo-package; };
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
}
