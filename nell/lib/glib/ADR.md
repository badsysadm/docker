# ADR: профиль сборки GLib

## Статус
Принято.

## Решение
- Собирать GLib 2.84.4 из upstream release archive.
- Собирать только статические библиотеки.
- Собирать static libraries как PIC для использования в shared-библиотеках потребителей.
- Сохранять GLib, GObject, GIO и GModule.
- Сохранять headers, pkg-config metadata и build tools.
- Отключить SELinux integration.
- Отключить libmount integration.
- Отключить sysprof и libelf integration.
- Отключить GObject Introspection.
- Отключить NLS.
- Тесты не собирать и не запускать.
- Документацию не собирать и не оставлять в bundle.

## Последствия
- Shared-библиотеки GLib в bundle отсутствуют.
- Потребители могут статически включать GLib/GObject/GIO/GModule в свои ELF.
- Static archives пригодны для включения в shared libraries.
- GLib не создаёт зависимости на libselinux и libmount.
- GTK и другие GUI-библиотеки в bundle отсутствуют.
