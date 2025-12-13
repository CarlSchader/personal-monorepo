{ self, ... }:
{
  nixosModules.aarch64-darwin-system-packages =
    { ... }:
    {
      environment.systemPackages = self.common.aarch64-darwin.system-packages;
    };
}
