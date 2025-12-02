{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.homeManager;
in
{
  imports = [
    ./moduleSystem.nix
    ./nonStandalone.nix
    ./standalone.nix
  ];

  options.homeManager = with delib; {
    users = attrsOfOption (listOf (enum (builtins.attrNames config.moduleSystems))) { };
  };

  config.modules."home-manager".home.always =
    let
      username = cfg.standalone.user or null;
    in
    lib.optional (username != null) (
      { pkgs, ... }@inputs:
      {
        home = {
          username = lib.mkDefault (inputs.osConfig.users.users.${username}.name or username);
          homeDirectory = lib.mkDefault (
            inputs.osConfig.users.users.${username}.home
              or (if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}")
          );
        };
      }
    );
}
