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

## Ограничения и проверки

- Наличие `libfsverity.so` не отменяет требование статической
  линковки сторонних зависимостей внутри неё.
- В целевой среде проверить `make fsverity-utils`, перечень
  артефактов, экспорт символов, `readelf -d` для исполняемого
  файла и shared library, отсутствие сторонних `DT_NEEDED`,
  кроме libc.
- Проверить работу `fsverity --version`, `fsverity digest`,
  `fsverity sign` и идентичность SHA-256 двух сборок.
- `Static-Built-Using` отражает выбранные OCI-версии;
  фактически встроенные компоненты следует подтвердить
  проверкой линковки.

## Ссылки

- https://github.com/ebiggers/fsverity-utils/tree/v1.7
- https://github.com/ebiggers/fsverity-utils/blob/v1.7/Makefile
- https://github.com/ebiggers/fsverity-utils/blob/v1.7/README.md
