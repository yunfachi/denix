{
  description = "Denix extensions collection";

  inputs.denix.url = "github:yunfachi/denix";

  outputs =
    { denix, ... }:
    {
      denixExtensions = denix.lib.callExtensions {
        paths = [ ./extensions ];
      };
    };
}
