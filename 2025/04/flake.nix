{
  description = "Advent of Code R + RStudio (nixy)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # RStudio that *internally* uses R with these packages
        rstudioEnv = pkgs.rstudioWrapper.override {
          packages = with pkgs.rPackages; [
            tidyverse       # dplyr, readr, tidyr, ggplot2, purrr, stringr, etc
            data_table
            languageserver
            devtools
            here
            janitor
            glue
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rstudioEnv
            pkgs.git
          ];

          shellHook = ''
            echo "AoC nixy RStudio env"
            echo "  rstudio binary: $(which rstudio)"
          '';
        };

        apps.rstudio = {
          type = "app";
          program = "${rstudioEnv}/bin/rstudio";
        };
      }
    );
}

