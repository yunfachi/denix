{ delib, ... }:
delib.module {
  name = "programs.bash";
  options = {
    enable = delib.boolOption false;
  };

  nixos.ifEnabled.programs.bash.enable = true;
  nixos.ifDisabled.programs.bash.enable = false;
}
