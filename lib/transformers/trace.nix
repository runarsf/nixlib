{lib}: let
  inherit (builtins) mapAttrs trace;

  inherit (lib.strings) concatStringsSep;
in
  # https://github.com/nix-community/haumea/issues/50
  cursor: mod:
    mapAttrs (
      n: v: trace "eval ${concatStringsSep "." (cursor ++ [n])}" v
    )
    mod
