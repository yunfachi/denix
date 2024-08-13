{
  lib,
  apply,
  config,
  myconfigName,
  options,
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
  in {
    config.${myconfigName}.hosts.${name} = args;

    imports = with _shared; [
      (apply.myconfig myconfig)
      (apply.nixos nixos)
      (apply.home home)
    ];
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
