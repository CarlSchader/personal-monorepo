{ self, flake-utils, ... }:
flake-utils.eachDefaultSystem  (system:
{
  nixosModules."${system}-system-packages" =
    { ... }:
    {
      environment.systemPackages = self.common.${system}.system-packages;
    };
})
