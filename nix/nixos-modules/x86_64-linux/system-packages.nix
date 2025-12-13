{ self, ... }:
{
  nixosModules.x86_64-linux-system-packages =
    { ... }:
    {
      environment.systemPackages = self.common.x86_64-linux.system-packages;
    };
}
