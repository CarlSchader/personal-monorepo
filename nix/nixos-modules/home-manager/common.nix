# These are top level nixos modules. Not just homa-manager user modules.
{ self, nixpkgs, home-manager, neovim-config, ... }:
let
  inherit (nixpkgs) lib;

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

  common-home-modules = lib.mkMerge common-home-manager-modules;
  saronic-home-modules = lib.mkMerge saronic-home-manager-modules;
in
{
  nixosModules.common-home-manager-nixos = { config, pkgs, ... }: 
  {
    imports = [ 
      self.nixosModules.rust-overlay-module 
      (home-manager.nixosModules.home-manager)
    ];

    config = {
      home-manager.users = lib.mapAttrs (name: user: common-home-modules) (
        lib.filterAttrs (name: user: 
          if pkgs.stdenv.isDarwin 
          then (user.home or "") != "" && lib.hasPrefix "/Users/" (user.home or "")
          else user.isNormalUser or false
        ) config.users.users
      );
    };
  };

  nixosModules.saronic-home-manager-nixos = { config, pkgs, ... }: {
    imports = [ 
      self.nixosModules.rust-overlay-module 
      (home-manager.nixosModules.home-manager)
    ];

    config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = lib.mapAttrs (name: user: saronic-home-modules) (
        lib.filterAttrs (name: user: 
          if pkgs.stdenv.isDarwin 
          then (user.home or "") != "" && lib.hasPrefix "/Users/" (user.home or "")
          else user.isNormalUser or false
        ) config.users.users
      );
    };
  };

  nixosModules.common-home-manager-darwin = { config, pkgs, ... }: 
  {
    imports = [ 
      self.nixosModules.rust-overlay-module 
      (home-manager.darwinModules.home-manager)
    ];

    config = {
      home-manager.users = lib.mapAttrs (name: user: common-home-modules) (
        lib.filterAttrs (name: user: 
          if pkgs.stdenv.isDarwin 
          then (user.home or "") != "" && lib.hasPrefix "/Users/" (user.home or "")
          else user.isNormalUser or false
        ) config.users.users
      );
    };
  };

  nixosModules.saronic-home-manager-darwin = { config, pkgs, ... }: {
    imports = [ 
      self.nixosModules.rust-overlay-module 
      (home-manager.darwinModules.home-manager)
    ];

    config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = lib.mapAttrs (name: user: saronic-home-modules) (
        lib.filterAttrs (name: user: 
          if pkgs.stdenv.isDarwin 
          then (user.home or "") != "" && lib.hasPrefix "/Users/" (user.home or "")
          else user.isNormalUser or false
        ) config.users.users
      );
    };
  };
}
