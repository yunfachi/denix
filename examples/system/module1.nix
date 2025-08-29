{ delib, ... }:
{
  modules."programs.git" = {
    options = {
      enable = delib.boolOption false;
    };

    nixos.ifEnabled.programs.git.enable = true;
  };
}
