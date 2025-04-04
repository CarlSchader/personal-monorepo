{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    devShells = flake-utils.lib.eachDefaultSystem (system: {
      default = nixpkgs.${system}.mkShell {
        buildInputs = with nixpkgs.${system}; [
            python312.withPackages (ps: [
                # nothing yet
            ])
        ];
      };
    });
  };
}