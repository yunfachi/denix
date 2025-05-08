# Configuration Initialization {#initialization}
This section will describe creating the `minimal` template from scratch.

You do not have to do this; you can simply clone the minimal configuration template with the following command:
```sh
nix flake init -t github:yunfachi/denix#minimal
```

You can also copy the minimal configuration template without the rices:
```sh
nix flake init -t github:yunfachi/denix#minimal-no-rices
```

## Flake {#flake}
First, create a directory for your configuration and a `flake.nix` file with the following content:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    denix,
    nixpkgs,
    ...
  } @ inputs: let
    mkConfigurations = isHomeManager:
      denix.lib.configurations {
        homeManagerUser = "sjohn"; #!!! REPLACEME
        inherit isHomeManager;

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations false;
    homeConfigurations = mkConfigurations true;
  };
}
```

If you are not familiar with `inputs` and `outputs`, read [NixOS Wiki Flakes](https://nixos.wiki/wiki/Flakes).

Code explanation:
- `mkConfigurations` - a function to reduce code repetition, which takes `isHomeManager` and passes it to `denix.lib.configurations`.
- `denix.lib.configurations` - [Configurations (flakes) - Introduction](/configurations/introduction).
- `paths = [./hosts ./modules ./rices];` - paths to be recursively imported by Denix. Remove `./rices` if you don't want to use rices.

## Hosts {#hosts}
Create a `hosts` directory, and within it, create a subdirectory with the name of your host, for example, `desktop`.

In this subdirectory, create a `default.nix` file with the following content:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME
}
```

In the same directory, create a `hardware.nix` file:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  homeManagerSystem = "x86_64-linux"; #!!! REPLACEME
  home.home.stateVersion = "24.05"; #!!! REPLACEME

  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux"; #!!! REPLACEME
    system.stateVersion = "24.05"; #!!! REPLACEME

    # nixos-generate-config --show-hardware-config
    # other generated code here...
  };
}
```

The `default.nix` file will be modified later after adding modules and rices, so you can keep it open.

## Rices {#rices}
Skip this section if you do not wish to use rices.

Create a `rices` directory, and within it, create a subdirectory with the name of your rice, for example, `dark`.

In this subdirectory, create a `default.nix` file with the following content:
```nix
{delib, ...}:
delib.rice {
  name = "dark"; #!!! REPLACEME
}
```

## Modules {#modules}
Create a `modules` directory, and within it, create a `config` subdirectory (typically, it contains modules that are not tied to a specific program or service).

It should be mentioned that modules represent your configuration, meaning it's up to your imagination, and you are free to change the modules as you wish.

### Constants {#modules-constants}
In this subdirectory, create a `constants.nix` file with the following content:
```nix
{delib, ...}:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "sjohn"); #!!! REPLACEME
    userfullname = readOnly (strOption "John Smith"); #!!! REPLACEME
    useremail = readOnly (strOption "johnsmith@example.com"); #!!! REPLACEME
  };
}
```

This file is optional, as are any of its options, which are only used by you, but it is strongly recommended as good practice.

### Hosts {#modules-hosts}
Also, create a `hosts.nix` file in this same directory (`modules/config`), and write any example from [Hosts - Examples](/hosts/examples).

For example, we will take ["With the `type` Option"](/hosts/examples#type-option):
```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          type = noDefault (enumOption ["desktop" "server"] null);

          isDesktop = boolOption (config.type == "desktop");
          isServer = boolOption (config.type == "server");
        };
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

If you added an example with new options (`type`, `displays`, etc.) or made your own options, don't forget to add values for these options in the hosts.

In our example, we added the `type` option, so open the `default.nix` file in your host's directory and add the attribute `type` to the `delib.host` function:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  type = "desktop" #!!! REPLACEME (desktop/server)

  # ...
}
```

### Rices {#modules-rices}
Skip this section if you are not using rices.

In the `modules/config` directory, create a `rices.nix` file, and write any example from [Rices - Examples](/rices/examples).

For example, we will take ["Minimally Recommended Rice Module"](/rices/examples#minimally-recommended):
```nix
delib.module {
  name = "rices";

  options = with delib; let
    rice = {
      options = riceSubmoduleOptions;
    };
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.riceNamesAssertions myconfig.rices;
  };
}
```

Also, open the `default.nix` file of your host and add the attribute `rice` to the `delib.host` function:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  rice = "dark" #!!! REPLACEME

  # ...
}
```

### Home Manager {#modules-home-manager}
If you created a [constants module](#modules-constants), just create a `home.nix` file with the following content:
```nix
{delib, ...}:
delib.module {
  name = "home";

  home.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };
  };
}
```

If you did not use the [constants module](#modules-constants), the content of the file will be:
```nix
{delib, ...}:
delib.module {
  name = "home";

  home.always.home = {
    username = "sjohn"; #!!! REPLACEME
    homeDirectory = "/home/sjohn"; #!!! REPLACEME
  };
}
```

### User {#modules-user}
You can also create a `user.nix` file with the configuration of your NixOS user:
```nix
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
```

If you did not use the [constants module](#modules-constants), the content of the file will be:
```nix
{delib, ...}:
delib.module {
  name = "user";

  nixos.always.users = {
    groups.sjohn = {}; #!!! REPLACEME

    users.sjohn = { #!!! REPLACEME
      isNormalUser = true;
      initialPassword = "sjohn"; #!!! REPLACEME
      extraGroups = ["wheel"];
    };
  };
}
```

## Conclusion {#conclusion}
If you have followed the instructions precisely, you will end up with the following configuration directory tree:
```plaintext
hosts
- desktop
  - default.nix
  - hardware.nix
modules
- config
  - constants.nix
  - home.nix
  - hosts.nix
  - rices.nix
  - user.nix
rices
- dark
  - default.nix
flake.nix
```

You can check if everything is set up correctly using the command:
```sh
nix flake check .#
```
