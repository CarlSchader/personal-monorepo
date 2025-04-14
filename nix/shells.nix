{ nixpkgs, flake-utils, ...}:
flake-utils.lib.eachDefaultSystem (system: 
let
  pkgs = nixpkgs.legacyPackages.${system};
in 
{
  devShells.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      (python312.withPackages (ps: [ ps.build ps.pip ]))
      age
      sops
    ];
  };
})
