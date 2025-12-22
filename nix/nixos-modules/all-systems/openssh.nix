{ ... }:
{
  nixosModules.openssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
          X11Forwarding = true;
          AllowAgentForwarding = true;
          PasswordAuthentication = false; # force use SSH keys instead
        };
      };
    };
}
