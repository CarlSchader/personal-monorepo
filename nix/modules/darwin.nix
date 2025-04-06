# nix-darwin configuration

{ pkgs, ... }: {
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
    [ pkgs.vim ];

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

    users.motd = 
    ''
                                ____                    __         
       /'\_/`\                 /\  _`\                 /\ \        
      /\      \     __      ___\ \ \L\ \    ___     ___\ \ \/'\    
      \ \ \__\ \  /'__`\   /'___\ \  _ <'  / __`\  / __`\ \ , <    
       \ \ \_/\ \/\ \L\.\_/\ \__/\ \ \L\ \/\ \L\ \/\ \L\ \ \ \\`\  
        \ \_\\ \_\ \__/.\_\ \____\\ \____/\ \____/\ \____/\ \_\ \_\
         \/_/ \/_/\/__/\/_/\/____/ \/___/  \/___/  \/___/  \/_/\/_/
                                                                   
                                                                   
    '';

    # User configuration
    users.users.carlschader = {
        name = "carlschader";
        home = "/Users/carlschader";
    };
}
