{ pkgs, ... }:
let
  keys = import ../keys.nix;
in 
{
  # Git server
  users.users.git-shared = {
    isSystemUser = true;
    group = "git-shared";
    home = "/var/lib/git-shared-server";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = keys.shared;
  };

  users.groups.git-shared = {};

  services.openssh.extraConfig = ''
    Match user git-shared
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      PermitTTY no
      X11Forwarding no
  '';
}
