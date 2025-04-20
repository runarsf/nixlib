{
  lib,
  lib',
}: let
  inherit (builtins) isString isList throw;

  inherit
    (lib)
    mkOption
    setAttrByPath
    getAttrFromPath
    mkIf
    ;

  inherit (lib.types) bool;

  inherit (lib') fmatch;
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
    options = moduleConfig.options or {};
    options' = moduleConfig.options' or {};
    cfg =
      if (moduleConfig ? options || moduleConfig ? options')
      then moduleConfig.config or (throw "Missing toplevel config attribute")
      else moduleConfig.config or moduleConfig;

    pathList = fmatch name [
      [
        isList
        name
      ]
      [
        isString
        [name]
      ]
    ];

    modulePath = ["modules"] ++ pathList;
    enableOptionPath = modulePath ++ ["enable"];

    moduleOptions =
      {
        enable = mkOption {
          inherit default;
          type = bool;
          description = "Enable ${name} module";
        };
      }
      // options;
  in {
    options = (setAttrByPath modulePath moduleOptions) // options';

    config = mkIf (extraCondition (getAttrFromPath enableOptionPath config)) cfg;
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
