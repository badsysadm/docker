# ADR: профиль сборки acl

## Статус
Принято.

## Решение
- Собирать acl 2.4.0 из upstream release tarball.
- Сохранять утилиты `getfacl`, `setfacl` и `chacl`.
- Собирать и сохранять статическую библиотеку `libacl.a`.
- Собирать и сохранять динамическую библиотеку `libacl.so`.
- Утилиты acl должны линковать зависимости статически, кроме libc.
- Отключить NLS.
- Линковать внешние зависимости статически, libc оставлять динамической.
- Использовать libattr как build/link dependency acl 2.4.0.
- Статически линковать libattr в утилиты и libacl, не оставляя runtime dependency на libattr.so.
- Тесты не запускать.
- Документацию и локали не оставлять в конечном bundle.

## Последствия
- В bundle доступны утилиты управления POSIX ACL, `libacl.a` и `libacl.so`.
- Наличие shared `libacl` не означает, что утилиты acl должны зависеть от неё в runtime.
- Для сборки требуется libattr development package.
- Runtime dependency на libattr.so в конечном bundle не допускается.
- libc и dynamic loader остаются динамическими.
