{
  homeManagerUser,
  isHomeManager,
  myconfigName,
  ...
}: {
  myconfig = myconfig: {
    ${myconfigName} = myconfig;
  };
  nixos = nixos:
    if !isHomeManager
    then nixos
    else {};
  home = home:
    if isHomeManager
    then home
    else {home-manager.users.${homeManagerUser} = home;};

  all = myconfig: nixos: home:
    {${myconfigName} = myconfig;}
    // (
      if isHomeManager
      then home
      else (nixos // {home-manager.users.${homeManagerUser} = home;})
    );
}
