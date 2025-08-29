{ delib, ... }:
delib.host {
  name = "host2";

  nixos.ifEnabled.nixpkgs.hostPlatform = "x86_64-linux";
}
