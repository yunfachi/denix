{delib, ...}:
delib.module {
  name = "user";

  nixos.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    users = {
      groups.${username} = {};

      users.${username} = {
        isNormalUser = true;
        initialPassword = username;
        extraGroups = ["wheel"];
      };
    };
  };
}
