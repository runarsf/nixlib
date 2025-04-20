{lib}: let
  inherit (lib.types) mkOptionType;
in {
  anything = mkOptionType {
    name = "anything";
    description = "Anything!";
    check = _: true;
  };
}
