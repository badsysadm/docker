# ADR: профиль сборки kmod

## Статус
Принято.

## Решение
- Собирать kmod 34.2 из upstream Git-тега `v34.2`.
- Сохранять рабочий профиль сборки из `bootstrap/debian/knod.Dockerfile`.
- Использовать Meson/Ninja.
- Устанавливать бинарники в `/bin` и `/sbin`, библиотеку — в `/lib/x86_64-linux-gnu`.
- Собирать `libkmod` статически: `-Ddefault_library=static -Dprefer_static=true`.
- Включать поддержку zstd, xz, zlib и OpenSSL.
- zstd, lzma, zlib и libcrypto линковать статически, libc оставлять динамической.
- Manpages отключать, тесты не запускать.
- Создавать symlink'и `lsmod`, `modprobe`, `insmod`, `rmmod`, `depmod`, `modinfo` на `kmod`.

## Последствия
- В runtime не требуются shared zstd, lzma, zlib и libcrypto.
- Обновление любой из статически включённых библиотек требует пересборки kmod.
- Набор стандартных CLI предоставляется через symlink'и на один бинарник `kmod`.
- Документация в конечном bundle отсутствует.
