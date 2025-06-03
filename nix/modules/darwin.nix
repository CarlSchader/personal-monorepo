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
in 
{
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
    [ pkgs.vim ];

    environment.etc.motd.text = motd;
    environment.interactiveShellInit = "cat /etc/motd";
    environment.loginShellInit = "cat /etc/motd";

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";
    

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
    users.users.carlschader = {
        name = "carlschader";
        home = "/Users/carlschader";
    };
}
