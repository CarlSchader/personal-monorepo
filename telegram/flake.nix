{
  description = "all the telegram bullshit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pyproject-nix, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };   
    project = pyproject-nix.lib.project.loadPyproject {
      projectRoot = ./.;
    };

    python = pkgs.python312;
  in 
  rec {
    packages.default = python.pkgs.buildPythonPackage (
      project.renderers.buildPythonPackage { inherit python; }
    );

    apps.default = apps.server;

    apps.server = {
      type = "app";
      program = "${packages.default}/bin/server";
    };

    apps.remind = {
      type = "app";
      program = "${packages.default}/bin/remind";
    };
    
    apps.register-webhook = {
      type = "app";
      program = "${packages.default}/bin/register-webhook";
    };

    apps.unregister-webhook = {
      type = "app";
      program = "${packages.default}/bin/unregister-webhook";
    };

    nixosModule.remind = { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.services.telegram-remind;
    in 
    {
      options.services.telegram-remind = {
        enable = mkEnableOption "enable the telegram-remind.timer service";

        bot-token = mkOption {
          type = types.string;
          default = "";
          description = "telegram bot token to use. REQUIRED";
        };

        OnCalendar = mkOption {
          description = "systemd timer calendar rules for when the service activates";
          default = [
            "*-*-* 08:00:00"
            "*-*-* 14:00:00"
            "*-*-* 20:00:00"
          ];
        };

        OnBootSec = mkOption {
          description = "systemd timer OnBootSec rule for how long after booting to activate the service";
          default = "1m";
        };
      };

      config = mkIf cfg.enable {
        systemd.timers."telegram-remind" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = cfg.OnBootSec;
            OnCalendar = cfg.OnCalendar;
            Persistent = true;
            Unit = "telegram-remind.timer";
          };
        };

        systemd.services."telegram-remind" = {
          enable = true; 
          script = "${packages.default}/bin/remind -b ${cfg.bot-token}"; # change this to somewhere in /etc in the future
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
        };
      };
    };
     
  });
}
