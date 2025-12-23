{
  self,
  nixpkgs,
  ...
}:
let
  system = "x86_64-linux";
in
{
  nixosConfigurations."carls-system76" = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix

      self.nixosModules.x86_64-linux-system-packages
      self.nixosModules.experimental-features
      self.nixosModules.nix-ld
      self.nixosModules.openssh
      self.nixosModules.parallelism
      self.nixosModules.saronic-builders
      self.nixosModules.tailscaled

      self.nixosModules."${system}-saronic-user"

      (self.nixosModules.saronic-home-manager-nixos [ "saronic" ])
    ];
  };
}
