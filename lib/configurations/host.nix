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
    darwin ? {},
    shared ? {},
    # to avoid overwriting
    # homeManagerSystem ? null,
    # rice ? null,
    ...
  } @ args: {
    imports = [
      ({config, ...}: let
        sharedDefaults = {
          myconfig ? {},
          nixos ? {},
          home ? {},
          darwin ? {},
        }: {inherit myconfig nixos home darwin;};
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
            darwin = wrap darwin;
            shared = {
              myconfig = wrap _shared.myconfig;
              nixos = wrap _shared.nixos;
              home = wrap _shared.home;
              darwin = wrap _shared.darwin;
            };
          };

        imports =
          (apply.listOfEverything (wrap _shared.myconfig) (wrap _shared.nixos) (wrap _shared.home) (wrap _shared.darwin))
          ++ (
            if currentHostName == name
            then apply.listOfEverything (wrap myconfig) (wrap nixos) (wrap home) (wrap darwin)
            else []
          );
      })
    ];
  };

  # TODO: get config through `hostSubmoduleOption = config: ...`
  hostSubmoduleOptions = with delib.options; {
    name = noDefault (strOption null);

    homeManagerSystem = description (noDefault (strOption null)) "Passed to the `homeManagerConfiguration` as `nixpkgs.legacyPackages.<homeManagerSystem>`";

    myconfig = attrsOption {};
    nixos = attrsOption {};
    home = attrsOption {};
    darwin = attrsOption {};

    shared = {
      myconfig = attrsOption {};
      nixos = attrsOption {};
      home = attrsOption {};
      darwin = attrsOption {};
    };

    rice = allowNull (enumOption (
        let
          rices = config.${myconfigName}.rices or null;
        in
          if rices == null
          then []
          else builtins.attrNames rices
      )
      null);
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
