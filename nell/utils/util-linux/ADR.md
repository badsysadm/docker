# ADR: профиль сборки util-linux

## Статус
Принято.

## Решение
- Собирать из официального release archive kernel.org.
- Отключать NLS, asciidoc, Python libmount, systemd, SELinux, cryptsetup и btrfs.
- Оставлять включёнными liblastlog2 и PAM lastlog2.
- Выбранные низкоуровневые утилиты собирать как static programs.
- Тесты не запускать, документацию удалять.

## Последствия
- Отключённые интеграции и bindings отсутствуют в bundle.
- Статические программы не требуют своих обычных shared-зависимостей.
- PAM lastlog2 сохраняет системную интеграцию и соответствующие runtime-требования.
