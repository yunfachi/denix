{
  lib,
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
}
