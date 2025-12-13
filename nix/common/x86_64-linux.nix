{
  nixpkgs,
  nixpkgs-2505,
  refresh-auth-sock,
  cococrawl,
  ...
}:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs { inherit system; };
  pkgs-2505 = import nixpkgs-2505 { inherit system; };
in
{
  common.${system} = {
    user-packages = [
      refresh-auth-sock.packages.${system}.default
      cococrawl.packages.${system}.default
      pkgs-2505.tailscale
      pkgs.binutils
    ];

    system-packages = with pkgs; [
      vim
      neovim
      git
      dmidecode
      linuxPackages.v4l2loopback
      v4l-utils
    ];
  };
}
