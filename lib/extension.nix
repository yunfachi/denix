{
  delib,
  lib,
  ...
}:
let
  pretty =
    value:
    (lib.generators.toPretty { } (
      lib.generators.withRecursion {
        depthLimit = 10;
        throwOnDepthLimit = false;
      } value
    ));
  toExtensionWithConfig =
    f:
    if lib.isFunction f then
      config: final: prev:
      let
        fConfig = f config;
      in
      if lib.isFunction fConfig then
        let
          fConfigPrev = f config prev;
        in
        if lib.isFunction fConfigPrev then
          # f is (config: final: prev: { ... })
          f config final prev
        else
          # f is (config: prev: { ... })
          fConfigPrev
      else
        # f is (config: { ... })
        fConfig
    else
      # f is not a function; probably { ... }
      config: final: prev:
      f;
in
{
  extension =
    {
      # Meta
      name,
      description ? null,
      maintainers ? [ ],
      # Extension
      config ? final: prev: { },
      initialConfig ? null,
      configOrder ? 0, # Used in mergeExtensions. Lower values mean earlier execution.
      # Configuration
      libExtension ?
        config: final: prev:
        { },
      libExtensionOrder ? 0, # Used in mergeExtensions. Lower values mean earlier execution.
      modules ? config: [ ],
    }:
    let
      _initialConfig = initialConfig;
      f =
        _config:
        let
          config = lib.toExtension _config;
          initialConfig =
            if _initialConfig == null || lib.isFunction _initialConfig then
              _initialConfig
            else
              _: _initialConfig;
          fixedConfig = delib.fix (
            delib.recursivelyExtends config (if initialConfig != null then initialConfig else _: { })
          );
        in
        {
          inherit
            name
            description
            maintainers
            initialConfig
            configOrder
            libExtensionOrder
            ;

          libExtension = (toExtensionWithConfig libExtension) fixedConfig;
          modules = if lib.isFunction modules then modules fixedConfig else modules;

          __unfix__ = f;
          __unfixConfig__ = config;
          config = fixedConfig;
          withConfig =
            configOverlay: f (delib.recursivelyComposeExtensions config (lib.toExtension configOverlay));
        };
    in
    f config;

  extensions = delib.callExtensions { paths = [ ./extensions ]; };

  callExtension = file: delib._callLib file // { _file = file; };

  callExtensions =
    {
      # Umport
      paths ? [ ],
      exclude ? [ ],
      recursive ? true,
    }:
    let
      allExtensions = map delib.callExtension (delib.umport { inherit paths exclude recursive; });
      groupedByName = builtins.groupBy (extension: extension.name) allExtensions;
    in
    lib.mapAttrs delib.mergeExtensions groupedByName;

  withExtensions = lib.foldl (acc: extension: acc.recursivelyExtend extension.libExtension) delib;

  mergeExtensions =
    name: extensions:
    let
      totalExtensions = builtins.length extensions;
    in
    if totalExtensions == 0 then
      delib.extension { inherit name; }
    else if totalExtensions == 1 then
      builtins.removeAttrs (builtins.elemAt extensions 0) [ "_file" ]
    else
      let
        config =
          let
            sorted = builtins.sort (q: p: q.configOrder < p.configOrder) extensions;
            configs = builtins.map (x: x.__unfixConfig__) sorted;
          in
          delib.recursivelyComposeManyExtensions configs;
      in
      delib.extension {
        inherit name;
        description =
          let
            withDescription = builtins.filter (extension: extension.description != null) extensions;
            withUniqueDescription = lib.foldl' (
              acc: e:
              if builtins.any (extension: e.description == extension.description) acc then acc else acc ++ [ e ]
            ) [ ] withDescription;
            totalUnique = builtins.length withUniqueDescription;
          in
          if totalUnique == 0 then
            null
          else if totalUnique == 1 then
            (builtins.head withDescription).description
          else
            lib.warn (
              "Denix extension with the name '${name}' has conflicting 'description' values:\n"
              + (lib.concatMapStringsSep "\n" (
                extension: "- ${extension._file or extension.name}: ${pretty extension.description}"
              ) withDescription)
            ) null;

        inherit config;
        initialConfig =
          let
            withInitialConfig = builtins.filter (extension: extension.initialConfig != null) extensions;
            total = builtins.length withInitialConfig;
          in
          if total == 0 then
            null
          else if total == 1 then
            (builtins.head withInitialConfig).initialConfig
          else
            lib.warn (
              "Denix extension with the name '${name}' has conflicting 'initialConfig' values:\n"
              + (lib.concatMapStringsSep "\n" (
                extension: "- ${extension._file or extension.name}: ${pretty extension.initialConfig}"
              ) withInitialConfig)
            ) null;

        maintainers = lib.unique (builtins.concatMap (extension: extension.maintainers) extensions);

        libExtension =
          let
            sorted = builtins.sort (q: p: q.libExtensionOrder < p.libExtensionOrder) extensions;
            libExtensions = config: builtins.map (extension: (extension.__unfix__ config).libExtension) sorted;
          in
          config: delib.recursivelyComposeManyExtensions (libExtensions config);
        modules = config: builtins.concatMap (extension: (extension.__unfix__ config).modules) extensions;
      };
}
