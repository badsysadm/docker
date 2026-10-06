# ADR: профиль сборки sudo

## Статус
Принято.

## Решение
- Собирать sudo 1.9.17p2 из upstream release-тега.
- Использовать PAM для аутентификации.
- Не включать LDAP и SSSD backend для sudoers.
- Включать Linux audit.
- `libaudit` и `libcap-ng` линковать через явные пути к static archives из отдельного каталога.
- Собирать sudoers policy встроенным в `sudo` через `--enable-static-sudoers`.
- Не использовать shared `libsudo_util`.
- Использовать встроенный static zlib.
- Не собирать log server/client; OpenSSL и NLS отключать.
- Тесты не запускать, документацию удалять из конечного bundle.

## Последствия
- PAM остаётся динамической системной зависимостью.
- sudoers policy и внутренний `libsudo_util` не требуют отдельных shared runtime-библиотек.
- `libaudit`, `libcap-ng` и zlib не требуются как shared runtime-зависимости sudo.
- Порядок static-зависимостей audit/cap-ng фиксируется явным указанием `libaudit.a` перед `libcap-ng.a`.
- Централизованные sudo rules через SSSD/FreeIPA или LDAP текущим профилем не поддерживаются.
- Удалённое логирование через `sudo_logsrvd` и TLS не поддерживается.
