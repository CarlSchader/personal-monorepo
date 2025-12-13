{ ... }:
{
  nixosModules.dockerd = { ... }: {
    virtualisation.docker.enable = true;
  };
}
