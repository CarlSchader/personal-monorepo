{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  ...
}:
let
  inherit (nixpkgs) lib;

  system = "aarch64-darwin";
  darwin-module = import ./darwin.nix;

  home-manager-config = import ../home-manager/home.nix;
  home-manager-rust-overlay-config = import ../home-manager/rust-overlay-home.nix;

  merged-home-manager-config = lib.mkMerge [
    home-manager-config
    home-manager-rust-overlay-config
  ];
in
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = merged-home-manager-config;
      }
    ];
  };

  darwinConfigurations."Carls-MacBook-Air-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carl-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = merged-home-manager-config;
      }
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
      {

      }
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      self.nixosModules."${system}-saronic-user"
      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = merged-home-manager-config;
        home-manager.users.saronic = merged-home-manager-config;
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
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."carl.schader" = merged-home-manager-config;
      }
    ];
  };
}
