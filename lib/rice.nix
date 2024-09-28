{
  lib,
  config,
  myconfigName,
  options,
  ...
}: {
  rice = {
    name,
    inherits ? [],
    inheritanceOnly ? false,
    myconfig ? {},
    nixos ? {},
    home ? {},
    ...
  } @ args: let
    wrap = x:
      if builtins.typeOf x == "lambda"
      then
        x {
          inherit name;
          cfg = config.${myconfigName}.rices.${name};
          myconfig = config.${myconfigName};
        }
      else x;
  in {
    config.${myconfigName}.rices.${name} =
      {
        inherit name;
        myconfig = wrap myconfig;
        nixos = wrap nixos;
        home = wrap home;
      }
      // lib.optionalAttrs inheritanceOnly {inherit inheritanceOnly;}
      // lib.optionalAttrs (inherits != []) {inherit inherits;};
  };

  riceSubmoduleOptions = with options; {
    name = strOption null;
    inherits = listOfOption str [];
    inheritanceOnly = boolOption false;

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
