# ADR: профиль сборки util-linux

## Статус
Принято.

## Контекст
`liblastlog2` и `pam_lastlog2` включают SQLite статически в разделяемые библиотеки. Debian `libm.a` не собрана с PIC и не может быть встроена в такие библиотеки.

## Решение
- Собирать из официального release archive kernel.org.
- Отключать NLS, asciidoc, Python libmount, systemd, SELinux, cryptsetup и btrfs.
- Оставлять включёнными liblastlog2 и PAM lastlog2.
- Использовать SQLite из профиля NELL; в патче линковки `liblastlog2` и `pam_lastlog2` не указывать `libm.a`.
- Выбранные низкоуровневые утилиты собирать как static programs.
- Тесты не запускать, документацию удалять.

## Последствия
- Отключённые интеграции и bindings отсутствуют в bundle.
- Статические программы не требуют своих обычных shared-зависимостей.
- PAM lastlog2 сохраняет системную интеграцию и соответствующие runtime-требования.
- Debian `libm.a` не включается непосредственно через патч линковки `liblastlog2` и `pam_lastlog2`.

## Рассмотренные альтернативы
Отключение математических SQL-функций SQLite рассматривалось, но не принято.

## Ссылки
- [ADR SQLite](../../lib/sqlite/ADR.md)
- [Патч линковки](debian/patches/_build.patch)
