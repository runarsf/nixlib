{
  lib,
  lib',
}: let
  inherit (lib.options) mkEnableOption;

  inherit (lib'.modules) mkModuleWithOptions;
in
  (mkModuleWithOptions {
    config = {};
    name = "test";
    extraCondition = _: true;
    moduleConfig = {
      options = {hello = mkEnableOption "hi";};
      config = {hello = "world";};
    };
  }).config
