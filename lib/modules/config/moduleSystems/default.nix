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
            mkMyConfigPrefix = myconfigPrefix: lib.optionalString (myconfigPrefix != null) "${myconfigPrefix}.";
          in
          {
            options = {
              name = readOnly (strOption name);

              myconfigPrefix = allowNull (strOption myconfigPrefixDefault);

              applyOptions = functionToOption attrs (
                {
                  myconfigPrefix,
                  moduleName,
                  value,
                }:
                {
                  imports = [
                    (lib.setFunctionArgs (args: {
                      options = delib.setAttrByStrPath (value args) ((mkMyConfigPrefix myconfigPrefix) + moduleName);
                    }) (lib.functionArgs value))
                  ];
                }
              );

              applyModuleSystemsConfig = functionToOption attrs (
                {
                  myconfigPrefix,
                  moduleSystem,
                  moduleName,
                  value,
                  type,
                }:
                lib.optionalAttrs (moduleSystem == name) {
                  imports = [
                    {
                      always = value;
                      ifEnabled = lib.setFunctionArgs (
                        { config, ... }@args:
                        lib.mkIf (delib.getAttrByStrPath config "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable"
                          false
                        ) (value args)
                      ) ({ config = false; } // (lib.functionArgs value));
                      ifDisabled = lib.setFunctionArgs (
                        { config, ... }@args:
                        lib.mkIf (
                          !(delib.getAttrByStrPath config "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable" true)
                        ) (value args)
                      ) ({ config = false; } // (lib.functionArgs value));
                    }
                    .${type}
                  ];
                }
              );
            };
          }
        )
      ];
    }) { };
  };
}
