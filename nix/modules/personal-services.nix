{config, pkgs}@inputs:
{
  systemd.timers.remind = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "remind.service";
    };
  };

  systemd.services.remind = {
    enable = true; 
    ExecStart = "${inputs.personal-monorepo}/bin/remind -b=/home/carl/secrets/personal-monorepo-bot-token";
  };
}
