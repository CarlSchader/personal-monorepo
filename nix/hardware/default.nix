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
      ../modules/darwin.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
      }
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
      ../modules/darwin.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
      }
    ];
  };

  nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit personal-monorepo-package; };
    modules = [
      ./ml-pc/configuration.nix
      ./ml-pc/hardware-configuration.nix
      ../modules/personal-services.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
        home-manager.users.connor = import ../modules/home.nix;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };
}
