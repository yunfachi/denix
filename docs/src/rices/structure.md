# Structure {#structure}

## Function Arguments {#function-arguments}
- `name`: a string representing the rice name.
- `inherits`: a list of strings - the names of rices whose configurations will be inherited by the current rice.
- `inheritanceOnly`: a boolean value that determines whether this rice will be added to the [list of systems generated for each host and rice](/configurations/introduction), or if it is only used for inheritance.
- `myconfig`: sets its value to `config.${myconfigName}` if `config.${myconfigName}.rice` matches the current rice.
- `nixos`: sets its value to `config` if `moduleSystem` is `nixos` and `config.${myconfigName}.rice` matches the current rice.
- `home`: sets its value to `config` if `moduleSystem` is `home` and `config.${myconfigName}.rice` matches the current rice. Otherwise, if `config.${myconfigName}.rice` matches the current rice, sets its value to `config.home-manager.users.${homeManagerUser}`.
- `darwin`: sets its value to `config` if `moduleSystem` is `darwin` and `config.${myconfigName}.rice` matches the current rice.

## Passed Arguments {#passed-arguments}
A list of arguments passed to `[myconfig|nixos|home|darwin]` if their type is `lambda`:
- `name`: the same `name` as in the arguments of `delib.rice`.
- `myconfig`: equals `config.${myConfigName}`.
- `cfg`: equals `config.${myConfigName}.rices.${delib.rice :: name}`.

## Pseudocode {#pseudocode}
```nix
delib.rice {
  name = "";

  inherits = [];

  inheritanceOnly = [];

  # if config.${myconfigName}.rice == name
  # then {config.${myConfigName} = ...;}
  # else {}
  myconfig = {name, cfg, myconfig, ...}: {};

  # if config.${myconfigName}.rice == name, then
  #   if moduleSystem == "nixos"
  #   then {config = ...;}
  #   else {}
  # else {}
  nixos = {name, cfg, myconfig, ...}: {};

  # if config.${myconfigName}.rice == name, then
  #   if moduleSystem == "home"
  #   then {config = ...;}
  #   else {config.home-manager.users.${homeManagerUser} = ...;}
  # else {}
  home = {name, cfg, myconfig, ...}: {};

  # if config.${myconfigName}.rice == name, then
  #   if moduleSystem == "darwin"
  #   then {config = ...;}
  #   else {}
  # else {}
  darwin = {name, cfg, myconfig, ...}: {};
}
```
