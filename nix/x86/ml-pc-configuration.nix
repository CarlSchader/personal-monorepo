# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  defaultShell = pkgs.bash;
  defaultUserPackages = with pkgs; [
    gcc
    git
    code-cursor
  ];
  authorizedKeys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEfes+9mHAnHSb0GjyP305zzFtS2P12e3Ha/Vur+62He carlschader@Carls-MacBook-Pro.local" # personal
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnEa9ffHtw4evQmVDKaoVDMLGan0k4Olrs1h+jPvhpc carlschader@Carls-MacBook-Pro.local" # work 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE8N1WCZEQv43tuIvndSbtSPa3uYxFUfGh6LN0BFbnyt connorjones@MacBookPro" # connor
  ];
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./ml-pc-hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "ml-pc"; # Define your hostname.

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedTCPPortRanges = [ 
      { from = 8000; to = 9000; }
      { from = 3000; to = 4000; }
    ];
    allowedUDPPortRanges = [
      { from = 8000; to = 9000; }
      { from = 3000; to = 4000; }
    ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Indiana/Vincennes";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  environment.pathsToLink = [ "/libexec" ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
      # xfce = {
      #   enable = true;
      #   noDesktop = true;
      #   enableXfwm = false;
      # };
    };

    displayManager.defaultSession = "none+i3";

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
    };

    videoDrivers = ["nvidia"]; # was causing black screen
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # enable docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.carl = {
    isNormalUser = true;
    description = "Carl Schader";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = defaultUserPackages;
    shell = defaultShell;
    openssh.authorizedKeys.keys = authorizedKeys; 
  };

  users.users.connor = {
    isNormalUser = true;
    description = "Connor Jones";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = defaultUserPackages;
    shell = defaultShell;
    openssh.authorizedKeys.keys = authorizedKeys; 
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.saronic = {
    isNormalUser = true;
    description = "carlschader-saronic";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = defaultUserPackages;
    shell = defaultShell;
    openssh.authorizedKeys.keys = authorizedKeys; 
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    linuxPackages.v4l2loopback
    v4l-utils
    # nodejs_23 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.ssh.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.X11Forwarding = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # nvidia stuff
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # end nvidia

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
