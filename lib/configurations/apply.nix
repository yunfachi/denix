{
  useHomeManagerModule,
  homeManagerUser,
  moduleSystem,
  myconfigName,
  ...
}:
rec {
  configForModuleSystem =
    {
      nixos ? { },
      home ? { },
      darwin ? { },
    }:
    {
      inherit nixos home darwin;
    }
    .${moduleSystem};

  myconfig = _myconfig: { ${myconfigName} = _myconfig; };

  nixos =
    _nixos:
    configForModuleSystem {
      nixos = _nixos;
      home = { };
      darwin = { };
    };
  home =
    _home:
    configForModuleSystem {
      nixos =
        if useHomeManagerModule then
          {
            home-manager.users.${homeManagerUser} = _home;
          }
        else
          { };
      home = _home;
      darwin =
        if useHomeManagerModule then
          {
            home-manager.users.${homeManagerUser} = _home;
          }
        else
          { };
    };
  darwin =
    _darwin:
    configForModuleSystem {
      nixos = { };
      home = { };
      darwin = _darwin;
    };

  listOfEverything = _myconfig: _nixos: _home: _darwin: [
    (myconfig _myconfig)
    (nixos _nixos)
    (home _home)
    (darwin _darwin)
  ];
}
