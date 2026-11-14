# ADR: профиль сборки dpkg

## Статус
Принято.

## Решение
- Собирать dpkg из upstream Git-тега и применять локальные patch-файлы build/PAX.
- Собирать `libdpkg.a` с `-fPIC`; разделяемую `libdpkg.so` не выпускать. В upstream dpkg 1.22.11 отсутствует стабильный ABI `libdpkg`: `configure.ac` намеренно использует `LT_INIT([disable-shared])`, а `DPKG_BUILD_SHARED_LIBS` запрещает `--enable-shared` вне режима `AUTHOR_TESTING`. Режим тестирования авторов не является обязательством совместимости ABI, поэтому для `libdpkg` принимается исключение из общего требования NELL о выпуске `.a` и `.so`.
- Отключать dselect, start-stop-daemon, developer docs и NLS.
- `update-alternatives` оставлять включённым.
- Тесты не запускать, документацию удалять.

## Последствия
- dselect и start-stop-daemon отсутствуют в bundle.
- Локализация и developer documentation отсутствуют.
- Локальные patch-файлы требуют проверки при обновлении upstream.
