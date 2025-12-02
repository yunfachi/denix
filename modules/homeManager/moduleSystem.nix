{
  inputs,
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.homeManager;
in
{
  moduleSystems.home = {
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
                name = "${host}@${user}";
                value = fn (configuration.extendModules {
                  modules = [ { hosts.${host}.standaloneHomeManager.user = lib.mkVMOverride user; } ];
                }) host;
              })
            ) hosts
          );
        in
        delib.strictMergeAttrs baseHosts hostsForEachUser
      else
        fn configuration host;
  };
}
