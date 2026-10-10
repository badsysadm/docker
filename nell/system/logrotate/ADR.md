# ADR: профиль сборки logrotate

## Статус
Принято.

## Решение
- Собирать logrotate 3.22.0 из upstream release tarball.
- Собирать основной исполняемый файл logrotate без сборки и запуска тестов.
- Использовать ACL support.
- Использовать libacl 2.4.0 из собственного bundle и линковать его статически.
- Линковать libpopt статически.
- Не включать SELinux support.
- Оставлять libc и dynamic loader динамическими.
- Использовать /var/lib/logrotate/status как state file.
- Устанавливать проект штатным make install.
- Устанавливать upstream systemd service и timer.
- После установки удалять документацию, man pages, info и локали из конечного bundle.

## Последствия
- logrotate сохраняет POSIX ACL при ротации файлов.
- libacl и libpopt не являются runtime-зависимостями logrotate.
- Runtime dependency на libselinux отсутствует.
- Ожидаемые динамические зависимости ELF ограничены libc и dynamic loader.
- Ротация может запускаться штатным systemd timer.
- Команды сжатия и отправки почты остаются внешними runtime-командами и не входят в bundle logrotate.
