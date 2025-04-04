{
  description = "Library functions for Nix.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    ...
  }:
    flakeUtils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      concatPaths = (import ./lib/paths.nix {inherit (pkgs) lib;}).concatPaths;
    in {
      lib = with pkgs.lib;
        zipAttrsWith (
          name: value:
            builtins.elemAt value 0
        ) (
          builtins.map (
            path:
              import path ({
                  lib' = self.lib.${system};
                }
                // pkgs)
          ) (concatPaths {
            path = ./lib;
            recursive = false;
          })
        );
    });
}
