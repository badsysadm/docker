# ADR: профиль сборки util-linux

## Статус
Принято.

## Контекст
`liblastlog2` и `pam_lastlog2` включают SQLite статически в разделяемые библиотеки. Debian `libm.a` не собрана с PIC и не может быть встроена в такие библиотеки.

## Решение
- Собирать из официального release archive kernel.org.
- Отключать NLS, asciidoc, Python libmount, systemd, udev, SELinux, cryptsetup и btrfs.
- Оставлять включёнными liblastlog2 и PAM lastlog2.
- Использовать SQLite из профиля NELL с отключёнными математическими SQL-функциями (`--disable-math`); при линковке `liblastlog2` и `pam_lastlog2` не подключать `libm.a`.
- Выбранные низкоуровневые утилиты собирать как static programs.
- Для `setpriv` статически подключать libcap-ng из профиля NELL, а для `sulogin` и `newgrp` — libcrypt.a из Debian. Динамические libm и интерфейс PAM сохранять из-за принятых особенностей их использования.
- Пакетировать отдельно util-linux-login (Provides: login; вход в систему и история сеансов), agetty, swap, disk (разметка, проверка файловых систем и блочные устройства), util-linux-su (Provides: su; su, runuser и sulogin), mount (монтаж и переключение корня), ns (nsenter, unshare, lsns и pivot_root), uuid (генерация и разбор UUID), hardware (аппаратные часы, CPU, память, IRQ и устройства), whereis и инструменты управления процессами, оставляя остальные утилиты в базовом пакете.
- Тесты не запускать, документацию удалять.

## Последствия
- Отключённые интеграции и bindings отсутствуют в bundle; `lsblk` и `findmnt` используют резервное получение метаданных через libblkid без обращения к libudev.
- Статические программы не требуют своих обычных shared-зависимостей.
- PAM lastlog2 сохраняет системную интеграцию и соответствующие runtime-требования.
- Исключается непригодная для разделяемых библиотек статическая зависимость от Debian `libm.a`; математические SQL-функции SQLite недоступны.

## Рассмотренные альтернативы
Сохранение математических SQL-функций потребовало бы PIC-совместимого `libm.a`; вариант отклонён в пользу `--disable-math`.

## Ссылки
- [ADR SQLite](../../lib/sqlite/ADR.md)
- [Патч линковки](debian/patches/_build.patch)
