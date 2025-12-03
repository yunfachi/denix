inputName: url:
builtins.throw ''
  This flake input is disabled by default to avoid pulling extra dependencies.
  Since it is only required by an optional Denix module, you must explicitly
  add this input to your flake.nix and override it in Denix:

    inputs.${inputName}.url = "${url}";
    inputs.denix.inputs.${inputName}.follows = "${inputName}";
''
