# ADR: профиль сборки dump

## Статус
Принято.

## Решение
- Собирать dump 0.4b56 из upstream release tarball.
- Линковать внешние зависимости статически, libc оставлять динамической.
- Сохранять поддержку readline, QFA, blkid, UUID, zlib, bzip2, LZO и SELinux.
- Собирать `rmt`.
- Не включать SQLite indexing и `ermt`/OpenSSL.

## Последствия
- `dump`, `restore` и `rmt` не требуют shared-библиотек проекта и сторонних библиотек.
- NSS-функции libc остаются доступны через динамическую libc.
- SQLite indexing и encrypted `ermt` отсутствуют.
