{ lib, delib, ... }:
let
  inherit (delib) extension singleEnableOption maintainers;
  inherit (lib) elem mkIf optional;
in
extension {
  name = "overlays";
  description = "Simplified overlay configuration module";
  maintainers = with maintainers; [ zonni ];

  config = final: prev: {
    defaultTargets = [
      "nixos"
      "home"
    ];
    moduleNamePrefix = "overlays";
  };

  libExtension = config: final: _: {
    overlayModule =
      {
        name,
        overlay ? null,
        overlays ? [ ],
        targets ? config.defaultTargets,
        withPrefix ? true,
        enabled ? true,
      }:
      let
        finalOverlays = overlays ++ (optional (overlay != null) overlay);
      in
      final.module {
        name = if withPrefix then "${config.moduleNamePrefix}.${name}" else name;

        options = singleEnableOption enabled;

        nixos.ifEnabled = mkIf (elem "nixos" targets) {
          nixpkgs.overlays = finalOverlays;
        };

        home.ifEnabled = mkIf (elem "home" targets) {
          nixpkgs.overlays = finalOverlays;
        };

        darwin.ifEnabled = mkIf (elem "darwin" targets) {
          nixpkgs.overlays = finalOverlays;
        };
      };
  };
}
