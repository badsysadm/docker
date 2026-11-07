# ADR: профиль сборки Buildbot

## Статус
Принято для проверки сборкой.

## Контекст
Существующий `buildbot/Dockerfile` собирал Buildbot `v4.3.0` вместе
с Python 3.14.7 и extra `bundle`. Необходимо перенести профиль
в `nell`, сохранив состав runtime и службу, но соблюдая трехэтапную
структуру `src/dep/bin` и формат `/target`.

## Решение
- Сборка официального тега `v4.3.0` из `buildbot/buildbot`.
- Секция `infra` и стандартные три Dockerfile, `debian/control`, ADR.
- Python 3.14.7 брать из существующего `pkg/dev/python3.14`
  до появления собственного профиля Python в `nell` (см. `docs/TODO.md`).
- Build-dependencies устанавливать посредством `mk-build-deps`.
- На этапе `dep` получать wheels через upstream `master[bundle]`,
  включая Web UI, worker и стандартные плагины из bundle.
- На этапе `bin` устанавливать только локальные wheels через
  `pip install --no-index`, без сборки и запуска тестов.
- Поставлять Python, его стандартную библиотеку, CLI `/usr/bin/buildbot`,
  `coreutils` с алиасом `tail`, `git`, `os-release` и прежний systemd-unit.
- Брать glibc 2.44 из `bin/system/glibc`, OpenSSL и zlib из собственных
  `bin`-образов, а `libbz2`, `libgcc_s`, `libsqlite3`, `libzstd`
  из окружения сборки; `libpthread` из glibc.
- `coreutils` брать из `bin/utils/coreutils`; `git` — из прежнего
  `pkg/utils/git:2.56.0` до создания его `nell`-профиля.
- Сохранить функциональность службы `buildbot.service`, исправив
  опечатку `DinamicUser` на `DynamicUser`.
- Удалить устаревший каталог `buildbot/` после переноса.
- Все артефакты помещать в `/src/target`, финальный образ —
  `FROM scratch` с `COPY --from=build /src/target/ /target/`.
- Для Python runtime и его нативных extensions применяется
  существующее Python-исключение на динамическую линковку.

## Последствия
- Профиль доступен по `make buildbot`.
- Для исполнения под systemd требуются параметры и каталог состояния,
  описанные в `debian/buildbot.service`.
- Состав runtime-библиотек сохранен по предоставленному списку:
  libbz2, libcrypto, libgcc_s, libpthread, libsqlite3, libssl, libz, libzstd.
- Отсутствие отдельных профилей Python и Git остаётся известным
  ограничением, уже покрытым общей задачей миграции `pkg` в `nell`.
- Сборка, запуск и сравнение SHA-256 двух сборок ещё не проверены.

## Ссылки
- https://github.com/buildbot/buildbot/tree/v4.3.0/master
- ../../README.md
- ../../../docs/TODO.md
