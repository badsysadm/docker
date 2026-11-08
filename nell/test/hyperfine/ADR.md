# ADR: Hyperfine with offline Rust dependencies

## Статус

Принято для проверки сборкой.

## Контекст

Hyperfine — CLI-программа на Rust. Для воспроизводимой сборки необходимо
разделить загрузку Rust-зависимостей и финальную компиляцию, оставив
динамической только libc.

## Решение

- Брать исходники официального тега `v2.0.0` из GitHub.
- Использовать Rust 1.97.0 согласно `rust-version` upstream.
- Устанавливать toolchain и создавать `cargo vendor --locked` только
  на этапе `02_dep`, по аналогии с `nell/infra/lldap`.
- На этапе `03_bin` выполнять `cargo build --offline --locked --release`
  без сборки и запуска тестов.
- Сохранять генерируемые upstream shell completions в
  `/usr/share/hyperfine/completions`; не включать документацию.
- Устанавливать `hyperfine` в `/usr/bin` и поставлять только
  содержимое `/target` в образе `FROM scratch`.

## Ограничения

- Вспомогательный `build.rs` генерирует shell completion при сборке;
  их отсутствие означало бы неполную поставку.
- Программа вызывает переданные пользователем внешние команды, которые
  не включаются в конечный образ.
- Упаковка vendored crates не означает их учёта
  как Debian source packages в `Static-Built-Using`.

## Ссылки

- https://github.com/sharkdp/hyperfine/tree/v2.0.0
- https://github.com/sharkdp/hyperfine/blob/v2.0.0/Cargo.toml
- https://github.com/sharkdp/hyperfine/blob/v2.0.0/build.rs
