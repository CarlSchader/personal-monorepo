{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Allow unfree packages like cuda
          config.cudaSupport = true;
          config.cudaVersion = "12";
        };
      in
      {
        devShell = pkgs.mkShell rec {
          buildInputs = with pkgs; [
            python312
            cudatoolkit
            linuxPackages.nvidia_x11
            cudaPackages.cudnn
            libGLU libGL
            xorg.libXi xorg.libXmu freeglut
            xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
            ncurses5 stdenv.cc binutils
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.cudatoolkit pkgs.cudaPackages.cudnn pkgs.stdenv.cc.cc.lib pkgs.linuxPackages.nvidia_x11 ];
          NIXPKGS_ALLOW_UNFREE = "1";

          shellHook = ''
            echo "activating shell"

            echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

            python -m venv ./.venv
            source ./.venv/bin/activate

            # Python with packages
            touch ./requirements.txt

            echo Done!
          '';
        };
      }
    );
}
