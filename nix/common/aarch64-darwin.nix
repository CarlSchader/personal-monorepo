{
  nixpkgs,
  nixpkgs-2505,
  refresh-auth-sock,
  cococrawl,
  ...
}:
let
  system = "aarch64-darwin";

  pkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
  pkgs-2505 = import nixpkgs-2505 { inherit system; };
in
{
  common.${system} = {
    user-packages = [
      refresh-auth-sock.packages.${system}.default
      cococrawl.packages.${system}.default
      pkgs-2505.tailscale
      pkgs.darwin.binutils
      pkgs.obsidian
      pkgs.brave
    ];

    system-packages = with pkgs; [
      vim
      git
    ];
  };
}
