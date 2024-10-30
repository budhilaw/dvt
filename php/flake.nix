{
  description = "A Nix-flake-based Go development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, utils, devenv, ... }:

    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.${system}.devenv-up = self.devShells.${system}.default.config.procfileScript;
        packages.${system}.devenv-test = self.devShells.${system}.default.config.test;

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({ pkgs, config, ... }: {
              # This is your devenv configuration
              packages = [ pkgs.hello ];

              enterShell = ''
                hello
              '';

              processes.run.exec = "hello";
            })
          ];
        };
      });
}