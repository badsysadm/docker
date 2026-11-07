# ADR: профиль сборки Matrix Synapse

## Статус
Принято для проверки сборкой.

## Контекст
Synapse — Python homeserver протокола Matrix с нативным Rust-расширением,
собираемым через maturin. Версия 1.164.2 требует Rust >= 1.85.
Референсы в nell: `www/radicale` для Python и `infra/lldap` для Rust.

## Решение
- Получать официальные исходники из `element-hq/synapse` по тегу версии.
- Использовать Python 3.14.7 из существующего `pkg/dev/python3.14`.
- Использовать `mk-build-deps` и Debian `debian/control` для системных
  build-зависимостей, включая PostgreSQL и ICU.
- Устанавливать Rust 1.89.0 через rustup с `--profile minimal`,
  по образцу `infra/lldap`, без зависимости от Debian `rustc` и `cargo`.
- Выполнять `cargo vendor --locked` и использовать `CARGO_NET_OFFLINE=true`
  при создании wheel, чтобы Rust-зависимости разрешались из vendored исходников.
- На этапе `dep` собирать wheels из upstream с PostgreSQL extra.
  Maturin собирает Rust-расширение в wheel.
- На этапе `bin` устанавливать Python-зависимости только из подготовленных
  wheels, без сетевого доступа.
- Упаковывать интерпретатор, стандартную библиотеку, wheels и CLI в `/target`.
- Следовать Python-исключению Radicale: Python runtime и его нативные
  расширения используют динамические библиотеки; glibc берётся из
  `pkg/libs/glibc`, OpenSSL и zlib — из существующих образов.
- Не включать тесты, документацию, systemd-юниты или конфигурацию
  развёртывания в финальный образ.

## Последствия
- Профиль содержит поддержку PostgreSQL; он не включает сам сервер БД.
- Требуется проверить достаточность динамических зависимостей Python,
  Rust-расширения и `libpq` в конечном `/target`.
- Версия Rust закреплена в профиле; при обновлении Synapse необходимо
  проверять совместимость с upstream `rust/Cargo.toml` и `Cargo.lock`.
- Сборка через `make synapse`, содержимое `/target` и совпадение SHA-256
  двух последовательных сборок не проверены.

## Ссылки
- https://github.com/element-hq/synapse
- https://github.com/element-hq/synapse/blob/v1.164.2/pyproject.toml
- ../radicale/ADR.md
- ../../infra/lldap/ADR.md
- ../../../README.md
