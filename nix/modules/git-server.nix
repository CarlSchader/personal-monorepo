{ config, pkgs, ... }:
let
  keys = import ../keys.nix;
in 
{
  # Git server
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/var/lib/git-server";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = keys.carl;
  };

  users.groups.git = {};

  services.openssh.extraConfig = ''
    Match user git
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      PermitTTY no
      X11Forwarding no
  '';
}
