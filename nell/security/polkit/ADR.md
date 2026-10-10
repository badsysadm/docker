# ADR: профиль сборки polkit

## Статус
Принято.

## Решение
- Собирать polkit 127 из upstream release tag.
- Сохранять polkitd, pkexec, pkcheck, pkaction и pkttyagent.
- Сохранять публичные shared-библиотеки polkit.
- Использовать PAM для аутентификации.
- Использовать systemd-logind для session tracking.
- Использовать PAM и systemd из собственных bundle проекта.
- Разрешить динамические зависимости от libpam и libsystemd.
- Остальные внешние зависимости предпочитать статическими.
- Использовать Duktape как JavaScript engine.
- Отключить introspection, gettext, examples, tests, man и gtk-doc.
- Не включать SELinux integration.
- Документацию и локали не оставлять в конечном bundle.

## Последствия
- polkit сохраняет полноценную PAM-аутентификацию и интеграцию с logind.
- libc, libpam и libsystemd являются разрешёнными динамическими зависимостями.
- Публичные libpolkit-gobject и libpolkit-agent доступны другим проектам.
- PAM modules продолжают загружаться штатным динамическим механизмом PAM.
- Duktape, GLib и Expat должны по возможности входить в конечные ELF статически.
- GObject Introspection и локализации отсутствуют.
