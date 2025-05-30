# Перенос на Denix {#transfer-to-denix}
Если у вас уже есть конфигурация NixOS, Home Manager или Nix-Darwin, вы можете перенести большинство кода без значительных изменений, а затем адаптировать его под Denix.

Однако, вам потребуется создать с нуля:
- Хосты
- Райсы (если хотите)
- Некоторые начальные модули

Основную часть конфигурации можно полностью использовать из вашей старой конфигурации, главное - отделить аппаратные настройки (hardware configuration) от общей конфигурации. См. раздел [Как это работает?](#how-it-works).

## Как это работает? {#how-it-works}
Все модули Denix представляют собой обычные модули NixOS, Home Manager или Nix-Darwin, но с дополнительной логикой включения и выключения конфигураций.

Это означает, что вы можете добавить код или файлы из старой конфигурации в новую, чтобы они импортировались через [`delib.configurations`](/ru/configurations/introduction). Вы можете положить этот код в директорию `modules` или создать новую директорию, например, `modules_nixos_old` для старых конфигураций.

## Пример простой конфигурации {#example-of-simple-configuration}
Допустим, у вас есть старая конфигурация, состоящая из двух файлов: `configuration.nix` и `hardware-configuration.nix`, и вы уже создали хосты и директорию `modules/config` по инструкции. Конфигурация вашего хоста должна включать `hardware-configuration.nix`, поэтому остаётся лишь скопировать `configuration.nix` в директорию `modules` и удалить из неё ненужные опции, например, `system.stateVersion`.

## Пример сложной конфигурации {#example-of-complex-configuration}
Допустим, у вас есть старая конфигурация с хостами и множеством модулей, разделённых на файлы. Хосты, как правило, специфичны для вашей системы, поэтому их нужно будет перенести вручную, чаще всего просто скопировав код.

Модули (например, для программ и сервисов) можно просто скопировать в директорию `modules` или другие файлы, импортируемые через [`delib.configurations`](/ru/configurations/introduction).
