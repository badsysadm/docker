# ADR: профиль сборки polkit

## Статус
Принято.

## Решение
- Собирать polkit 127 из upstream release tag.
- Сохранять polkitd, pkexec, pkcheck, pkaction и pkttyagent.
- Сохранять публичные shared-библиотеки polkit.
- Собирать внутренние статические варианты libpolkit-gobject и libpolkit-agent для линковки исполняемых файлов polkit.
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
- Публичные libpolkit-gobject и libpolkit-agent доступны другим проектам.
- Исполняемые файлы polkit не имеют runtime dependency на libpolkit-gobject.so и libpolkit-agent.so.
- PAM modules продолжают загружаться штатным динамическим механизмом PAM.
- Duktape, GLib и Expat должны входить в конечные ELF статически.
- GObject Introspection и локализации отсутствуют.
