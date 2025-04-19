{ self, nixpkgs, flake-utils, ...}:
flake-utils.lib.eachDefaultSystem (system: 
let
  overlays = [ self.overlays.default ];
  pkgs = import nixpkgs { inherit system overlays; };
in 
{
  devShells.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      (python312.withPackages (ps: [ ps.build ps.pip ]))
      age
      sops
    ] ++ (builtins.attrValues pkgs.repo-packages);
  };
})
