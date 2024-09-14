{
  lib,
  apply,
  config,
  myconfigName,
  options,
  currentHostName,
  ...
}: {
  host = {
    name,
    myconfig ? {},
    nixos ? {},
    home ? {},
    shared ? {},
    ...
  } @ args: let
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
    config.${myconfigName}.hosts.${name} = args;

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
  };

  hostSubmoduleOptions = with options; {
    name = strOption null;

    rice = allowNull (enumOption (builtins.attrNames config.${myconfigName}.rices) null);
    homeManagerSystem = description (noDefault (strOption null)) "Passed to the `homeManagerConfiguration` as `nixpkgs.legacyPackages.<homeManagerSystem>`";

    myconfig = allowLambdaTo attrs (attrsOption {});
    nixos = allowLambdaTo attrs (attrsOption {});
    home = allowLambdaTo attrs (attrsOption {});

    shared = {
      myconfig = allowLambdaTo attrs (attrsOption {});
      nixos = allowLambdaTo attrs (attrsOption {});
      home = allowLambdaTo attrs (attrsOption {});
    };
  };

  hostOption = host:
    with options; noDefault (submoduleOption host null);
  hostsOption = host:
    with options; attrsOfOption (submodule host) {};

  hostNamesAssertions = hosts:
    builtins.attrValues (builtins.mapAttrs
      (name: value: {
        assertion = (builtins.hashString "sha256" name) == (builtins.hashString "sha256" value.name);
        message = "The hosts attribute '${name}' does not match the value of hosts.'${name}'.name (${value.name})";
      })
      hosts);
}
