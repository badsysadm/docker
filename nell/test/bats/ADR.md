# ADR: Единый профиль Bats с библиотеками

## Статус

Принято.

## Контекст

Bats-core и его библиотеки распространяются отдельными upstream-репозиториями.
Для работы тестовых сценариев необходимы исполняемые скрипты Bats, его
внутренние runtime-файлы и доступные по `load` вспомогательные библиотеки.

## Решение

- Использовать один профиль `nell/test/bats` и единый артефакт.
- На `01_src` получать пять официальных Git-репозиториев:
  `bats-core`, `bats-support`, `bats-assert`, `bats-detik`, `bats-file`.
- На `02_dep` устанавливать сборочные зависимости через `mk-build-deps`.
- На `03_bin` устанавливать `bats-core` upstream-скриптом `install.sh`
  и раскладывать runtime-файлы всех четырёх библиотек под
  `/usr/lib/bats/<library>`, сохраняя их внутреннюю структуру.
- Сохранять `/usr/bin/bats`, `/usr/libexec/bats-core` и
  `/usr/lib/bats-core`; не запускать тесты и не поставлять документацию.
- Поставлять всё в едином `FROM scratch` через каталог `/target`.

## Последствия

- Bats загружает библиотеки из стандартного `BATS_LIB_PATH=/usr/lib/bats`.
- `bats-detik` использует собственные `lib/*.bash`; их расположение
  сохраняется.
- Вызываемые `bats-detik` внешние клиенты Kubernetes (kubectl, oc, helm)
  не являются частью этого артефакта.
- Профиль содержит shell-скрипты, без сторонней нативной линковки.

## Ссылки

- https://github.com/bats-core/bats-core
- https://github.com/bats-core/bats-support
- https://github.com/bats-core/bats-assert
- https://github.com/bats-core/bats-detik
- https://github.com/bats-core/bats-file
