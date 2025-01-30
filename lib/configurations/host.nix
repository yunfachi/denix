{
  delib,
  lib,
  apply,
  myconfigName,
  config,
  currentHostName,
  ...
}: {
  host = {
    name,
    myconfig ? {},
    nixos ? {},
    home ? {},
    shared ? {},
    # to avoid overwriting
    # homeManagerSystem ? null,
    ...
  } @ args: {
    imports = [
      ({config, ...}: let
        sharedDefaults = {
          myconfig ? {},
          nixos ? {},
          home ? {},
        }: {inherit myconfig nixos home;};
        _shared = sharedDefaults shared;

        wrap = x:
          if builtins.typeOf x == "lambda"
          then
            x {
              inherit name;
              cfg = config.${myconfigName}.hosts.${name};
              myconfig = config.${myconfigName};
            }
          else x;
      in {
        config.${myconfigName}.hosts.${name} =
          args
          // {
            myconfig = wrap myconfig;
            nixos = wrap nixos;
            home = wrap home;
            shared = {
              myconfig = wrap _shared.myconfig;
              nixos = wrap _shared.nixos;
              home = wrap _shared.home;
            };
          };

        imports =
          [
            (apply.myconfig (wrap _shared.myconfig))
            (apply.nixos (wrap _shared.nixos))
            (apply.home (wrap _shared.home))
          ]
          ++ (
            if currentHostName == name
            then [
              (apply.myconfig (wrap myconfig))
              (apply.nixos (wrap nixos))
              (apply.home (wrap home))
            ]
            else []
          );
      })
    ];
  };

  # TODO: get config through `hostSubmoduleOption = config: ...`
  hostSubmoduleOptions = with delib.options;
    {
      name = strOption null;

      homeManagerSystem = description (noDefault (strOption null)) "Passed to the `homeManagerConfiguration` as `nixpkgs.legacyPackages.<homeManagerSystem>`";

      myconfig = attrsOption {};
      nixos = attrsOption {};
      home = attrsOption {};

      shared = {
        myconfig = attrsOption {};
        nixos = attrsOption {};
        home = attrsOption {};
      };
    }
    // lib.optionalAttrs (config.${myconfigName} ? rices) {
      rice = allowNull (enumOption (builtins.attrNames config.${myconfigName}.rices) null);
    };

  hostOption = host:
    with delib.options; noDefault (submoduleOption host null);
  hostsOption = host:
    with delib.options; attrsOfOption (submodule host) {};

  hostNamesAssertions = hosts:
    builtins.attrValues (builtins.mapAttrs
      (name: value: {
        assertion = (builtins.hashString "sha256" name) == (builtins.hashString "sha256" value.name);
        message = "The hosts attribute '${name}' does not match the value of hosts.'${name}'.name (${value.name})";
      })
      hosts);
}
