{ remind-package, ... }:
{
  config = {
    systemd.timers."remind-timer" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnCalendar = [
          "*-*-* 08:00:00"
          "*-*-* 14:00:00"
          "*-*-* 20:00:00"
        ];
        Persistent = true;
        Unit = "remind-timer.service";
      };
    };

    systemd.services."remind-timer" = {
      enable = true; 
      script = "${remind-package}/bin/remind -b=/etc/personal-monorepo/bot-token"; # change this to somewhere in /etc in the future
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
