{
  delib,
  lib,
  config,
  ...
}:
{
  imports = [
    ./moduleSystems/default.nix
  ];

  options =
    with delib;
    let
      modulesOption = lib.mkOption {
        type = lib.mkOptionType {
          name = "modules";
          check = with lib; x: !(isFunction x && isPath x && isAttrs x && isList x);
          merge =
            loc: defs:
            lib.concatLists (
              map (
                def:
                lib.toList (
                  if lib.isFunction def.value then
                    lib.setFunctionArgs def.value (lib.functionArgs def.value)
                  else
                    def.value
                )
              ) defs
            );
        };
        default = [ ];
      };
    in
    {
      myconfigPrefix = allowNull (strOption "myconfig");

      modules = attrsOfOption (
        functionTo (submoduleWith {
          # NOTE: requires https://github.com/NixOS/nixpkgs/pull/437972
          onlyDefinesConfig = true;
          modules = [
            (
              { name, ... }:
              {
                options = {
                  name = readOnly (strOption name) true;

                  options = modulesOption;
                }
                // builtins.mapAttrs (name: value: {
                  always = modulesOption;
                  ifEnabled = modulesOption;
                  ifDisabled = modulesOption;
                }) config.moduleSystems;
              }
            )
          ];
        })
      );
    };
}
