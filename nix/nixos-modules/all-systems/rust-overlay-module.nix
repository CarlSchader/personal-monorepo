{ rust-overlay, ... }:
{
  nixosModules.rust-overlay-module =
    { ... }:
    {
      nixpkgs.overlays = [ rust-overlay.overlays.default ];
    };
}
