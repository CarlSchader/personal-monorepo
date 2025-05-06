# hardware nix configs sub-flake

{ 
  nixpkgs, 
  nix-darwin, 
  home-manager, 
  telegram,
  ...
}:
{
  darwinConfigurations."Carls-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
    modules = [ 
      ../modules/darwin.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carlschader = import ../modules/home.nix;
      }
    ];
  };

  # work laptop
  darwinConfigurations."Carls-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
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
      ./ml-pc/configuration.nix
      ./ml-pc/hardware-configuration.nix
      ../modules/nginx-reverse-proxy.nix
      {
        config.nginxHost = "carlschader.com";
        config.nginxHostPath = "/telegram";
        config.nginxProxy = "http://127.0.0.1:8080";
        config.nginxAcmeEmail = "carlschader@proton.me";
      }
      telegram.nixosModules.telegram-server
      telegram.nixosModules.telegram-remind 
      {
        config.services.telegram-remind = {
          enable = true;
          # bot-token = builtins.readFile ../../secrets/telegram-bot/bot-token;
        };
      }
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.carl = import ../modules/home.nix;
        home-manager.users.connor = import ../modules/home.nix;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };

  nixosConfigurations.lambda-carl = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./lambda/configuration.nix
      ./lambda/hardware-configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.saronic = import ../modules/home.nix;
      }
    ];
  };
}
