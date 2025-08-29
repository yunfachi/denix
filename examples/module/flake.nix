{
  inputs = {
    denix.url = "../../.";
  };

  outputs =
    {
      denix,
      self,
      ...
    }:
    let
      delib = denix.lib;
      modules = delib.genModules {
        configuration = self.denixConfiguration;
      };
    in
    {
      denixConfiguration = delib.denixConfiguration {
        modules = [ ./module.nix ];
      };

      nixosModules.default = modules.nixos;

      homeModules.default = modules.home;
    };
}
