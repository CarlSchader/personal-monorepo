{ ... }:
{
  nixosModules.tailscaled =
    { config, pkgs, ... }:
    {
      networking.firewall.enable = true;
      services.tailscale.enable = true;

      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

      environment.systemPackages = [ pkgs.tailscale ];
    };
}
