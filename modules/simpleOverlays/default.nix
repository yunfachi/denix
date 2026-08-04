{
  lib,
  config,
  delib,
  ...
}:
let
  cfg = config.simpleOvelays;
in
{
  # maintainers = with maintainers; [ zonni ];

  options.simpleOvelays = {
    defaultTargets = delib.listOfOption delib.str [ "nixos" ];
    moduleNamePrefix = delib.strOption "overlays";
  };
}
