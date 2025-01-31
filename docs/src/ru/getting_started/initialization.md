# Инициализация конфигурации {#initialization}
В этом разделе будет описано создание шаблона `minimal` с нуля.

Делать это необязательно, можно просто склонировать шаблон минимальной конфигурации с помощью команды:
```sh
nix flake init -t github:yunfachi/denix#minimal
```

Также можно скопировать шаблон минимальной конфигурации, но без райсов:
```sh
nix flake init -t github:yunfachi/denix#minimal-no-rices
```

## Флейк {#flake}
Первым делом создайте директорию под вашу конфигурацию и файл `flake.nix` со следующим содержанием:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    denix,
    nixpkgs,
    ...
  } @ inputs: let
    mkConfigurations = isHomeManager:
      denix.lib.configurations {
        homeManagerNixpkgs = nixpkgs;
        homeManagerUser = "sjohn"; #!!! REPLACEME
        inherit isHomeManager;

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations false;
    homeConfigurations = mkConfigurations true;
  };
}
```

Если вы не знаете про `inputs` и `outputs`, то прочитайте [NixOS Wiki Flakes](https://nixos.wiki/wiki/Flakes).

Объяснение кода:
- `mkConfigurations` - функция для сокращения кода, которая принимает `isHomeManager` и передает его в `denix.lib.configurations`.
- `denix.lib.configurations` - [Конфигурации (флейки) - Вступление](/ru/configurations/introduction).
- `paths = [./hosts ./modules ./rices];` - пути, которые будут рекурсивно импортированы Denix. Удалите `./rices`, если не хотите использовать райсы.

## Хосты {#hosts}
Создайте директорию `hosts`, а в ней поддиректорию с названием вашего хоста, например, `desktop`.

В этой поддиректории создайте файл `default.nix` со следующим содержанием:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME
}
```

В этой же директории создайте файл `hardware.nix`:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  homeManagerSystem = "x86_64-linux"; #!!! REPLACEME
  home.home.stateVersion = "24.05"; #!!! REPLACEME

  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux"; #!!! REPLACEME
    system.stateVersion = "24.05"; #!!! REPLACEME

    # nixos-generate-config --show-hardware-config
    # остальной сгенерированный код здесь...
  };
}
```

Файл `default.nix` ещё будет изменяться после добавления модулей и райсов, поэтому его можно не закрывать.

## Райсы {#rices}
Пропустите этот пункт, если не хотите использовать райсы.

Создайте директорию `rices`, а в ней поддиректорию с названием вашего райса, например, `dark`.

В этой поддиректории создайте файл `default.nix` со следующим содержанием:
```nix
{delib, ...}:
delib.rice {
  name = "dark"; #!!! REPLACEME
}
```

## Модули {#modules}
Создайте директорию `modules`, а в ней поддиректорию `config` (обычно в ней находятся модули, которые не привязаны к какой-то программе или сервису).

Стоит упомянуть, что модули - это ваша конфигурация, а значит ваша фантазия, поэтому вы вольны менять модули так, как вам угодно.

### Константы {#modules-constants}
В этой поддиректории создайте файл `constants.nix` со следующим содержанием:
```nix
{delib, ...}:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "sjohn"); #!!! REPLACEME
    userfullname = readOnly (strOption "John Smith"); #!!! REPLACEME
    useremail = readOnly (strOption "johnsmith@example.com"); #!!! REPLACEME
  };
}
```

Этот файл необязателен, так же как и любая из его опций, которые используются лишь вами, но он настоятельно рекомендуется как хорошая практика.

### Хосты {#modules-hosts}
Также создайте файл `hosts.nix` в этой же директории (`modules/config`), а в него запишите любой пример из [Хосты - Примеры](/ru/hosts/examples).

Для примера мы возьмём ["С опцией `type`"](/ru/hosts/examples#type-option):
```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          type = noDefault (enumOption ["desktop" "server"] null);

          isDesktop = boolOption (config.type == "desktop");
          isServer = boolOption (config.type == "server");
        };
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

Если вы добавили пример с новыми опциями (`type`, `displays` и т.д.) или сами сделали свои опции, то не забудьте добавить значения этим опциям в самих хостах.

В нашем примере мы добавили опцию `type`, поэтому откройте файл `default.nix` в директории вашего хоста и в функцию `delib.host` добавляем атрибут `type`:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  type = "desktop" #!!! REPLACEME (desktop/server)

  # ...
}
```

### Райсы {#modules-rices}
Пропустите этой пункт, если вы не используете райсы.

В директории `modules/config` создайте файл `rices.nix`, а в него запишите любой пример из [Райсы - Примеры](/ru/rices/examples).

Для примера возьмём ["Минимально рекомендуемый модуль райсов"](/ru/rices/examples#minimally-recommended):
```nix
delib.module {
  name = "rices";

  options = with delib; let
    rice = {
      options = riceSubmoduleOptions;
    };
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.riceNamesAssertions myconfig.rices;
  };
}
```

Также откройте файл `default.nix` вашего хоста и добавьте в функцию `delib.host` атрибут `rice`:
```nix
{delib, ...}:
delib.host {
  name = "desktop"; #!!! REPLACEME

  rice = "dark" #!!! REPLACEME

  # ...
}
```

### Home Manager {#modules-home-manager}
Если вы создали [модуль констант](#modules-constants), то просто создайте файл `home.nix` с таким содержанием:
```nix
{delib, ...}:
delib.module {
  name = "home";

  home.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };
  };
}
```

Если вы не использовали [модуль констант](#modules-constants), то содержание файла будет таким:
```nix
{delib, ...}:
delib.module {
  name = "home";

  home.always.home = {
    username = "sjohn"; #!!! REPLACEME
    homeDirectory = "/home/sjohn"; #!!! REPLACEME
  };
}
```

### Пользователь {#modules-user}
Также можно создать файл `user.nix` с конфигурацией вашего пользователя NixOS:
```nix
{delib, ...}:
delib.module {
  name = "user";

  nixos.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    users = {
      groups.${username} = {};

      users.${username} = {
        isNormalUser = true;
        initialPassword = username;
        extraGroups = ["wheel"];
      };
    };
  };
}
```

Если вы не использовали [модуль констант](#modules-constants), то содержание файла будет таким:
```nix
{delib, ...}:
delib.module {
  name = "user";

  nixos.always.users = {
    groups.sjohn = {}; #!!! REPLACEME

    users.sjohn = { #!!! REPLACEME
      isNormalUser = true;
      initialPassword = "sjohn"; #!!! REPLACEME
      extraGroups = ["wheel"];
    };
  };
}
```

## Заключение {#conclusion}
Если вы чётко следовали инструкции, то в итоге у вас будет следующее дерево директории конфигурации:
```plaintext
hosts
- desktop
  - default.nix
  - hardware.nix
modules
- config
  - constants.nix
  - home.nix
  - hosts.nix
  - rices.nix
  - user.nix
rices
- dark
  - default.nix
flake.nix
```

Вы можете проверить, правильно ли всё сделали, с помощью команды:
```sh
nix flake check .#
```
