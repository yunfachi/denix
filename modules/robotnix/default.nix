{ inputs, ... }:
{
  moduleSystems.robotnix = {
    makeSystem =
      { modules, ... }:
      inputs.robotnix.lib.robotnixSystem {
        imports = modules;
      };
  };
}
