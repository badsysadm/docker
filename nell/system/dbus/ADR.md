# ADR: профиль сборки D-Bus

## Статус
Принято.

## Решение
- Сохранять классический dbus-daemon.
- Использовать Meson с default_library=static и prefer_static=true.
- Статически линковать libcap и libsystemd.
- Сохранять интеграцию с systemd и AppArmor.
- Отключить SELinux и X11 autolaunch.

## Последствия
- Системная шина D-Bus использует systemd-интеграцию.
- AppArmor mediation остаётся доступной.
- SELinux и X11 autolaunch не поддерживаются.
