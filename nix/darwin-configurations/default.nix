{
  self,
  nix-darwin,
  ...
}:
let
  system = "aarch64-darwin";
  darwin-module = import ./darwin.nix;
in
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      (self.nixosModules.common-home-manager-darwin [ "carlschader" ])

      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.parallelism
      self.nixosModules.saronic-builders
      
    ];
  };

  darwinConfigurations."Carls-MacBook-Air-2" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carl-user"
      (self.nixosModules.common-home-manager-darwin [ "carl" ])

      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.parallelism
      self.nixosModules.saronic-builders
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carlschader-user"
      (self.nixosModules.common-home-manager-darwin [ "carlschader" ])

      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.saronic-macbook-motd
      self.nixosModules.parallelism
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders
    ];
  };

  # work laptop 2
  darwinConfigurations."Carls-MacBook-Air" = nix-darwin.lib.darwinSystem {
    modules = [
      darwin-module

      self.nixosModules."${system}-carl.schader-user"
      (self.nixosModules.saronic-home-manager-darwin [ "carl.schader" ])

      self.nixosModules.aarch64-darwin-system-packages
      self.nixosModules.carls-macbook-motd
      self.nixosModules.parallelism
      self.nixosModules.saronic-builders
    ];
  };
}
