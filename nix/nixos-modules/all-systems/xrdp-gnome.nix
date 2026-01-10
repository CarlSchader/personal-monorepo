{ ... }:
{
  nixosModules.xrdp-gnome = { pkgs, ... }:
  {
    services.xrdp.enable = true;

    # Use the GNOME Wayland session
    services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";

    # XRDP needs the GNOME remote desktop backend to function
    services.gnome.gnome-remote-desktop.enable = true;

    # Open the default RDP port (3389)
    services.xrdp.openFirewall = true;

    # Disable autologin to avoid session conflicts
    services.displayManager.autoLogin.enable = false;
    services.getty.autologinUser = null;
  };
}


