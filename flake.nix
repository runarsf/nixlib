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
    with flakeUtils.lib;
      eachSystem allSystems (system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        concatPaths = (import ./lib/paths.nix {inherit (pkgs) lib;}).concatPaths;

        lib = pkgs.lib.makeExtensible (self: let
          libFiles = concatPaths {
            path = ./lib;
            recursive = false;
          };

          importedFiles =
            builtins.map (
              path:
                import path {
                  lib' = self.lib.${system};
                  inherit (pkgs) lib;
                }
            )
            libFiles;
        in
          pkgs.lib.mergeAttrsList importedFiles);
      in {
        inherit lib;
      });
}
