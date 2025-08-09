{
  delib,
  myconfigName,
  ...
}:
{
  rice =
    {
      name,
      inherits ? [ ],
      inheritanceOnly ? false,
      myconfig ? { },
      nixos ? { },
      home ? { },
      darwin ? { },
      ...
    }@args:
    {
      imports = [
        (
          { config, ... }:
          let
            wrap =
              x:
              if builtins.typeOf x == "lambda" then
                x {
                  inherit name;
                  cfg = config.${myconfigName}.rices.${name};
                  myconfig = config.${myconfigName};
                }
              else
                x;
          in
          {
            config.${myconfigName}.rices.${name} = args // {
              myconfig = wrap myconfig;
              nixos = wrap nixos;
              home = wrap home;
              darwin = wrap darwin;
            };
          }
        )
      ];
    };

  riceSubmoduleOptions = with delib.options; {
    name = strOption null;
    inherits = listOfOption str [ ];
    inheritanceOnly = boolOption false;

    myconfig = attrsOption { };
    nixos = attrsOption { };
    home = attrsOption { };
    darwin = attrsOption { };
  };

  riceOption = rice: with delib.options; allowNull (submoduleOption rice null);
  ricesOption = rice: with delib.options; attrsOfOption (submodule rice) { };

  riceNamesAssertions =
    rices:
    builtins.attrValues (
      builtins.mapAttrs (name: value: {
        assertion = (builtins.hashString "sha256" name) == (builtins.hashString "sha256" value.name);
        message = "The rices attribute '${name}' does not match the value of rices.'${name}'.name (${value.name})";
      }) rices
    );
}
