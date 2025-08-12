{ delib, ... }:
delib.host {
  name = "desktop";

  system = "x86_64-linux"; # !!! REPLACEME

  # useHomeManagerModule = false;
  home.home.stateVersion = "24.05"; # !!! REPLACEME

  # If you're not using NixOS, you can remove this entire block.
  nixos = {
    system.stateVersion = "24.05"; # !!! REPLACEME

    # nixos-generate-config --show-hardware-config
    # other generated code here...
  };

  # If you're not using Nix-Darwin, you can remove this entire block.
  darwin = {
    system.stateVersion = 6; # !!! REPLACEME
  };
}
