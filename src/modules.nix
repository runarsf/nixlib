{lib}: let
  inherit (builtins) throw;

  inherit (lib.types) bool;

  inherit (lib.lists) toList;

  inherit (lib.modules) mkIf;

  inherit (lib.attrsets) setAttrByPath getAttrFromPath;

  inherit (lib.options) mkOption;

  inherit (lib.strings) concatStringsSep;
in rec {
  exports = {
    inherit mkModuleWithOptions mkModule mkModule';
  };

  mkModuleWithOptions = {
    config,
    name,
    moduleConfig,
    default ? false,
    extraCondition ? (x: x && true),
  }: let
    pathList = toList name;
    stringName = concatStringsSep "." pathList;

    options = moduleConfig.options or {};
    options' = moduleConfig.options' or {};
    cfg =
      if (moduleConfig ? options || moduleConfig ? options')
      then moduleConfig.config or (throw "Missing toplevel config attribute for '${stringName}'")
      else moduleConfig.config or moduleConfig;

    modulePath = ["modules"] ++ pathList;
    enableOptionPath = modulePath ++ ["enable"];

    moduleOptions =
      {
        enable = mkOption {
          inherit default;
          type = bool;
          description = "Enable ${stringName} module";
        };
      }
      // options';
  in {
    options = (setAttrByPath modulePath moduleOptions) // options;

    config = mkIf (extraCondition <| getAttrFromPath enableOptionPath config) cfg;
  };

  mkModule = config: name: moduleConfig:
    mkModuleWithOptions {
      inherit
        config
        name
        moduleConfig
        ;
    };

  mkModule' = config: name: default: moduleConfig:
    mkModuleWithOptions {
      inherit
        config
        name
        default
        moduleConfig
        ;
    };
}
