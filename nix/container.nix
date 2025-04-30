{ pkgs, ... }:
pkgs.dockerTools.buildImage {
  name = "telegram-webhook-server";
  config = {
    Cmd = [ "${pkgs.repo-packages.remind}/bin/remind" ];
  };
}
