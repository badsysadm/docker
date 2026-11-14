# ADR: профиль сборки D-Bus

## Статус
Принято.

## Решение
- Сохранять классический dbus-daemon.
- Использовать Meson с default_library=both, b_staticpic=true и prefer_static=true, чтобы выпускать статическую и динамическую libdbus-1 с PIC.
- Статически линковать libcap и libsystemd.
- Сохранять интеграцию с systemd и AppArmor.
- Отключить SELinux и X11 autolaunch.

## Последствия
- Системная шина D-Bus использует systemd-интеграцию.
- AppArmor mediation остаётся доступной.
- SELinux и X11 autolaunch не поддерживаются.
