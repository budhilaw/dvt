{
  description = "A Nix-flake-based Go development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:

    utils.lib.eachDefaultSystem (system:
      let
        nodejsVersion = 18;
        overlays = [ (final: prev: {
            nodejs = prev."nodejs-${toString nodejsVersion}_x";
            pnpm = prev.nodePackages.pnpm;
            yarn = (prev.yarn.override { inherit nodejs; });
          })
        ];
        pkgs = import nixpkgs { inherit overlays system; };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            pnpm
            yarn
          ];
        };
      });
}