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
          "18" = pkgs.nodejs_18;
          "20" = pkgs.nodejs_20;
          "21" = pkgs.nodejs_21;
        };
        
        getNodejs = version: nodejsVersions.${toString version} or pkgs.nodejs;

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ (getNodejs 20) ];
        };
      });
}