{
  description = "Library functions for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    alejandra,
    flake-utils,
    treefmt-nix,
    ...
  }: let
    inherit
      (import ./lib/paths.nix {
        inherit (nixpkgs) lib;
        # Partial implementation of lib', as concatPaths is used to build lib'.
        lib' = {
          toList = x:
            if builtins.isList x
            then x
            else [x];
        };
      })
      concatPaths
      ;

    lib = nixpkgs.lib.makeExtensible (
      self: let
        libFiles = concatPaths {
          path = ./lib;
          recursive = false;
        };

        importedFiles =
          builtins.map (
            path:
              import path {
                inherit (nixpkgs) lib;
                lib' = lib;
              }
          )
          libFiles;
      in
        nixpkgs.lib.mergeAttrsList importedFiles
    );
  in
    {
      inherit lib;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              alejandra = alejandra.packages.${system}.default;
            })
          ];
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
