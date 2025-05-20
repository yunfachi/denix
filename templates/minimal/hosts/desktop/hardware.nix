{delib, ...}:
delib.host {
  name = "desktop";

  homeManagerSystem = "x86_64-linux"; #!!! REPLACEME
  home.home.stateVersion = "24.05"; #!!! REPLACEME

  # If you're not using NixOS, you can remove this entire block.
  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux"; #!!! REPLACEME
    system.stateVersion = "24.05"; #!!! REPLACEME

    # nixos-generate-config --show-hardware-config
    # other generated code here...
  };

  # If you're not using Nix-Darwin, you can remove this entire block.
  darwin = {
    nixpkgs.hostPlatform = "aarch64-darwin"; #!!! REPLACEME
    system.stateVersion = "6"; #!!! REPLACEME
  };
}
