# Introduction to Denix Configurations (Flakes) {#introduction}
The `delib.configurations` function is used to create lists of `nixosConfigurations`, `homeConfigurations`, and `darwinConfigurations` for flakes.

In addition to all hosts, it also adds combinations of each host with every **non-`inheritanceOnly`** rice, which allows for quickly switching between rice configurations without editing the code. For example, if the "desktop" host is set to use the "light" rice, executing the following command:

```sh
nixos-rebuild switch --flake .#desktop --use-remote-sudo
```

will use the "desktop" host with the "light" rice. However, if you need to quickly switch to another rice, for example, "dark" you can run the following command:

```sh
nixos-rebuild switch --flake .#desktop-dark --use-remote-sudo
```

In this case, the host remains "desktop", but the rice changes to "dark".

It is important to note that when switching rice in this way, only the value of the `${myConfigName}.rice` option changes, while the value of `${myConfigName}.hosts.${hostName}.rice` remains the same.

## Principle of Configuration List Generation {#principle}
The configuration list is generated based on the following principle:

- `{hostName}` - where `hostName` is the name of any host.
- `{hostName}-{riceName}` - where `hostName` is the name of any host, and `riceName` is the name of any rice where `inheritanceOnly` is `false`.

If `moduleSystem` from the [function arguments](/configurations/structure#function-arguments) is set to `home`, then a prefix of `{homeManagerUser}@` is added to all configurations in the list.

## Example {#example}
An example of a flake's `outputs` for `nixosConfigurations`, `homeConfigurations`, and `darwinConfigurations`:

```nix
outputs = {denix, nixpkgs, ...} @ inputs: let
  mkConfigurations = moduleSystem:
    denix.lib.configurations rec {
      inherit moduleSystem;
      homeManagerUser = "sjohn";

      paths = [./hosts ./modules ./rices];

      specialArgs = {
        inherit inputs moduleSystem homeManagerUser;
      };
    };
in {
  nixosConfigurations = mkConfigurations "nixos";
  homeConfigurations = mkConfigurations "home";
  darwinConfigurations = mkConfigurations "darwin";
}
```

## Using multiple channels {#multiple-channels}
To conveniently work with multiple channels in the configuration, the `delib.configurations` function accepts the arguments `nixpkgs`, `home-manager`, and `nix-darwin`, which are used in the generated configurations.

**By default, there is no need to specify these arguments** - they default to the corresponding values from the Denix flake's `inputs`. These can also be overridden via `inputs.denix.inputs.<input>.follows`, which is more convenient for users who rely on a single channel.

Therefore:
- `delib.configurations :: [nixpkgs, home-manager, nix-darwin]` - for those who need multiple channels.
- `inputs.denix.<nixpkgs|home-manager|nix-darwin>.follows` - for those who only need a single channel.

Based on this, several usage options are possible:

1. Override `nixpkgs`, `home-manager`, and `nix-darwin` via the arguments of the `delib.configurations` function for both "stable" and "unstable" channels used in `./hosts/stable` and `./hosts/unstable`, respectively. Note that the implementation of the `mkConfigurations` function can vary - this is just an example.
```nix
{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-darwin-unstable = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin-stable = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    denix.url = "github:yunfachi/denix";
  };

  outputs = {
    denix,
    nixpkgs-unstable,
    nixpkgs-stable,
    home-manager-unstable,
    home-manager-stable,
    nix-darwin-unstable,
    nix-darwin-stable,
    ...
  } @ inputs: let
    _mkConfigurations = nixpkgs: home-manager: nix-darwin: hosts: moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem nixpkgs home-manager nix-darwin;
        homeManagerUser = "sjohn";

        paths = [./modules ./rices] ++ hosts;

        specialArgs = {
          inherit inputs;
        };
      };

    mkConfigurations = moduleSystem:
      nixpkgs-unstable.lib.attrsets.mergeAttrsList 
      (map (f: f moduleSystem) [
        (_mkConfigurations nixpkgs-stable home-manager-stable nix-darwin-stable [./hosts/stable])
        (_mkConfigurations nixpkgs-unstable home-manager-unstable nix-darwin-unstable [./hosts/unstable])
      ]);
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```

2. Override `nixpkgs`, `home-manager`, and `nix-darwin` using `inputs.denix.inputs.<name>.follows`. This is the recommended method for those using a single channel.
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-darwin.follows = "nix-darwin";
    };
  };

  outputs = {denix, ...} @ inputs: let
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "sjohn";

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```

3. Do not override anything. Also suitable for single-channel use, though less recommended.
```nix
{
  inputs = {
    denix.url = "github:yunfachi/denix";
  };

  outputs = {denix, ...} @ inputs: let
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "sjohn";

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```
