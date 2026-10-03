# ADR: профиль сборки util-linux

## Статус
Принято.

## Решение
- Собирать из официального release archive kernel.org.
- Отключать NLS, asciidoc, Python libmount, systemd, SELinux, cryptsetup и btrfs.
- Оставлять включёнными liblastlog2 и PAM lastlog2.
- Выбранные низкоуровневые утилиты собирать как static programs.
- Тесты не запускать, документацию удалять.
