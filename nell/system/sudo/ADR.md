# ADR: профиль сборки sudo

## Статус
Принято.

## Решение
- Собирать sudo 1.9.17p2 из upstream release-тега.
- Использовать PAM для аутентификации.
- Не включать LDAP и SSSD backend для sudoers.
- Включать Linux audit.
- `libaudit` и `libcap-ng` линковать статически.
- Использовать штатный динамически загружаемый `sudoers.so`.
- Использовать встроенный static zlib.
- Не собирать log server/client; OpenSSL и NLS отключать.
- Тесты не запускать, документацию удалять из конечного bundle.

## Последствия
- PAM остаётся динамической системной зависимостью.
- `sudoers.so` остаётся отдельным plugin sudo.
- `libaudit`, `libcap-ng` и zlib не требуются как shared runtime-зависимости sudo.
- Централизованные sudo rules через SSSD/FreeIPA или LDAP текущим профилем не поддерживаются.
- Удалённое логирование через `sudo_logsrvd` и TLS не поддерживается.
