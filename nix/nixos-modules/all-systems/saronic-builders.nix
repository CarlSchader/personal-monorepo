{ pkgs, ... }:
{
  nixosModules.saronic-builders =
    { ... }:
    {
      nix.buildMachines = [
        {
          hostName = "flyingbrick";
          system = "aarch64-linux";
          sshUser = "saronic";

          # protocol = "ssh";
          maxJobs = 16;
          supportedFeatures = [
            "big-parallel"
            "kvm"
          ];
          mandatoryFeatures = [ ];
        }
        {
          hostName = "mondo2";
          system = "x86_64-linux";
          sshUser = "saronic";
          # protocol = "ssh";
          maxJobs = 16;
          supportedFeatures = [
            "big-parallel"
            "kvm"
          ];
          mandatoryFeatures = [ ];
        }
        {
          hostName = "turbo5";
          system = "x86_64-linux";
          sshUser = "saronic";
          # protocol = "ssh";
          maxJobs = 1;
          supportedFeatures = [ "nvidia-L4" ];
          mandatoryFeatures = [ ];
        }
        {
          hostName = "scalar";
          system = "x86_64-linux";
          sshUser = "saronic";
          # protocol = "ssh";
          maxJobs = 16;
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ];
          mandatoryFeatures = [ "nvidia-ada-RTX6000" ];
        }
      ];
      nix.distributedBuilds = true;
      nix.extraOptions = "builders-use-substitutes = true";
    };

    environment.systemPackages = with pkgs; [ opkssh ];
}
