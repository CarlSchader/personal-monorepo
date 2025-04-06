{config, pkgs, personal-monorepo, ...}:
{
  config = {
    systemd.timers."remind-timer" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "remind-timer.service";
      };
    };

    systemd.services."remind-timer" = {
      enable = true; 
      script = "${personal-monorepo}/bin/remind -b=/home/carl/secrets/personal-monorepo-bot-token";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
