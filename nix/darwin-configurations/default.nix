{
  self,
  nix-darwin,
  home-manager,
  ...
}:
let
  system = "aarch64-darwin";
  darwin-module = import ./darwin.nix;
  home-module = import ../nixos-modules/all-systems/home.nix;
in
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = home-module;
      }
    ];
  };

  darwinConfigurations."Carls-MacBook-Air-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carl-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = home-module;
      }
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      self.nixosModules."${system}-saronic-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = home-module;
        home-manager.users.saronic = home-module;
      }
    ];
  };

  # work laptop 2
  darwinConfigurations."Carls-MacBook-Air" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carl.schader-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."carl.schader" = home-module;
      }
    ];
  };
}
