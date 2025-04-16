{
  lib,
  lib',
  ...
}: let
  inherit (builtins) isString isList;

  inherit (lib) foldl setAttrByPath recursiveUpdate;

  inherit (lib') fmatch;
in rec {
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

  enable = fill {enable = true;};

  disable = fill {enable = false;};
}
