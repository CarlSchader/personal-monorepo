{ pkgs, ... }:
pkgs.dockerTools.buildImage {
  name = "telegram webhook-server";
  config = {
    Cmd = [ "${pkgs.repo-packages.telegram-webhook-server}/bin/telegram-webhook-server" ];
  };
}
