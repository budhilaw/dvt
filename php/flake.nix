{
  description = "A flexible Nix-flake-based PHP development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:

    utils.lib.eachDefaultSystem (system:
      let
        mkPhpShell = phpVersion:
          let
            pkgs = import nixpkgs { inherit system; };
            php = pkgs."php${toString phpVersion}";
            composer = pkgs.phpPackages.composer;
            wp-cli = pkgs.wp-cli;
          in
          pkgs.mkShell {
            buildInputs = [ php composer wp-cli ];
          };

      in
      {
        devShells = {
          default = mkPhpShell 83;  # Default to PHP 8.3
          "81" = mkPhpShell 81;
          "82" = mkPhpShell 82;
          "83" = mkPhpShell 83;
          "84" = mkPhpShell 84;
        };

      });
}
