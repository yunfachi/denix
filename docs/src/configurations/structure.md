# Structure {#structure}

## Function Arguments {#function-arguments}
- `myconfigName` (string): the category for all Denix module options, hosts, and rices. Defaults to `myconfig`; changes are not recommended.
- `denixLibName` (string): the name of the Denix library in `specialArgs` (`{denixLibName, ...}: denixLibName.module { ... }`). Defaults to `delib`; changes are not recommended.
- `extensions` (listOf delib.extension): a list of extensions to be applied to the configuration. Defaults to `[]`.
- `nixpkgs` (nixpkgs): used to override nixpkgs in your configuration, equivalent to `inputs.denix.inputs.nixpkgs.follows`. Defaults to `inputs.nixpkgs`.
- `home-manager` (home-manager): used to override home-manager in your configuration, equivalent to `inputs.denix.inputs.home-manager.follows`. Defaults to `inputs.home-manager`.
- `nix-darwin` (nix-darwin): used to override nix-darwin in your configuration, equivalent to `inputs.denix.inputs.nix-darwin.follows`. Defaults to `inputs.nix-darwin`.
- `homeManagerNixpkgs` (nixpkgs): used in the `pkgs` attribute of the `home-manager.lib.homeManagerConfiguration` function in the format: `homeManagerNixpkgs.legacyPackages.${host :: homeManagerSystem}`. Defaults to the `nixpkgs` provided in the function arguments.
- `useHomeManagerModule` (boolean): whether to include the Home Manager module in the NixOS and Nix-Darwin configurations. Defaults to `true`; can be overridden per host via `delib.host :: useHomeManagerModule`.
- `homeManagerUser` (string): the username, used in `home-manager.users.${homeManagerUser}` and for generating the Home Manager configuration list. Can be overridden per host via `delib.host :: homeManagerUser`.
- `moduleSystem` ("nixos", "home", and "darwin"): specifies which module system the configuration list should be generated for - NixOS, Home Manager, or Nix-Darwin.
- `paths` (listOf string): paths to be imported; add hosts, rices, and modules here. Defaults to `[]`.
- `exclude` (listOf string): paths to be excluded from importing. Defaults to `[]`.
- `recursive` (boolean): determines whether to recursively search for paths to import. Defaults to `true`.
- `specialArgs` (attrset): `specialArgs` to be passed to `lib.nixosSystem`, `home-manager.lib.homeManagerConfiguration`, and `nix-darwin.lib.darwinSystem`. Defaults to `{}`.
- **EXPERIMENTAL** `extraModules` (list): defaults to `[]`.
- **EXPERIMENTAL** `mkConfigurationsSystemExtraModule` (attrset): a module used in the internal NixOS configuration that receives the list of hosts and rices to generate the configuration list. Defaults to `{nixpkgs.hostPlatform = "x86_64-linux";}`.

## Pseudocode {#pseudocode}
```nix
delib.configurations rec {
  myconfigName = "myconfig";
  denixLibName = "delib";
  extensions = with delib.extensions; [];
  nixpkgs = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  nix-darwin = inputs.nix-darwin;
  homeManagerNixpkgs = nixpkgs;
  useHomeManagerModule = true;
  homeManagerUser = "sjohn";
  moduleSystem = "nixos";
  paths = [./modules ./hosts ./rices];
  exclude = [./modules/deprecated];
  recursive = true;
  specialArgs = {
    inherit inputs;
  };
}
```
