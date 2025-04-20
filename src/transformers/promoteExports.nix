let
  inherit (builtins) map listToAttrs concatMap attrNames isAttrs;
in
  _: attr: _: attrs: let
    # Replace attributes with their 'default' if present
    replaced =
      builtins.mapAttrs (
        k: v:
          if v ? ${attr}
          then v.${attr}
          else v
      )
      attrs;

    # Generate promoted attributes from nested defaults
    promoted = listToAttrs (concatMap (
      k: let
        entry = attrs.${k};
      in
        if entry ? ${attr} && isAttrs entry.${attr}
        then
          map (sk: {
            name = sk;
            value = replaced.${k}.${sk};
          }) (attrNames entry.${attr})
        else []
    ) (attrNames attrs));
  in
    replaced // promoted
