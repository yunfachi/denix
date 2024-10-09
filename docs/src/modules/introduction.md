# Introduction to Denix Modules {#introduction}
A Denix module is the same as a NixOS or Home Manager module, but its attribute set is wrapped in the [`delib.module`](/modules/structure) function.

## No Limitations {#no-limitations}
This means that you can use all three types of modules simultaneously, although it's unlikely you'll need anything other than the first option:

### Denix Module
```nix
{delib, ...}:
delib.module {
  name = "...";
}
```

### Denix Module with NixOS/Home Manager Module
```nix
{delib, ...}:
delib.module {
  name = "...";
} // {

}
```

### NixOS/Home Manager Module Only
```nix
{

}
```

## Simplicity and Cleanliness {#simplicity-and-cleanliness}
Denix modules tend to look simpler and cleaner compared to NixOS/Home Manager modules, due to the following reasons:

1. Simple yet fully functional option declaration (see [Options](/options/introduction)).
2. Built-in logic for separating configurations based on the value of `${delib.module :: name}.enable`: always, ifEnabled, ifDisabled.
3. Shared options but separated configurations for NixOS, Home Manager, and custom options.
