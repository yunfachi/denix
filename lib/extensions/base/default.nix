{ delib, ... }:
delib.extension {
  name = "base";
  description = "Implement feature-rich and fine-tunable modules for hosts and rices with minimal effort";
  maintainers = with delib.maintainers; [ yunfachi ];

  initialConfig = {
    enableAll = true;

    args = {
      enable = false;
      path = "args";
    };

    assertions = {
      enable = true;
      moduleSystem = "home-manager";
    };
  };
}
