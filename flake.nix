{
  description = "Library functions for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    promoteExports = import ./lib/transformers/promoteExports.nix {};
  in
    {
      lib = nixpkgs.lib.makeExtensible (
        _:
          inputs.haumea.lib.load {
            src = ./lib;
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
          overlays = [
            (_: _: {
              alejandra = inputs.alejandra.packages.${system}.default;
            })
          ];
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

        checks.formatting = treefmtEval.config.build.check self;
      }
    );
}
