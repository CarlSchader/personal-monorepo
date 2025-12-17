{
  self,
  nixpkgs,
  disko,
  home-manager,
  neovim-config,
  ...
}:
let
  inherit (nixpkgs) lib;
  system = "x86_64-linux";

  home-manager-config = ../../home-manager/home.nix;
  home-manager-rust-overlay-config = ../../home-manager/rust-overlay-home.nix;
  wezterm-config = ../../home-manager/wezterm.nix;

  merged-home-manager-config = lib.mkMerge [
    home-manager-config
    home-manager-rust-overlay-config
    wezterm-config
    neovim-config.nixosModules.home-manager
  ];
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
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders
      self.nixosModules.tailscaled

      disko.nixosModules.disko
      ./disko-config.nix
      {
        disko.devices.disk.main.device = "/dev/nvme0n1"; # overridden on install from cli
      }

      self.nixosModules."${system}-carl-user"
      self.nixosModules."${system}-saronic-user"
      self.nixosModules."${system}-connor-user"

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = merged-home-manager-config;
        home-manager.users.connor = merged-home-manager-config;
        home-manager.users.saronic = merged-home-manager-config;
      }
    ];
  };
}
