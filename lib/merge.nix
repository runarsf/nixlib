{lib, ...}: {
  # Merges a list of attributes into one, including lists and nested attributes.
  # Use this instead of lib.mkMerge if the merge type isn't allowed somewhere.
  # https://stackoverflow.com/a/54505212
  deepMerge = attrs: let
    merge = path:
      builtins.zipAttrsWith (n: values:
        if builtins.tail values == []
        then builtins.head values
        else if builtins.all builtins.isList values
        then lib.unique (lib.concatLists values)
        else if builtins.all builtins.isAttrs values
        then merge (path ++ [n]) values
        else lib.last values);
  in
    merge [] attrs;
}
