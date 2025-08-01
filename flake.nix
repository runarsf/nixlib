{
  description = "Library functions for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    namaka = {
      url = "github:nix-community/namaka/v0.2.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        haumea.follows = "haumea";
      };
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    promoteExports = import ./src/transformers/promoteExports.nix {};
  in
    {
      lib = nixpkgs.lib.makeExtensible (
        _:
          inputs.haumea.lib.load {
            src = ./src;
            transformer = promoteExports "exports";
            inputs = {
              inherit (nixpkgs) lib;
              lib' = self.lib;
            };
          }
      );
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in {
        packages = {
          nixdoc = pkgs.writeShellScriptBin "nixdoc-generate" ''
            export IFS=$'\n'
            set -o noglob

            rm -f docs.md

            while read -r f; do
              ${pkgs.lib.getExe pkgs.nixdoc} --file "$f" --category "" --description "" >> docs.md
            done <<< "$(find . -name '*.nix')"
          '';
        };

        formatter = treefmtEval.config.build.wrapper;

        checks =
          {
            formatting = treefmtEval.config.build.check self;
          }
          // inputs.namaka.lib.load {
            src = ./tests;
            inputs = {
              inherit (pkgs) lib;
              lib' = self.lib;
            };
          };

        devShells.default = pkgs.mkShell {
          packages = [
            inputs.namaka.packages.${system}.default
          ];

          shellHook = ''
            comment="$(tput setaf 8)"
            reset="$(tput sgr0)"

            printf '\n> Namaka version: %s\n\n' "$(namaka --version | awk '{print $2}')"
            printf 'To run tests, use:\n'
            printf '$ namaka check   %s# run checks%s\n' "$comment" "$reset"
            printf '$ namaka review  %s# review pending snapshots%s\n\n' "$comment" "$reset"
          '';
        };
      }
    );
}
