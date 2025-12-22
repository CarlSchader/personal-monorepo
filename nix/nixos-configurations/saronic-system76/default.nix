{
  self,
  nixpkgs,
  home-manager,
  neovim-config,
  ...
}:
let
  inherit (nixpkgs) lib;
  system = "x86_64-linux";

  common-home-manager-modules = [
    self.nixosModules.home
    self.nixosModules.rust-overlay-home
    self.nixosModules.shell-configs-home
    self.nixosModules.wezterm-home
    neovim-config.nixosModules.home-manager
  ];

  saronic-home-manager-modules = [
    self.nixosModules.saronic-opk-home
    self.nixosModules.saronic-awscli-home
  ];

  saronic-home-config = lib.mkMerge (common-home-manager-modules ++ saronic-home-manager-modules);
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
      self.nixosModules.rust-overlay-module
      self.nixosModules.saronic-builders
      self.nixosModules.tailscaled

      self.nixosModules."${system}-saronic-user"

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.saronic = saronic-home-config;
      }
    ];
  };
}
