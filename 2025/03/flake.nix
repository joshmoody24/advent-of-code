{
  description = "Dev environment for AoC day 3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; 
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; dyalog.acceptLicense = true; }; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.dyalog
        ];
      };
    };
}

