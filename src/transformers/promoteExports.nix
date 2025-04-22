let
  inherit (builtins) map mapAttrs attrValues foldl' isAttrs;
in
  _: attr: _: attrs: let
    processed =
      mapAttrs
      (name: value:
        if isAttrs value && value ? "${attr}"
        then {
          exports = value.${attr};
          rest = removeAttrs value [attr];
        }
        else {
          exports = {};
          rest = value;
        })
      attrs;
    exportsList = map (v: v.exports) (attrValues processed);
    allExports = foldl' (acc: e: acc // e) {} exportsList;
    originalWithoutExports = mapAttrs (name: v: v.rest) processed;
  in
    originalWithoutExports // allExports
