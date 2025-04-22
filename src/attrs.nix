{
  lib,
  lib',
}: let
  inherit (builtins) isString isList;

  inherit (lib.lists) foldl;

  inherit (lib.attrsets) setAttrByPath recursiveUpdate;

  inherit (lib.strings) splitString;

  inherit (lib'.matching) fmatch;
in rec {
  exports = {
    inherit
      fill
      fill'
      enable
      disable
      ;
  };

  /**
  Set the value of each attribute given a list of paths.

  # Arguments

  value
  : The value to set.

  xs
  : A list of paths to set the value for.
  : The paths can be strings or lists of strings.

  # Example

  ```nix
  fill { enable = true; } [ "a" [ "a" "b" ] ]
  => {
    a = {
      b = { enable = true; };
      enable = true;
    };
  }
  ```
  */

  fill = value: xs: let
    normalizePath = p:
      fmatch p [
        [
          isList
          p
        ]
        [
          isString
          [p]
        ]
      ];
    attrsets = map (p: setAttrByPath (normalizePath p) value) xs;
  in
    foldl recursiveUpdate {} attrsets;

  # The same as fill, but splits the paths by '.'
  fill' = value: xs: fill value <| map (x: splitString "." x) xs;

  enable = fill {enable = true;};

  disable = fill {enable = false;};
}
