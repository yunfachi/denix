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
        modules = [
          ./module1.nix
          ./module2.nix
          ./host1.nix
          ./host2.nix
        ];
      };

      nixosConfigurations = self.denixConfiguration.genSystem {
        moduleSystem = "nixos";
        forEachHost = true;
      };
    };
}
