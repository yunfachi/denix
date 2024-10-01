# Introduction to Denix Configurations (Flakes) {#introduction}
The `delib.configurations` function is used to create lists of `nixosConfigurations` and `homeConfigurations` for flakes.

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

If `isHomeManager` from the [function arguments](/configurations/structure#function-arguments) is equal to `true`, then a prefix of `{homeManagerUser}@` is added to all configurations in the list.

## Example {#example}
An example of a flake's `outputs` for `nixosConfigurations` and `homeConfigurations`:

```nix
outputs = {denix, nixpkgs, ...} @ inputs: let
  mkConfigurations = isHomeManager:
    denix.lib.configurations rec {
      homeManagerNixpkgs = nixpkgs;
      homeManagerUser = "sjohn";
      inherit isHomeManager;

      paths = [./hosts ./modules ./rices];

      specialArgs = {
        inherit inputs isHomeManager homeManagerUser;
      };
    };
in {
  nixosConfigurations = mkConfigurations false;
  homeConfigurations = mkConfigurations true;
}
```
