# docker

Сборка модулей из исходников выполняется через Kaniko. Основные модули находятся в `nell/`.

## Структура модуля

```text
nell/<section>/<module>/
├── 01_src.Dockerfile
├── 02_dep.Dockerfile
├── 03_bin.Dockerfile
├── ADR.md
└── debian/control
```

- `01_src.Dockerfile` — получает исходники и формирует `src`-образ.
- `02_dep.Dockerfile` — добавляет build-зависимости и формирует `dep`-образ.
- `03_bin.Dockerfile` — собирает конечные артефакты в `/target`.
- `ADR.md` — фиксирует принятый профиль сборки и его последствия.

Правила оформления и компиляции описаны в [nell/README.md](nell/README.md).

## Регистрация в Makefile

Модуль регистрируется в корневом `Makefile` через section и version:

```make
nftables: section = net
nftables: version ?= 1.1.7
```

После этого полная сборка запускается:

```bash
make nftables
```

Версию можно переопределить:

```bash
make nftables version=1.1.8
```

## Как работает полная сборка

`make <module>` выполняет:

1. Проверяет наличие `src/<section>/<module>:<version>` в registry. Если образа нет — собирает `01_src.Dockerfile` и публикует его.
2. Проверяет наличие `dep/<section>/<module>:<version>`. Если образа нет — собирает `02_dep.Dockerfile` и публикует его.
3. Собирает `03_bin.Dockerfile`.
4. Считает SHA-256 всех полученных файлов.
5. Повторно собирает `03_bin.Dockerfile` и сравнивает SHA-256 для проверки воспроизводимости.

`03_bin` автоматически в registry не публикуется.

## Ручной дебаг

Любой этап можно запустить отдельно:

```bash
make nell/net/nftables/03_bin.Dockerfile version=1.1.7
```

Makefile подготовит Kaniko rootfs и запустит Dockerfile через `systemd-run` с его каталогом в качестве build context.

Результат `03_bin` после сборки доступен в:

```text
.build/rootfs/target/
```

Например, проверить динамические зависимости:

```bash
readelf -d .build/rootfs/target/usr/sbin/nft
```

При проблемах со сборкой удобнее запускать отдельно `01_src`, `02_dep` или `03_bin`, передавая нужную версию через `version=...`.
