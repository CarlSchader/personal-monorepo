# hardware nix configs sub-flake

{ 
  self,
  nixpkgs, 
  nix-darwin, 
  disko,
  home-manager, 
  ...
}:
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [ 
      { nixpkgs = { overlays = [ self.overlays.aarch64-darwin.bitcoin-carl ]; }; }
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
          self.overlays.aarch64-darwin.bitcoin-carl 
          self.overlays.aarch64-darwin.darwin-packages 
      ]; }; }
      ../modules/darwin.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
      }
    ];
  };

  nixosConfigurations.ml-pc = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs = { overlays = [ self.overlays.x86_64-linux.bitcoin-carl ]; }; }
      ./ml-pc/configuration.nix
      ./ml-pc/hardware-configuration.nix
      ../modules/git-server.nix
      ../modules/git-shared-server.nix

      disko.nixosModules.disko 
      ./ml-pc/disko-config.nix {
        disko.devices.disk.main.device = "/dev/nvme0n1"; # overridden on install from cli
      }

      # ../modules/nginx-reverse-proxy.nix {
      #   config.nginxHost = "carlschader.com";
      #   config.nginxHostPath = "/telegram";
      #   config.nginxProxy = "http://127.0.0.1:8080";
      #   config.nginxAcmeEmail = "carlschader@proton.me";
      # }
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

  nixosConfigurations.nix-pi = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      { nixpkgs = { overlays = [ self.overlays.aarch64-linux.bitcoin-carl ]; }; }
      ./nix-pi.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
      }
    ];
  };
}
