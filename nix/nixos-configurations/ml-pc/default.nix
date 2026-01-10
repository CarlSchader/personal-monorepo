{
  self,
  nixpkgs,
  disko,
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
      self.nixosModules.nix-ld
      self.nixosModules.openssh
      self.nixosModules.parallelism
      self.nixosModules.xrdp-gnome

      disko.nixosModules.disko
      ./disko-config.nix
      {
        disko.devices.disk.main.device = "/dev/nvme0n1"; # overridden on install from cli
      }

      self.nixosModules."${system}-carl-user"
      self.nixosModules."${system}-connor-user"

      (self.nixosModules.common-home-manager-nixos [ "carl" "connor" ])
    ];
  };
}
