{
  lib,
  myconfigName,
  options,
  ...
}: {
  rice = {
    name,
    myconfig ? {},
    nixos ? {},
    home ? {},
    ...
  } @ args: {
    config.${myconfigName}.rices.${name} = args;
  };

  riceSubmoduleOptions = with options; {
    name = strOption null;

    myconfig = allowLambdaTo attrs (attrsOption {});
    nixos = allowLambdaTo attrs (attrsOption {});
    home = allowLambdaTo attrs (attrsOption {});
  };

  riceOption = rice:
    with options; allowNull (submoduleOption rice null);
  ricesOption = rice:
    with options; attrsOfOption (submodule rice) {};

  riceNamesAssertions = rices:
    builtins.attrValues (builtins.mapAttrs
      (name: value: {
        assertion = (builtins.hashString "sha256" name) == (builtins.hashString "sha256" value.name);
        message = "The rices attribute '${name}' does not match the value of rices.'${name}'.name (${value.name})";
      })
      rices);
}
