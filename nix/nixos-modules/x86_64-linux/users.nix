{
  self,
  ...
}:
let
  keys = import ../../lib/keys.nix;
  system = "x86_64-linux";
in
{
  nixosModules."${system}-carl-user" =
    { pkgs, ... }:
    {
      users.defaultUserShell = pkgs.zsh;
      users.users.carl = {
        isNormalUser = true;
        description = "Carl Schader";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = self.common.${system}.user-packages;
        openssh.authorizedKeys.keys = keys.carl;
      };
    };

  nixosModules."${system}-saronic-user" =
    { pkgs, ... }:
    {
      users.defaultUserShell = pkgs.zsh;
      users.users.saronic = {
        isNormalUser = true;
        description = "saronic";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = self.common.${system}.user-packages;
        openssh.authorizedKeys.keys = keys.saronic;
      };
    };

  nixosModules."${system}-connor-user" =
    { pkgs, ... }:
    {
      users.defaultUserShell = pkgs.zsh;
      users.users.connor = {
        isNormalUser = true;
        description = "Connor Jones";
        extraGroups = [ ];
        packages = self.common.${system}.user-packages;
        openssh.authorizedKeys.keys = keys.connor ++ keys.carl;
      };
    };
}
