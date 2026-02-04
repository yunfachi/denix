{ delib, lib, ... }:
{
  moduleSystems.myconfig =
    { config, ... }:
    {
      enable = false;

      flakeOutputs = {
        modules = null;
        systems = null;
      };

      applyConfigForModuleSystem =
        value:
        let
          addPrefixToModule =
            if config.myconfigPrefix != null then
              delib.modules.addPrefixToModule (lib.splitString "." config.myconfigPrefix)
            else
              lib.id;
        in
        [ (delib.processModule addPrefixToModule value) ];
    };
}
