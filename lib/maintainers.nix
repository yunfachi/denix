{
  delib,
  lib,
  ...
}:
let
  maintainer =
    {
      name,
      email ? null,
      github ? null,
      githubId ? null,
      telegram ? null,
      telegramId ? null,
    }@args:
    lib.warnIf (!delib.hasAttrs [ "email" "githubId" "telegramId" ] args)
      "Maintainer '${name}' is missing contact info: expected at least one of email, githubId, or telegramId'"
      args;
in
{
  maintainers = {
    yunfachi = maintainer {
      name = "yunfachi";
      github = "yunfachi";
      githubId = 73419713;
      telegram = "yunfachi";
      telegramId = 1349897307;
    };
  };
}
