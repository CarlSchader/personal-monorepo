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
      programs.zsh.enable = true;
      users.users.carl = {
        isNormalUser = true;
        description = "Carl Schader";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        hashedPassword = "$6$oUx4cxq3vxiY2Czo$RdM1s7eLdnNgFV9F4UAOCFiZrkiIyW6MuIcXveRqYFmK5GrzVmvwwfkGhMNPgKk3wwu.Ybhh.//JJBPIEj/2K0";
        packages = self.common.${system}.user-packages;
        openssh.authorizedKeys.keys = keys.carl;
      };
    };

  nixosModules."${system}-saronic-user" =
    { pkgs, ... }:
    {
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;
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
      programs.zsh.enable = true;
      users.users.connor = {
        isNormalUser = true;
        description = "Connor Jones";
        extraGroups = [ ];
        packages = self.common.${system}.user-packages;
        openssh.authorizedKeys.keys = keys.connor ++ keys.carl;
      };
    };
}
