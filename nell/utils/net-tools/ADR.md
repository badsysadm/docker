# ADR: профиль сборки net-tools

## Статус
Принято.

## Решение
- Собирать net-tools 2.10 из upstream Git-тега `v2.10`.
- Использовать upstream default configuration.
- Оставлять libc динамической для resolver/NSS.
- Устанавливать полный набор бинарных утилит upstream.

## Последствия
- Дополнительные shared runtime-библиотеки не требуются.
- SELinux и NLS в этом профиле не включены.
