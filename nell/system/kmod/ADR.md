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
- zstd, lzma и zlib брать из build-зависимостей Debian и линковать статически.
- `libcrypto.a`, OpenSSL headers и pkg-config metadata брать из собственного `bin/security/openssl:3.6.5` и использовать через `/usr/local`.
- libc оставлять динамической.
- Manpages отключать, тесты не запускать.
- Создавать symlink'и `lsmod`, `modprobe`, `insmod`, `rmmod`, `depmod`, `modinfo` на `kmod`.

## Последствия
- В runtime не требуются shared zstd, lzma, zlib и libcrypto.
- Версия OpenSSL для kmod контролируется собственным OpenSSL bundle, а не содержимым Debian build image.
- Обновление OpenSSL или любой другой статически включённой библиотеки требует пересборки kmod.
- Набор стандартных CLI предоставляется через symlink'и на один бинарник `kmod`.
- Документация в конечном bundle отсутствует.
