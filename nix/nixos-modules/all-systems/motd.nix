{ ... }:
let
  carls-macbook-string = ''

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

  carls-ml-pc-string = ''

       ______           ___      
      / ____/___ ______/ ( )_____ 
     / /   / __ `/ ___/ /|// ___/
    / /___/ /_/ / /  / /  (__  )
    \____/\__,_/_/__/_/  /____/
       ____ ___  / /     ____  _____
      / __ `__ \/ /_____/ __ \/ ___/
     / / / / / / /_____/ /_/ / /__
    /_/ /_/ /_/_/     / .___/\___/
                     /_/

  '';

  shellInit = ''
    if [ -z "$MOTD_SHOWN" ]; then
      cat /etc/motd
      export MOTD_SHOWN=1
    fi
  '';

  make-motd-module =
    motd-string:
    { ... }:
    {
      environment.etc.motd.text = motd-string;
      environment.loginShellInit = shellInit;
    };
in
{
  nixosModules.carls-macbook-motd = make-motd-module carls-macbook-string;
  nixosModules.carls-ml-pc-motd = make-motd-module carls-ml-pc-string;
}
