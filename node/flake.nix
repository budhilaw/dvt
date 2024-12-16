{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [];
        pkgs = import nixpkgs { inherit overlays system; };
        
        nodejsVersions = {
          "18" = pkgs.nodejs-18_x;
          "20" = pkgs.nodejs-20_x;
          "21" = pkgs.nodejs-21_x;
        };
        
        getNodejs = version: nodejsVersions.${toString version} or pkgs.nodejs;

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ (getNodejs 20) ];
        };
      });
}