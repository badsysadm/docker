# ADR: профиль сборки findutils

## Статус
Принято.

## Решение
- Собирать из официального GNU release tarball.
- Отключать NLS.
- Использовать текущий layout `/usr`, `/etc`, `/var`, `/sbin`, `/usr/lib64`.
- Тесты не запускать, man/info удалять.
