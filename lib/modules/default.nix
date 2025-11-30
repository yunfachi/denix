{
  delib,
  lib,
  inputs,
  denixModules,
  ...
}:
delib._callLib ./denixArgs.nix
// delib._callLib ./helpers.nix
// delib._callLib ./options.nix
// delib._callLib ./helpers.nix
// {
  denixConfiguration =
    {
      modules ? [ ],
      specialArgs ? { },
      extraInputs ? { },
    }:
    let
      evaledModules = lib.evalModules {
        modules = [ denixModules.default ] ++ modules;

        specialArgs = {
          inputs = inputs // extraInputs;
          # `specialArgs.modulesPath` is used as the base path for `disabledModules`.
          modulesPath = denixModules.default;
        }
        // lib.recursiveUpdate {
          inherit delib;
        } specialArgs;
      };

      withExtraAttrs =
        configuration:
        configuration
        // {
          genModule = args: delib.genModule (delib.strictMergeAttrs { inherit configuration; } args);
          genSystem = args: delib.genSystem (delib.strictMergeAttrs { inherit configuration; } args);
          genModules = args: delib.genModules (delib.strictMergeAttrs { inherit configuration; } args);
          genSystems = args: delib.genSystems (delib.strictMergeAttrs { inherit configuration; } args);

          extendModules = args: withExtraAttrs (configuration.extendModules args);
        };
    in
    withExtraAttrs evaledModules;

  genModule =
    {
      configuration,

      moduleSystem ? null,
      host ? null,
    }:
    let
      configurationWithModules = configuration.extendModules {
        modules = lib.singleton {
          config = {
            inherit moduleSystem host;
          };
        };
      };
    in
    {
      key = "denix.genModule";

      imports = lib.concatLists (
        lib.mapAttrsToList (
          moduleSystemName: rawModules:
          lib.concatMap
            configurationWithModules.config.moduleSystems.${moduleSystemName}.applyConfigForModuleSystem
            rawModules
        ) configurationWithModules.config.rawModules
      );
    };

  genSystem =
    {
      configuration,

      moduleSystem,
      host ? null,

      extraArgs ? { },
      extraModules ? [ ],
    }:
    let
      makeSystem = configuration.config.moduleSystems.${moduleSystem}.makeSystem;
    in
    assert lib.assertMsg (makeSystem != null)
      "The selected module system '${moduleSystem}' does not support making systems. See its 'makeSystem' option.";
    makeSystem {
      inherit extraArgs;
      modules = extraModules ++ [
        (delib.modules.genModule {
          inherit
            configuration
            moduleSystem
            host
            ;
        })
      ];
    };

  genModules =
    {
      configuration,

      moduleSystem ? null,
      host ? null,

      forEachModuleSystem ? false,
      moduleSystems ? builtins.attrNames (
        lib.filterAttrs (_: value: value.flakeOutputs.modules != null) configuration.config.moduleSystems
      ),
      forEachHost ? false,
      hosts ? builtins.attrNames configuration.config.hosts,
    }:
    assert lib.assertMsg (
      forEachModuleSystem != (moduleSystem != null)
    ) "'forEachModuleSystem' must be true or 'moduleSystem' must be set, but not both.";
    assert lib.assertMsg (
      !(forEachHost && host != null)
    ) "'forEachHost' must not be true when 'host' is set.";
    let
      genSingle =
        moduleSystem: configuration: host:
        delib.modules.genModule {
          inherit
            configuration
            moduleSystem
            host
            ;
        };

      processModuleSystems =
        if forEachModuleSystem then
          lib.genAttrs' moduleSystems (moduleSystem: {
            name =
              let
                flakeOutput = configuration.config.moduleSystems.${moduleSystem}.flakeOutputs.modules;
              in
              lib.throwIf (flakeOutput == null)
                "The selected module system '${moduleSystem}' option 'flakeOutputs.modules' cannot be null."
                flakeOutput;
            value = processHosts moduleSystem;
          })
        else
          processHosts moduleSystem;

      processHosts =
        moduleSystem:
        configuration.config.moduleSystems.${moduleSystem}.processHosts {
          inherit
            configuration
            forEachHost
            hosts
            host
            ;
          fn = genSingle moduleSystem;
        };
    in
    processModuleSystems;

  genSystems =
    {
      configuration,

      moduleSystem ? null,
      host ? null,

      forEachModuleSystem ? false,
      moduleSystems ? builtins.attrNames (
        lib.filterAttrs (
          _: value: value.flakeOutputs.systems != null && value.makeSystem != null
        ) configuration.config.moduleSystems
      ),
      forEachHost ? false,
      hosts ? builtins.attrNames configuration.config.hosts,

      extraArgs ? { },
      extraArgsByModuleSystem ? { },
      extraModules ? [ ],
      extraModulesByModuleSystem ? { },
    }:
    assert lib.assertMsg (
      forEachModuleSystem != (moduleSystem != null)
    ) "'forEachModuleSystem' must be true or 'moduleSystem' must be set, but not both.";
    assert lib.assertMsg (
      !(forEachHost && host != null)
    ) "'forEachHost' must not be true when 'host' is set.";
    let
      genSingle =
        moduleSystem: configuration: host:
        delib.modules.genSystem {
          inherit
            configuration
            moduleSystem
            host
            ;
          extraArgs = extraArgs // extraArgsByModuleSystem.${moduleSystem} or { };
          extraModules = extraModules ++ extraModulesByModuleSystem.${moduleSystem} or [ ];
        };

      processModuleSystems =
        if forEachModuleSystem then
          lib.genAttrs' moduleSystems (moduleSystem: {
            name =
              let
                flakeOutput = configuration.config.moduleSystems.${moduleSystem}.flakeOutputs.systems;
              in
              lib.throwIf (flakeOutput == null)
                "The selected module system '${moduleSystem}' option 'flakeOutputs.systems' cannot be null."
                flakeOutput;
            value = processHosts moduleSystem;
          })
        else
          processHosts moduleSystem;

      processHosts =
        moduleSystem:
        configuration.config.moduleSystems.${moduleSystem}.processHosts {
          inherit
            configuration
            forEachHost
            hosts
            host
            ;
          fn = genSingle moduleSystem;
        };
    in
    processModuleSystems;
}
