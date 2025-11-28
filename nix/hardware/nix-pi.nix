{
  config,
  pkgs,
  lib,
  ...
}:
let
  user = "carl";
  password = "RedGreenBlue@1";
  SSID = "carlito";
  SSIDpassword = "RedGreenBlue@1";
  interface = "wlan0";
  hostname = "nix-pi";
  keys = ../keys.nix;
  motd-string = ''

                         _                                  _ 
                        | |                                (_)
     _ __ __ _ ___ _ __ | |__   ___ _ __ _ __ _   _   _ __  _ 
    | '__/ _` / __| '_ \| '_ \ / _ \ '__| '__| | | | | '_ \| |
    | | | (_| \__ \ |_) | |_) |  __/ |  | |  | |_| | | |_) | |
    |_|  \__,_|___/ .__/|_.__/ \___|_|  |_|   \__, | | .__/|_|
                  | |                          __/ | | |      
                  |_|                         |___/  |_|      
  '';
in
{
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  environment.etc.motd.text = motd-string;
  environment.interactiveShellInit = "cat /etc/motd";

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ interface ];
    };
  };

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh.enable = true;

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        vim
        neovim
        git
        curl
      ];
      openssh.authorizedKeys.keys = keys.carl;
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
