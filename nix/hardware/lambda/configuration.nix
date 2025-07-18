# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:
let
  defaultShell = pkgs.bash;

  defaultUserPackages = with pkgs; [
    gcc
    git
    vim
  ];

  keys = import ../../keys.nix;

  motd-string = ''
    ___          _ _      _               _        _      
  / __|__ _ _ _| ( )___ | |   __ _ _ __ | |__  __| |__ _ 
 | (__/ _` | '_| |/(_-< | |__/ _` | '  \| '_ \/ _` / _` |
  \___\__,_|_| |_| /__/ |____\__,_|_|_|_|_.__/\__,_\__,_|
                                                           
        '';
in 
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "saronic" "@wheel" ];
  };

  # remote builder setup
  nix.buildMachines = [
    {
      hostName = "flyingbrick";
      system = "aarch64-linux";
      sshUser = "saronic";
      
      # protocol = "ssh";
      maxJobs = 16;
      supportedFeatures = [ "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "mondo2";
      system = "x86_64-linux";
      sshUser = "saronic";
      # protocol = "ssh";
      maxJobs = 16;
      supportedFeatures = [ "big-parallel" "kvm" "nvidia-L4" ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = "builders-use-substitutes = true";
  # end remote builder setup

  networking.hostName = "lambda-carl"; # Define your hostname.

  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];

    allowedTCPPorts = [ 22 80 443 ];
    allowedTCPPortRanges = [ 
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

  environment.etc.motd.text = motd-string;
  environment.interactiveShellInit = "cat /etc/motd";

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.saronic = {
    isNormalUser = true;
    description = "saronic";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = defaultUserPackages;
    shell = defaultShell;
    openssh.authorizedKeys.keys = keys.saronic; 
  };

  # allows third party dynamically linked libs 
  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    linuxPackages.v4l2loopback
    v4l-utils
    tailscale
    # nodejs_23 
  ];

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.X11Forwarding = true;
    passwordAuthentication = true;
  };

  # tailscale
  services.tailscale.enable = true;

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
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  # end nvidia

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
