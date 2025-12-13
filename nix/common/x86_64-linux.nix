{
  self,
  nixpkgs,
  nixpkgs-2505,
  opkssh,
  refresh-auth-sock,
  cococrawl,
  ...
}:
let
  system = "x86_64-linux";

  pkgs = import nixpkgs { inherit system; };
  pkgs-2505 = import nixpkgs-2505 { inherit system; };
  opkssh-pkg = opkssh.packages.${system}.opkssh;
in
{
  common.${system}.user-packages = [
    self.packages.${system}.sops-export
    refresh-auth-sock.packages.${system}.default
    cococrawl.packages.${system}.default
    pkgs-2505.tailscale
    opkssh-pkg
    pkgs.binutils
  ];

  common.${system}.system-packages = with pkgs; [
    vim
    git
    dmidecode
    linuxPackages.v4l2loopback
    v4l-utils
  ];
}
