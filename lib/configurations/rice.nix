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
            params = delib.attrset.mkModuleArgs {
              inherit name;
              category = "rices";
              myconfig = config.${myconfigName};
            };

            wrap = x: if builtins.typeOf x == "lambda" then x params else x;
          in
          {
            # NOTE: using ${params.cfg} here is infinite recursion
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
