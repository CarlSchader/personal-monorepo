{ ... }:
{
  nixosModules.tailscaled =
    { config, ... }:
    {
      networking.firewall.enable = true;
      services.tailscale.enable = true;

      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

      # Ensure tailscaled waits for network to be fully online
      systemd.services.tailscaled = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
}
