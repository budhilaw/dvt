{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      system = "aarch64-darwin";

      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.devenv-up = self.devShells.${system}.default.config.procfileScript;
      packages.${system}.devenv-test = self.devShells.${system}.default.config.test;

      devShells.${system}.default = devenv.lib.mkShell {
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
    };
}