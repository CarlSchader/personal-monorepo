{
  self,
  nixpkgs,
  disko,
  home-manager,
  ...
}:
let
  system = "x86_64-linux";
in
{
  nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix

      self.nixosModules.x86_64-linux-system-packages
      self.nixosModules.experimental-features
      self.nixosModules.git-server
      self.nixosModules.git-shared-server
      self.nixosModules.carls-ml-pc-motd
      self.nixosModules.saronic-builders
      self.nixosModules.tailscaled

      disko.nixosModules.disko
      ./disko-config.nix
      {
        disko.devices.disk.main.device = "/dev/nvme0n1"; # overridden on install from cli
      }

      self.nixosModules."${system}-carl-user"
      self.nixosModules."${system}-saronc-user"
      self.nixosModules."${system}-connor-user"

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = self.nixosModules.home;
        home-manager.users.connor = self.nixosModules.home;
        home-manager.users.saronic = self.nixosModules.home;
      }
    ];
  };
}
