{ inputs, ... }:
{
  moduleSystems.nixos = {
    makeSystem =
      { modules, extraArgs, ... }:
      inputs.nixpkgs.lib.nixosSystem (
        {
          inherit modules;
        }
        // extraArgs
      );
  };
}
