# ADR: профиль сборки rsyslog

## Статус
Принято.

## Решение
- Собирать rsyslog 8.2608.0 из upstream release tarball.
- Сохранять штатную loadable-module архитектуру rsyslog.
- Не удалять штатные модули после make install.
- Использовать TCP и UDP syslog input.
- Использовать imklog для kernel logging.
- Использовать imfile.
- Использовать imkubernetes.
- Использовать HTTP/HTTPS input через imhttp.
- Использовать HTTP/HTTPS output через omhttp.
- Не использовать OpenTelemetry output через omotel.
- Не включать неиспользуемые default-on modules fmhttp, fmhash и mmleefparse.
- Не использовать RELP.
- Не использовать imjournal.
- Не использовать RFC3195.
- Не использовать deprecated omruleset.
- Не включать libsystemd integration.
- Собирать CivetWeb 1.16 из upstream source как PIC static archive для imhttp.
- Собирать APR 1.7.5, APR-util 1.6.3 и libxcrypt 4.4.38 из upstream source как PIC static archives для imhttp.
- Линковать imhttp со static APR-util/APR/libcrypt closure; Expat используется только как build-time зависимость APR-util.
- Линковать внешние зависимости модулей статически там, где доступны PIC static archives.
- Использовать собственный OpenSSL bundle для TLS.
- Релокировать pkg-config metadata OpenSSL при копировании в /usr/local и не сохранять абсолютные пути к системным static zlib/zstd.
- Не включать YAML configuration, UUID и libgcrypt.
- Отключить testbench и тестовые targets.
- Не генерировать документацию.
- Устанавливать штатным make install.
- Не устанавливать конфигурацию rsyslog по умолчанию.
- После установки удалять документацию, man pages, info и locales.
- Удалять libtool metadata (*.la) из конечного bundle.

## Последствия
- rsyslog modules остаются динамически загружаемыми .so.
- Сторонние библиотеки должны входить в соответствующие modules статически.
- CivetWeb не является отдельным nell dependency-проектом.
- HTTPS поддерживается для HTTP-oriented modules.
- protobuf-c и protoc-c не требуются, так как omotel и impstats-push отключены.
- Runtime-конфигурация rsyslog предоставляется системой отдельно.
- systemd journal и Unix syslog socket не используются штатной конфигурацией пакета.
- libc, resolver и NSS остаются системными динамическими механизмами.
