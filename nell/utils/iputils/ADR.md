# ADR: профиль сборки iputils

## Статус
Принято.

## Решение
- Собирать из upstream release archive через Meson/Ninja.
- Собирать arping, clockdiff, ping и tracepath.
- libcap, libidn2 и libunistring линковать статически, libc оставлять динамической.
- Отключать тесты, gettext, man и HTML-документацию.
