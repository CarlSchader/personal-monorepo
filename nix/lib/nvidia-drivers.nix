{ pkgs, ... }:
rec {
  baseNvidia = pkgs.linuxPackages.nvidiaPackages.latest;

  nvidia575_64_05 = baseNvidia.overrideAttrs (old: {
    version = "575.64.05";
    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/575.64.05/NVIDIA-Linux-x86_64-575.64.05.run";
      sha256 = "hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";
    };
  });

  nvidia570_207 = baseNvidia.overrideAttrs (old: {
    version = "570.207";
    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/570.207/NVIDIA-Linux-x86_64-570.207.run";
      sha256 = "sha256-LWvSWZeWYjdItXuPkXBmh/i5uMvh4HeyGmPsLGWJfOI=";
    };
  });

  nvidia580_95_05 = baseNvidia.overrideAttrs (old: {
    version = "580.95.05";
    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/580.95.05/NVIDIA-Linux-x86_64-580.95.05.run";
      sha256 = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
    };
  });
}
