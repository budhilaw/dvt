{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:

    utils.lib.eachDefaultSystem (system:
      let
        nodejsVersion = 22;
        overlays = [
          (final: prev: rec {
            nodejs = prev."nodejs-${toString nodejsVersion}_x";
          })
        ];

        pkgs = import nixpkgs { inherit overlays system; };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs ];
        };

      });
}