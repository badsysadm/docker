# ADR: профиль сборки elfutils

## Статус
Принято.

## Решение
- Собирать elfutils 0.196 из upstream release tarball.
- Сохранять основные ELF/DWARF utilities и библиотеки.
- Не включать debuginfod/libdebuginfod и libarchive.
- Линковать внешние зависимости статически, libc оставлять динамической.

## Последствия
- Bundle содержит утилиты elfutils и пригодный для статической линковки libelf.
- debuginfod и libarchive integration отсутствуют.
