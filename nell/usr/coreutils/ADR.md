# ADR: профиль сборки coreutils

## Статус
Принято.

## Решение
- Собирать из официального GNU release tarball.
- Использовать single-binary режим с symlink frontend'ами.
- Отключать NLS.
- Не регенерировать autotools-файлы release tarball из-за различий timestamp.
- Тесты не запускать, `/usr/share` удалять из bundle.
