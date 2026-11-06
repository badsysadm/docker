# ADR: профиль сборки binutils

## Статус
Принято.

## Решение
- Собирать binutils 2.47 из upstream release tarball.
- Сохранять assembler, linker, binary utilities и gprofng.
- Собирать внутренние библиотеки статически.
- Сохранять поддержку zlib, zstd и jansson со статической линковкой.
- Отключить NLS.

## Последствия
- В bundle доступны стандартные GNU binutils и gprofng.
- Внешние библиотеки zlib, zstd и jansson не требуются в runtime.
- libc и связанные системные библиотеки остаются динамическими.
