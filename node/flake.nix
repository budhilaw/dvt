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
            pkgs = import nixpkgs { inherit system; };
            nodejs = pkgs."nodejs_${toString nodejsVersion}";
            pnpm = pkgs.nodePackages.pnpm;
            yarn = pkgs.yarn.override { inherit nodejs; };
          in
          pkgs.mkShell {
            buildInputs = [ nodejs pnpm yarn ];

            shellHook = ''
              echo "Node.js ${toString nodejsVersion} development environment"
              echo "node $(${nodejs}/bin/node --version)"
              echo "yarn $(${yarn}/bin/yarn --version)"
              echo "pnpm $(${pnpm}/bin/pnpm --version)"
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
