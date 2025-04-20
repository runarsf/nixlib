{lib}: let
  inherit
    (builtins)
    zipAttrsWith
    tail
    head
    all
    isAttrs
    isList
    ;

  inherit (lib) concatLists unique last;
in rec {
  exports = {
    inherit deepMerge;
  };

  # Merges a list of attributes into one, including lists and nested attributes.
  # Use this instead of lib.mkMerge if the merge type isn't allowed somewhere.
  # https://stackoverflow.com/a/54505212
  deepMerge = attrs: let
    merge = path:
      zipAttrsWith (
        n: values:
          if tail values == []
          then head values
          else if all isList values
          then unique (concatLists values)
          else if all isAttrs values
          then merge (path ++ [n]) values
          else last values
      );
  in
    merge [] attrs;
}
