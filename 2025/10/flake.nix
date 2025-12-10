{
  description = "Advent of Code 2025 day 10 - Racket dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.racket
          ];

          shellHook = ''
            # Project-local “virtual env” for Racket
            export PLTADDONDIR="$PWD/.racket-addon"
            echo "PLTADDONDIR set to: $PLTADDONDIR"
            echo "First time in this shell, run:"
            echo "    raco pkg install --auto minikanren"
          '';
        };
      });
}

