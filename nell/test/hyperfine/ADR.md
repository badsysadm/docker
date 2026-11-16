# ADR: Генерация shell completions для Hyperfine

## Решение

Сохранять shell completions, которые upstream `build.rs` генерирует при
компиляции. Для этого задавать `SHELL_COMPLETIONS_DIR` и устанавливать
полученные файлы в `/usr/share/hyperfine/completions`.

## Обоснование

Обычно `build.rs` записывает completions во внутренний `OUT_DIR`, который
не попадает в конечный артефакт. Явный каталог позволяет включить их
в поставку без отдельного запуска генератора.

## Ссылка

- https://github.com/sharkdp/hyperfine/blob/v2.0.0/build.rs
