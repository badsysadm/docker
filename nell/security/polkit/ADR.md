# ADR: профиль сборки polkit

## Статус
Принято.

## Решение
- Собирать polkit 127 из upstream release tag.
- Сохранять polkitd, pkexec, pkcheck, pkaction и pkttyagent.
- Собирать libpolkit-gobject и libpolkit-agent только статически.
- Использовать локальную sed-правку Meson как исключение, поскольку upstream 127 явно объявляет эти библиотеки через shared_library().
- Использовать PAM для аутентификации.
- Использовать systemd-logind для session tracking.
- Использовать PAM и systemd из собственных bundle проекта.
- Использовать GLib/GObject/GIO из собственного статического GLib bundle.
- Использовать GLib, собранный без SELinux и libmount.
- Разрешить динамические зависимости от libpam и libsystemd.
- Остальные внешние зависимости предпочитать статическими.
- Использовать Duktape как JavaScript engine.
- Отключить introspection, gettext, examples, tests, man и gtk-doc.
- Не включать SELinux integration.
- Документацию и локали не оставлять в конечном bundle.

## Последствия
- polkit сохраняет полноценную PAM-аутентификацию и интеграцию с logind.
- libc, libpam и libsystemd являются разрешёнными динамическими зависимостями.
- Runtime dependency на libselinux и libsepol не допускается.
- Shared libpolkit-gobject и libpolkit-agent отсутствуют.
- libpolkit-gobject и libpolkit-agent входят в исполняемые файлы статически.
- PAM modules продолжают загружаться штатным динамическим механизмом PAM.
- Duktape, GLib и Expat должны входить в конечные ELF статически.
- GObject Introspection и локализации отсутствуют.
