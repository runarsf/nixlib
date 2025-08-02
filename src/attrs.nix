{
  lib,
  lib',
}: let
  inherit (builtins) isString isList head tail isAttrs concatStringsSep;

  inherit (lib.lists) foldl foldl';

  inherit (lib.attrsets) setAttrByPath recursiveUpdate attrNames;

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
  Be wary that if the path does not exist, it will not be set, and nix will not complain.

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

  /**
  Checks if the given attribute path exists in the attribute set.
  */
  hasAttrPath = path: attrs:
    if path == []
    then true
    else let
      head' = head path;
      tail' = tail path;
    in
      if !(isAttrs attrs)
      then false
      else if attrs ? ${head'}
      then
        if tail' == []
        then true
        else hasAttrPath tail' attrs.${head'}
      else false;

  # Flattens the attribute set into a single level attribute set (a.b.c -> "a.b.c").
  flattenAttrs = attrs: let
    go = path: attrs:
      foldl' (
        acc: name: let
          value = attrs.${name};
          fullPath = path ++ [name];
        in
          if isAttrs value
          then acc // (go fullPath value)
          else acc // {"${concatStringsSep "." fullPath}" = value;}
      ) {} (attrNames attrs);
  in
    go [] attrs;
}
