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
      foo = apply (anythingOption [ ]) lib.toList;
    in
    {
      myconfigPrefix = allowNull (strOption "myconfig");

      modules = attrsOfOption (
        # FIXME: https://github.com/NixOS/nixpkgs/issues/438933
        functionTo (submoduleWith {
          # NOTE: requires https://github.com/NixOS/nixpkgs/pull/437972
          onlyDefinesConfig = true;
          modules = [
            (
              { name, ... }:
              {
                options = {
                  name = readOnly (strOption name) true;

                  options = foo;

                  myconfig = {
                    ifEnabled = foo;
                    ifDisabled = foo;
                    always = foo;
                  };
                }
                // builtins.mapAttrs (name: value: {
                  ifEnabled = foo;
                  ifDisabled = foo;
                  always = foo;
                }) config.moduleSystems;
              }
            )
          ];
        })
      );
    };
}
