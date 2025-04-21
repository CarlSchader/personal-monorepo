{ pkgs,... }:
{
  config = {
    # This service runs on port 88
    systemd.services."telegram-webhook-server" = {
      enable = true;
      script = "${pkgs.repo-packages.telegram-webhook-server}/bin/telegram-webhook-server";
      serviceConfig = {
        Type = "simple";
        User = "root";
      };
    };
  };
}
