# Structure {#structure}

## Function Arguments {#function-arguments}
- `myconfigName` (string): the category for all Denix module options, hosts, and rices. Default is `myconfig`; changes are not recommended.
- `denixLibName` (string): the name of the Denix library in `specialArgs` (`{denixLibName, ...}: denixLibName.module { ... }`). Default is `delib`; changes are not recommended.
- `homeManagerNixpkgs` (nixpkgs): used in the `pkgs` attribute of the `home-manager.lib.homeManagerConfiguration` function in the format: `homeManagerNixpkgs.legacyPackages.${host :: homeManagerSystem}`. By default, it takes `nixpkgs` from the flake, so if you've set `inputs.denix.inputs.nixpkgs.follows = "nixpkgs";`, specifying `homeManagerNixpkgs` is typically unnecessary.
- `homeManagerUser` (string): the username, used in `home-manager.users.${homeManagerUser}` and for generating the Home Manager configuration list.
- `moduleSystem` ("nixos", "home", and "darwin"): specifies which module system the configuration list should be generated for - NixOS, Home Manager, or Nix-Darwin.
- `paths` (listOf string): paths to be imported; add hosts, rices, and modules here. Default is `[]`.
- `exclude` (listOf string): paths to be excluded from importing. Default is `[]`.
- `recursive` (boolean): determines whether to recursively search for paths to import. Default is `true`.
- `specialArgs` (attrset): `specialArgs` to be passed to `lib.nixosSystem`, `home-manager.lib.homeManagerConfiguration`, and `nix-darwin.lib.darwinSystem`. Default is `{}`.
- **EXPERIMENTAL** `extraModules` (list): default is `[]`.
- **EXPERIMENTAL** `mkConfigurationsSystemExtraModule` (attrset): a module used in the internal NixOS configuration that receives the list of hosts and rices to generate the configuration list. Default is `{nixpkgs.hostPlatform = "x86_64-linux";}`.

## Pseudocode {#pseudocode}
```nix
delib.configurations {
  myconfigName = "myconfig";
  denixLibName = "delib";
  homeManagerNixpkgs = inputs.nixpkgs;
  homeManagerUser = "sjohn";
  moduleSystem = "nixos";
  paths = [./modules ./hosts ./rices];
  exclude = [./modules/deprecated];
  recursive = true;
  specialArgs = {
    inherit inputs;
  };
}
