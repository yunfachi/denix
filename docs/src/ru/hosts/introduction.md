# Введение в хосты Denix {#introduction}
Хост (host) Denix - это attribute set, возвращаемый функцией [`delib.host`](/ru/hosts/structure), который включает или отключает определенные конфигурации в зависимости от значения опции `${myconfigName}.host`. Также он передает входящий `attribute set` в функцию `delib.host` в опцию `${myconfigName}.hosts.${delib.host :: name}`.

Простыми словами, это позволяет разделить конфигурацию NixOS, Home Manager и собственных опций на те, которые применяются только к текущему хосту, и те, которые применяются ко всем хостам. Например, первое может использоваться для включения или отключения определенных программ, а второе - для добавления SSH-ключа текущего хоста в `authorizedKeys` всех хостов.

Хост также можно сравнить с модулем, потому что все хосты импортируются независимо от того, какой из них активен, но применяемые конфигурации зависят от активного хоста.

## Опции {#options}
Для работы хостов конфигурация должна включать опции `${myconfigName}.host` и `${myconfigName}.hosts`, которые **вы задаете самостоятельно** в одном из модулей.

Пример минимальной рекомендуемой конфигурации хостов:

```nix
delib.module {
  name = "hosts";

  options = with delib; let
    host = {
      options = hostSubmoduleOptions;
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

Другие примеры можно найти в разделе [Примеры](/ru/hosts/examples).
