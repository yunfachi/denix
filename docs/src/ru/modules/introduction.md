# Введение в модули Denix {#introduction}
Модуль Denix - это тот же самый модуль NixOS, Home Manager или Nix-Darwin, но его attribute set обёрнут в функцию [`delib.module`](/ru/modules/structure).

## Отсутствие ограничений {#no-limitations}
Это означает, что вы можете использовать все три варианта модулей одновременно, хотя маловероятно, что вам понадобятся другие варианты, кроме первого:

### Denix модуль
```nix
{delib, ...}:
delib.module {
  name = "...";
}
```

### Denix модуль, дополненный NixOS/Home Manager/Nix-Darwin модулем
```nix
{delib, ...}:
delib.module {
  name = "...";
} // {

}
```

### Только NixOS/Home Manager/Nix-Darwin модуль
```nix
{

}
```

## Простота и чистота {#simplicity-and-cleanliness}
Модули Denix в большинстве случаев выглядят проще и чище, чем модули NixOS/Home Manager/Nix-Darwin, по следующим причинам:

1. Простое, но при этом полноценное декларирование опций (см. [Опции](/ru/options/introduction)).
2. Встроенная логика разделения конфигураций в зависимости от значения опции `${delib.module :: name}.enable`: always, ifEnabled, ifDisabled.
3. Общие опции, но разделённые конфигурации для NixOS, Home Manager, Nix-Darwin и собственных опций.
