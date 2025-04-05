{
  description = "Library functions for Nix.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flakeUtils.url = "github:numtide/flake-utils";
    treefmtNix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flakeUtils,
      treefmtNix,
      ...
    }:
    with flakeUtils.lib;
    eachSystem allSystems (
      system:
      let
        inherit (import ./lib/paths.nix { inherit (pkgs) lib; }) concatPaths;

        pkgs = import nixpkgs {
          inherit system;
        };

        treefmtEval = treefmtNix.lib.evalModule pkgs ./treefmt.nix;

        lib = pkgs.lib.makeExtensible (
          self:
          let
            libFiles = concatPaths {
              path = ./lib;
              recursive = false;
            };

            importedFiles = builtins.map (
              path:
              import path {
                lib' = self.lib.${system};
                inherit (pkgs) lib;
              }
            ) libFiles;
          in
          pkgs.lib.mergeAttrsList importedFiles
        );
      in
      {
        inherit lib;

        packages.nixdoc = pkgs.writeShellScriptBin "nixdoc-generate" ''
          export IFS=$'\n'
          set -o noglob

          rm -f docs.md

          while read -r f; do
            ${nixpkgs.lib.getExe pkgs.nixdoc} --file "$f" --category "" --description "" >> docs.md
          done <<< "$(find . -name '*.nix')"
        '';

        checks.formatting = treefmtEval.config.build.check self;

        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
