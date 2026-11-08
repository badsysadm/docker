# ADR: fsverity-utils with static OpenSSL dependencies

## Статус

Принято для проверки сборкой.

## Контекст

fsverity-utils предоставляет утилиту `fsverity` и библиотеку
`libfsverity`. Правила `nell` требуют выпускать оба варианта
библиотеки: `.a` и `.so`, а сторонние зависимости линковать
статически, оставляя динамической только libc.

## Решение

- Использовать официальный upstream Git-тег `v1.7`.
- Получать исходники на этапе `01_src`.
- Устанавливать build-зависимости через `mk-build-deps` из
  `debian/control` и использовать существующие `bin`-образы
  `nell` для OpenSSL, zlib и zstd на этапе `02_dep`.
- На этапе `03_bin` собирать и устанавливать `fsverity`,
  `libfsverity.a`, `libfsverity.so.0` и симлинк
  `libfsverity.so`, заголовок и pkg-config metadata.
- Не собирать и не запускать тестовые программы, не поставлять
  документацию.
- Сохранить стандартную линковку upstream `fsverity` с
  `libfsverity.a`, не добавлять динамическую зависимость
  на `libfsverity.so`.
- Все сторонние библиотеки, включая libcrypto и её зависимости,
  линковать статически.

## Ограничения

- Наличие `libfsverity.so` не отменяет требование статической
  линковки сторонних зависимостей внутри неё.
- `Static-Built-Using` отражает статически встроенные сторонние
  зависимости из используемых OCI-образов.

## Ссылки

- https://github.com/ebiggers/fsverity-utils/tree/v1.7
- https://github.com/ebiggers/fsverity-utils/blob/v1.7/Makefile
- https://github.com/ebiggers/fsverity-utils/blob/v1.7/README.md
