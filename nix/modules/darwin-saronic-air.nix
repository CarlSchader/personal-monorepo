# nix-darwin configuration

{ pkgs, ... }:
let
  motd = ''

     ____                     ___    __
    /\  _`\                  /\_ \  /\ \
    \ \ \/\_\     __     _ __\//\ \ \ \/      ____
     \ \ \/_/_  /'__`\  /\`'__\\ \ \ \/      /',__\
      \ \ \L\ \/\ \L\.\_\ \ \/  \_\ \_      /\__, `\
       \ \____/\ \__/.\_\\ \_\  /\____\     \/\____/
        \/___/  \/__/\/_/ \/_/  \/____/      \/___/


                              ____                    __
     /'\_/`\                 /\  _`\                 /\ \
    /\      \     __      ___\ \ \L\ \    ___     ___\ \ \/'\
    \ \ \__\ \  /'__`\   /'___\ \  _ <'  / __`\  / __`\ \ , <
     \ \ \_/\ \/\ \L\.\_/\ \__/\ \ \L\ \/\ \L\ \/\ \L\ \ \ \\`\
      \ \_\\ \_\ \__/.\_\ \____\\ \____/\ \____/\ \____/\ \_\ \_\
       \/_/ \/_/\/__/\/_/\/____/ \/___/  \/___/  \/___/  \/_/\/_/


  '';

  shellInit = ''
    cat /etc/motd
  '';
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];

  environment.etc.motd.text = motd;
  environment.loginShellInit = shellInit;
  environment.interactiveShellInit = shellInit;

  nix.enable = false;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # remote builder setup
  nix.buildMachines = [
    {
      hostName = "flyingbrick";
      system = "aarch64-linux";
      sshUser = "saronic";

      # protocol = "ssh";
      maxJobs = 16;
      supportedFeatures = [
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "mondo2";
      system = "x86_64-linux";
      sshUser = "saronic";
      # protocol = "ssh";
      maxJobs = 16;
      supportedFeatures = [
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "turbo5";
      system = "x86_64-linux";
      sshUser = "saronic";
      # protocol = "ssh";
      maxJobs = 1;
      supportedFeatures = [ "nvidia-L4" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "scalar";
      system = "x86_64-linux";
      sshUser = "saronic";
      # protocol = "ssh";
      maxJobs = 16;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "nvidia-ada-RTX6000"
      ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = "builders-use-substitutes = true";
  # end remote builder setup

  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # User configuration
  users.users."carl.schader" = {
    name = "carl.schader";
    home = "/Users/carl.schader";
    uid = 501;
    packages = [ pkgs.tailscale];
  };
}
