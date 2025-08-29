{ delib, ... }:
{
  moduleSystems.myconfig =
    with delib;
    { name, ... }:
    {
      applyModuleSystemsConfig =
        {
          myconfigPrefix,
          moduleSystem,
          moduleName,
          value,
          type,
        }:
        {
          imports = [
            (lib.setFunctionArgs (
              { config, ... }@args:
              let
                mkMyConfigPrefix = myconfigPrefix: lib.optionalString (myconfigPrefix != null) "${myconfigPrefix}.";
                applied = value args;
                unified = lib.unifyModuleSyntax ./default.nix "somekey" applied;
              in
              {
                always = {
                  config = delib.setAttrByStrPath unified.config myconfigPrefix;
                  options = delib.setAttrByStrPath unified.options myconfigPrefix;
                };

                ifEnabled = {
                  config = lib.mkIf (delib.getAttrByStrPath config
                    "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable"
                    false
                  ) (delib.setAttrByStrPath unified.config myconfigPrefix);
                  options = lib.mkIf (delib.getAttrByStrPath config
                    "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable"
                    false
                  ) (delib.setAttrByStrPath unified.options myconfigPrefix);
                };

                ifDisabled = {
                  config = lib.mkIf (
                    !(delib.getAttrByStrPath config "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable" true)
                  ) (delib.setAttrByStrPath unified.config myconfigPrefix);
                  options = lib.mkIf (
                    !(delib.getAttrByStrPath config "${mkMyConfigPrefix myconfigPrefix}${moduleName}.enable" true)
                  ) (delib.setAttrByStrPath unified.options myconfigPrefix);
                };
              }
              .${type}
            ) (lib.getFunctionArgs value))
          ];
        };
    };
}
