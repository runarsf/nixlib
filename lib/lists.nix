_: let
  inherit (builtins) isList;
in {
  toList = x:
    if isList x
    then x
    else [x];
}
