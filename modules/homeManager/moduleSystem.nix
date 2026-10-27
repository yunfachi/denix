{
  inputs,
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.settings.homeManager;
in
{
  moduleSystems.home =
    { name, ... }:
    {
      makeSystem =
        { modules, extraArgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration (
          {
            inherit modules;
            pkgs = inputs.home-manager.inputs.nixpkgs.legacyPackages.${cfg.standalone.system};
          }
          // extraArgs
        );

      processHosts =
        {
          configuration,
          forEachHost,
          hosts,
          host,
          fn,
        }:
        if forEachHost then
          let
            baseHosts = lib.genAttrs (lib.filter (
              host: configuration.config.hosts.${host}.standaloneHomeManager.user != null
            ) hosts) (fn configuration);

            hostsForEachUser = lib.foldl' delib.strictMergeAttrs { } (
              map (
                host:
                lib.genAttrs' configuration.config.hosts.${host}.standaloneHomeManager.users (user: {
                  name = "${user}@${host}";
                  value = fn (configuration.extendModules {
                    modules = [ { hosts.${host}.standaloneHomeManager.user = lib.mkDefault user; } ];
                  }) host;
                })
              ) hosts
            );
          in
          delib.strictMergeAttrs baseHosts hostsForEachUser
        else
          fn configuration host;

      applyConfigForModuleSystem =
        value:
        lib.optionals (config.moduleSystem.name or null == name) (
          builtins.concatMap (moduleSystem: lib.optional (moduleSystem == name) value) cfg.shared
          ++ lib.optionals (cfg.standalone.user != null) (
            builtins.concatMap (
              moduleSystem: lib.optional (moduleSystem == name) value
            ) cfg.users.${cfg.standalone.user}
          )
        )
        ++ lib.optional (config.moduleSystem.name or null == "nixos") {
          home-manager.sharedModules = builtins.concatMap (
            moduleSystem: lib.optional (moduleSystem == name) value
          ) cfg.shared;
          home-manager.users = lib.mapAttrs (
            user: moduleSystems: lib.optionalAttrs (builtins.elem name moduleSystems) value
          ) cfg.users;
        };
    };
}
