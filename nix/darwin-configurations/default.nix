{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  neovim-config,
  ...
}:
let
  inherit (nixpkgs) lib;

  system = "aarch64-darwin";
  darwin-module = import ./darwin.nix;

  common-home-manager-modules = [
    self.nixosModules.home
    self.nixosModules.rust-overlay-home
    self.nixosModules.wezterm-home
    neovim-config.nixosModules.home-manager
  ];

  saronic-home-manager-modules = [
    self.nixosModules.saronic-opk-home
  ];

  common-home-config = lib.mkMerge common-home-manager-modules;
  saronic-home-config = lib.mkMerge (common-home-manager-modules ++ saronic-home-manager-modules);
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
        home-manager.users.carlschader = common-home-config;
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
        home-manager.users.carl = common-home-config;
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
        home-manager.users.carlschader = common-home-config;
        home-manager.users.saronic = saronic-home-config;
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
        home-manager.users."carl.schader" = saronic-home-config;
      }
    ];
  };
}
