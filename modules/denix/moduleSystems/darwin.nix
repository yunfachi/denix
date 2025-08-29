{ inputs, ... }:
{
  moduleSystems.darwin = {
    makeSystem =
      { modules, extraArgs, ... }:
      inputs.nix-darwin.lib.darwinSystem (
        {
          inherit modules;
        }
        // extraArgs
      );
  };
}
