{delib, ...}:
delib.host {
  name = "desktop";

  homeManagerSystem = "x86_64-linux";
  home.home.stateVersion = "24.05";

  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "24.05";

    # nixos-generate-config --show-hardware-config
    # other generated code here...
  };
}
