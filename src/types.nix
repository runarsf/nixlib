{
  lib,
  lib',
}: let
  inherit (builtins) map;

  inherit (lib') deepMerge;

  inherit (lib.types) mkOptionType;
in {
  # Override nixpkgs.lib.types.attrs to be deep-mergeable. This avoids configs
  # from mistakenly overriding values due to the use of `//`.
  attrs.merge = _: definitions: let
    values = map (definition: definition.value) definitions;
  in
    deepMerge values;

  anything = mkOptionType {
    name = "anything";
    description = "Anything!";
    check = _: true;
  };
}
