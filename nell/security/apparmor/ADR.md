# ADR: профиль сборки AppArmor

## Статус
Принято.

## Решение
- Собирать `libapparmor`, `apparmor_parser`, `binutils`, `profiles` и systemd-интеграцию.
- Сохранять публичную `libapparmor.so` для программ, использующих AppArmor API.
- Собирать `libapparmor.a` для статической линковки собственных бинарных утилит.
- Не включать Python, Perl и Ruby bindings.
- Не включать Python-утилиты из `utils`.
- Не собирать PAM и Apache changehat modules.

## Последствия
- `apparmor_parser` и бинарные утилиты используют статическую `libapparmor`.
- `libapparmor.so` остаётся доступной сторонним потребителям AppArmor API.
- Утилиты `aa-enforce`, `aa-complain`, `aa-logprof` и другие Python-инструменты отсутствуют.
- PAM и Apache changehat integration отсутствует.
