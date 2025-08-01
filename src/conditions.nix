{lib}: let
  inherit (lib.modules) mkIf mkMerge;
in rec {
  exports = {
    inherit
      mkIfElse
      ;
  };

  mkIfElse = p: yes: no:
    mkMerge [
      (mkIf p yes)
      (mkIf (!p) no)
    ];
}
