{ self, ... }:
{
  nixosModules.telegram-server = { config, lib, pkgs, ... }:
  with lib;
  let
    cfg = config.services.telegram-server;
  in 
  {
    options.services.telegram-server = {
      bot-token = mkOption {
        type = types.string;
        default = "";
        description = "telegram bot token to use, if not set then the contensts of the file at /etc/personal-monorepo/bot-token is used";
      };

      port = mkOption {
        type = types.string;
        default = "8080";
        description = "port to run the server on";
      };
    };

    config = {
      systemd.services."telegram-server" = {
        enable = true; 
        environment.BOT_TOKEN = cfg.bot-token;
        after = [ "network.target" ];
        serviceConfig = {
          ExecStart = "${self.packages."${pkgs.system}".default}/bin/server";
          Restart = "always";
          User = "root";
        };
      };
    };
  };
  nixosModules.telegram-remind = { config, lib, pkgs, ... }:
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
        description = "telegram bot token to use";
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
          Unit = "telegram-remind.service";
        };
      };

      systemd.services."telegram-remind" = {
        enable = true; 
        script = "${self.packages."${pkgs.system}".default}/bin/remind -b \"${cfg.bot-token}\""; # change this to somewhere in /etc in the future
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
}
