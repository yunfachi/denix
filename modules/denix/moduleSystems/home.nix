{ inputs, ... }:
{
  moduleSystems.home = {
    makeSystem =
      { modules, extraArgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration (
        {
          inherit modules;
        }
        // extraArgs
      );
  };
}
