# Structure {#structure}

## Function Arguments {#function-arguments}
- `name`: a string representing the host name.
- `homeManagerSystem`: a string used in the `pkgs` attribute of the `home-manager.lib.homeManagerConfiguration` function, which is used in the [`delib.configurations`](/configurations/introduction) function as `homeManagerNixpkgs.legacyPackages.${homeManagerSystem}`.
- `myconfig`: sets its value to `config.${myconfigName}` if `config.${myconfigName}.host` matches the current host.
- `nixos`: sets its value to `config` if `isHomeManager` is `false` and `config.${myconfigName}.host` matches the current host.
- `home`: sets its value to `config` if `isHomeManager` is `true` and `config.${myconfigName}.host` matches the current host. Otherwise, if `config.${myconfigName}.host` matches the current host, sets its value to `config.home-manager.users.${homeManagerUser}`.
- `shared.myconfig`: sets its value to `config.${myconfigName}` for all hosts.
- `shared.nixos`: sets its value to `config` if `isHomeManager` is `false`. Otherwise, does nothing.
- `shared.home`: sets its value to `config` if `isHomeManager` is `true`. Otherwise, sets it to `config.home-manager.users.${homeManagerUser}`.

## Passed Arguments {#passed-arguments}
A list of arguments passed to `?(shared.)[myconfig|nixos|home]` if their type is `lambda`:
- `name`: the same `name` as in the arguments of `delib.host`.
- `myconfig`: equals `config.${myConfigName}`.
- `cfg`: equals `config.${myConfigName}.hosts.${delib.host :: name}`.

## Pseudocode {#pseudocode}
```nix
delib.host {
  name = "";

  # homeManagerNixpkgs.legacyPackages.${homeManagerSystem}
  homeManagerSystem = "x86_64-linux";

  # if config.${myconfigName}.host == name
  # then {config.${myConfigName} = ...;}
  # else {}
  myconfig = {name, cfg, myconfig, ...}: {};

  # if config.${myconfigName}.host == name
  # then {config = ...;}
  # else {}
  nixos = {name, cfg, myconfig, ...}: {};

  # if config.${myconfigName}.host == name, then
  #   if isHomeManager
  #   then {config = ...;}
  #   else {config.home-manager.users.${homeManagerUser} = ...;}
  # else {}
  home = {name, cfg, myconfig, ...}: {};

  # config.${myConfigName} = ...
  shared.myconfig = {name, cfg, myconfig, ...}: {};

  # config = ...
  shared.nixos = {name, cfg, myconfig, ...}: {};

  # if isHomeManager
  # then {}
  # else {config = ...;}
  shared.home = {name, cfg, myconfig, ...}: {};
}
```
