{
  homeManagerUser,
  isHomeManager,
  myconfigName,
  ...
}: rec {
  myconfig = _myconfig: {
    ${myconfigName} = _myconfig;
  };
  nixos = _nixos:
    if !isHomeManager
    then _nixos
    else {};
  home = _home:
    if isHomeManager
    then _home
    else {home-manager.users.${homeManagerUser} = _home;};

  listOfEverything = _myconfig: _nixos: _home: [
    (myconfig _myconfig)
    (nixos _nixos)
    (home _home)
  ];
}
