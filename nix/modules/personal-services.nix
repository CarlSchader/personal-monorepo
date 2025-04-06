{config, pkgs, ...}@inputs:
{
  config = {
    systemd.timers."remind" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "remind.service";
      };
    };

    systemd.services."remind" = {
      enable = true; 
      script = "${inputs.personal-monorepo}/bin/remind -b=/home/carl/secrets/personal-monorepo-bot-token";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
