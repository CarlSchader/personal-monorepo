# hardware nix configs sub-flake

{ 
  self,
  nixpkgs, 
  nix-darwin, 
  disko,
  home-manager, 
  log-server,
  ...
}:
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [ 
      { nixpkgs = { overlays = [ self.overlays.aarch64-darwin.refresh-auth-sock ]; }; }
      ../modules/darwin.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
      }
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem
    {
    modules = [
      { nixpkgs = { overlays = [ 
          self.overlays.aarch64-darwin.refresh-auth-sock 
          self.overlays.aarch64-darwin.darwin-packages 
      ]; }; }
      ../modules/darwin-saronic.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };

  # work laptop 2
  darwinConfigurations."Carls-MacBook-Air" = nix-darwin.lib.darwinSystem
    {
    modules = [
      { nixpkgs = { overlays = [ 
          self.overlays.aarch64-darwin.refresh-auth-sock 
          self.overlays.aarch64-darwin.darwin-packages 
      ]; }; }
      ../modules/darwin-saronic-air.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."carl.schader" = import ../modules/home.nix;
      }
    ];
  };

  nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs = { overlays = [ self.overlays.x86_64-linux.refresh-auth-sock ]; }; }
      ./ml-pc/configuration.nix
      ./ml-pc/hardware-configuration.nix
      ../modules/git-server.nix
      ../modules/git-shared-server.nix

      disko.nixosModules.disko 
      ./ml-pc/disko-config.nix {
        disko.devices.disk.main.device = "/dev/nvme0n1"; # overridden on install from cli
      }

      # exposes log server at https://carlschader.com/log-server
      # even though log-server is only http
      ../modules/nginx-reverse-proxy.nix {
        config.nginxHost = "carlschader.com";
        config.nginxHostPath = "/log-server";
        config.nginxProxy = "http://0.0.0.0:6000";
        config.nginxAcmeEmail = "carlschader@proton.me";
      }

      # log-server module
      log-server.nixosModules.default {
        config.services.log-server = {
          enable = true;
          port = 6000;
          host = "0.0.0.0";
          jwt-secret = "/etc/log-server/jwt-secret";
        };
      }

      # self.nixosModules.telegram-server {
      #   config.services.telegram-server = { ssh-key-path="/home/carl/.ssh/id_ed25519"; };
      # }
      # self.nixosModules.telegram-remind {
      #   config.services.telegram-remind = {
      #     enable = true;
      #     # bot-token = builtins.readFile ../../secrets/telegram-bot/bot-token;
      #   };
      # }
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
        home-manager.users.connor = import ../modules/home.nix;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ]; 
    # ++ self.lib.recurring-payments-systemd-units;
  };

  nixosConfigurations.lambda-carl = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs = { overlays = [ self.overlays.x86_64-linux.refresh-auth-sock ]; }; }
      ./lambda/configuration.nix
      ./lambda/hardware-configuration.nix
      
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ]; 
  };

  nixosConfigurations.nix-pi = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ./nix-pi.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
      }
    ];
  };
}
