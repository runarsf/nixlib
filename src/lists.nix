{lib}: let
  inherit (lib.lists) length;
in rec {
  exports = {
    inherit isEmpty;
  };

  isEmpty = xs: length xs == 0;
}
