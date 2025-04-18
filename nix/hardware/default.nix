# hardware nix configs sub-flake

{ 
  nixpkgs, 
  nix-darwin, 
  home-manager, 
  ...
}@inputs:
let
  remind-package = (import ../packages.nix inputs).packages.x86_64-linux.remind;
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
    specialArgs = { inherit remind-package; };
    modules = [
      ./ml-pc/configuration.nix
      ./ml-pc/hardware-configuration.nix
      ../modules/remind-timer.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
        home-manager.users.connor = import ../modules/home.nix;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };

  nixosConfigurations.lambda-carl = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./lambda/configuration.nix
      ./lambda/hardware-configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };
}
