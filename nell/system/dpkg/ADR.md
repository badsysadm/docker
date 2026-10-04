# ADR: профиль сборки dpkg

## Статус
Принято.

## Решение
- Собирать dpkg из upstream Git-тега и применять локальные patch-файлы build/PAX.
- Собирать static-библиотеки и отключать shared-библиотеки.
- Отключать dselect, start-stop-daemon, developer docs и NLS.
- `update-alternatives` оставлять включённым.
- Тесты не запускать, документацию удалять.

## Последствия
- dselect и start-stop-daemon отсутствуют в bundle.
- Локализация и developer documentation отсутствуют.
- Локальные patch-файлы требуют проверки при обновлении upstream.
