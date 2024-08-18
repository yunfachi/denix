# Structure {#structure}
This section uses the variables `myconfigName`, `isHomeManager`, and `homeManagerUser`, so it's recommended to first review the corresponding subsection: [delib.system Function Arguments](/TODO).

## Function Arguments {#function-arguments}
- `name`{#function-arguments-name}: string. It is recommended that it matches the parent path of the module's `enable` option, such as `"programs.example"`, since the `cfg` argument depends on this path.
- `options`: attrset or a lambda that returns an attrset (see [Options](/TODO)).
- `[myconfig|nixos|home].[ifEnabled|ifDisabled|always]`: attrset or a lambda that returns an attrset.
- `myconfig.*`: sets values in `config.${myconfigName}`.
- `nixos.*`: sets values in `config` if `isHomeManager` is `false`; otherwise, it does nothing.
- `home.*`: sets values in `config` if `isHomeManager` is `true`; otherwise, in `config.home-manager.users.${homeManagerUser}`.
- `[myconfig|nixos|home].ifEnabled`: executed only if the `cfg.enable` option (see [Passed Arguments - cfg](#passed-arguments-cfg)) exists and is `true`.
- `[myconfig|nixos|home].ifDisabled`: executed only if the `cfg.enable` option exists and is `false`.
- `[myconfig|nixos|home].always`: always executed, even if the `cfg.enable` option doesn't exist.

## Passed Arguments {#passed-arguments}
A list of arguments passed to `options` and `[myconfig|nixos|home].[ifEnabled|ifDisabled|always]`, if their type is a `lambda`:
- `name`: the same [name](#function-arguments-name) from the `delib.module` arguments. 
- `myconfig`: equals `config.${myConfigName}`.
- `cfg`{#passed-arguments-cfg}: equals the result of the expression `delib.getAttrByStrPath name config.${myConfigName} {}`, where `name` is the [argument](#function-arguments-name) from `delib.module`, and `{}` is the value returned if the attribute is not found.

## Pseudocode {#pseudocode}
```nix
delib.module {
  name = "";
  
  # options.${myConfigName} = ...
  options = {name, cfg, myconfig, ...}: {};

  # config.${myConfigName} = ...
  myconfig.ifEnabled = {name, cfg, myconfig, ...}: {};
  myconfig.ifDisabled = {name, cfg, myconfig, ...}: {};
  myconfig.always = {name, cfg, myconfig, ...}: {};

  # if isHomeManager
  # then {}
  # else {config = ...;}
  nixos.ifEnabled = {name, cfg, myconfig, ...}: {};
  nixos.ifDisabled = {name, cfg, myconfig, ...}: {};
  nixos.always = {name, cfg, myconfig, ...}: {};

  # if isHomeManager
  # then {config = ...;}
  # else {config.home-manager.users.${homeManagerUser} = ...;}
  home.ifEnabled = {name, cfg, myconfig, ...}: {};
  home.ifDisabled = {name, cfg, myconfig, ...}: {};
  home.always = {name, cfg, myconfig, ...}: {};
};
```
