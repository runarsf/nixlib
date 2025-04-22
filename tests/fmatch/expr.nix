{lib'}: let
  inherit (builtins) isList isString;

  inherit (lib'.matching) fmatch;
in
  fmatch "hello" [
    [isList "list"]
    [isString "string"]
  ]
