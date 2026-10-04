# ADR: профиль сборки strace

## Статус
Принято.

## Решение
- Собирать strace 7.2 из официального upstream release tarball.
- Сохранять рабочий профиль сборки из `bootstrap/debian/strace.Dockerfile`.
- Использовать layout `/usr`, `/etc`, `/var`, `/sbin`, `/usr/lib64`.
- Отключать mpers: `--disable-mpers`.
- Отключать libdw: `--without-libdw`.
- Тесты не запускать.
- Удалять man, info и doc из конечного bundle.

## Последствия
- Поддержка mpers отсутствует.
- Интеграция с libdw отсутствует.
- Дополнительные shared runtime-зависимости из libdw не требуются.
- Документация в конечном bundle отсутствует.
