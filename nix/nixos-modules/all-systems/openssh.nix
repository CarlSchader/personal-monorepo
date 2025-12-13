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
        };
        passwordAuthentication = false; # force use SSH keys instead
      };
    };
}
