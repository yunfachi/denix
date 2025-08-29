{
  inputs = {
    #nixpkgs.url = "/home/yunfachi/files/desktop/git/nixpkgs";
    denix.url = "../../.";
    #denix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      denix,
      self,
      ...
    }:
    let
      delib = denix.lib;
    in
    {
      denixConfiguration = delib.denixConfiguration {
        modules = [ ./module.nix ];
      };

      nixosModules.default = delib.compileModule {
        moduleSystem = "nixos";
        configuration = self.denixConfiguration;
      };

      homeModules.default = delib.compileModule {
        moduleSystem = "home";
        configuration = self.denixConfiguration;
        /*
          applyMyConfig =
            { myconfig, ... }:
            {
              imports = myconfig.type.getSubModules;
            };
        */
      };
    };
}
