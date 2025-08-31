{
  delib,
  lib,
  config,
  ...
}:
let
  myconfigPrefixDefault = config.myconfigPrefix;
in
{
  imports = [
    ./darwin.nix
    ./home.nix
    ./nixos.nix
  ];

  options = with delib; {
    moduleSystems = lazyAttrsOfOption (submoduleWith {
      modules = [
        (
          { config, name, ... }:
          let
            myconfigPrefix = lib.optionalString (config.myconfigPrefix != null) "${config.myconfigPrefix}.";
          in
          {
            options = {
              name = readOnly (strOption name);

              myconfigPrefix = allowNull (strOption myconfigPrefixDefault);

              applyModuleSystemsConfig = functionToOption list (
                {
                  moduleSystem,
                  moduleName,
                  module,
                }:
                lib.optionals (moduleSystem == name) (
                  module.always
                  ++ map (
                    m: { config, ... }: lib.mkIf (delib.getAttrByStrPath config "${moduleName}.enable" false) m
                  ) module.ifEnabled
                  ++ map (
                    m: { config, ... }: lib.mkIf (!(delib.getAttrByStrPath config "${moduleName}.enable" true)) m
                  ) module.ifDisabled
                )
              );

              applyOptions = functionToOption list (
                {
                  moduleName,
                  options,
                }:
                map (module: args: {
                  options = delib.setAttrByStrPath (lib.applyModuleArgsIfFunction "somekey" module args) (
                    myconfigPrefix + (builtins.trace moduleName moduleName)
                  );
                }) options
              );

              applyMyConfig = functionToOption list (
                {
                  moduleName,
                  myconfig,
                }:
                map (
                  module: args:
                  let
                    applied = lib.applyModuleArgsIfFunction "somekey" module args;
                    unified = lib.unifyModuleSyntax ./default.nix "somekey" applied;
                  in
                  {
                    config = delib.setAttrByStrPath unified.config myconfigPrefix;
                    options = delib.setAttrByStrPath unified.options myconfigPrefix;
                  }
                ) myconfig.always
                ++ map (
                  module: args:
                  let
                    applied = lib.applyModuleArgsIfFunction "somekey" module args;
                    unified = lib.unifyModuleSyntax ./default.nix "somekey" applied;
                  in
                  {
                    config = lib.mkIf (delib.getAttrByStrPath config "${moduleName}.enable" false) (
                      delib.setAttrByStrPath unified.config myconfigPrefix
                    );
                    options = lib.mkIf (delib.getAttrByStrPath config "${moduleName}.enable" false) (
                      delib.setAttrByStrPath unified.options myconfigPrefix
                    );
                  }
                ) myconfig.ifEnabled
                ++ map (
                  module: args:
                  let
                    applied = lib.applyModuleArgsIfFunction "somekey" module args;
                    unified = lib.unifyModuleSyntax ./default.nix "somekey" applied;
                  in
                  {
                    config = lib.mkIf (!(delib.getAttrByStrPath config "${moduleName}.enable" true)) (
                      delib.setAttrByStrPath unified.config myconfigPrefix
                    );
                    options = lib.mkIf (!(delib.getAttrByStrPath config "${moduleName}.enable" true)) (
                      delib.setAttrByStrPath unified.options myconfigPrefix
                    );
                  }
                ) myconfig.ifDisabled
              );
            };
          }
        )
      ];
    }) { };
  };
}
