{
  description = "A flexible Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:

    utils.lib.eachDefaultSystem (system:
      let
        mkNodejsShell = nodejsVersion:
          let
            overlays = [
              (final: prev: rec {
                nodejs = prev."nodejs_${toString nodejsVersion}";
                pnpm = prev.nodePackages.pnpm;
                yarn = (prev.yarn.override { inherit nodejs; });
              })
            ];

            pkgs = import nixpkgs { inherit overlays system; };
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [ nodejs pnpm yarn ];

            shellHook = with pkgs;''
              echo "Node.js ${toString nodejsVersion} development environment"
              echo "node `${nodejs}/bin/node --version`"
              echo "yarn `${yarn}/bin/yarn --version`"
              echo "pnpm `${pnpm}/bin/pnpm --version`"
            '';
          };

      in
      {
        devShells = {
          default = mkNodejsShell 22;  # Default to Node.js 22 LTS
          "18" = mkNodejsShell 18;
          "20" = mkNodejsShell 20;
          "22" = mkNodejsShell 22;
          "24" = mkNodejsShell 24;
        };

      });
}
