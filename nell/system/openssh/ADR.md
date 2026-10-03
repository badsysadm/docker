# ADR: профиль сборки OpenSSH

## Статус
Принято.

## Решение
- Собирать OpenSSH Portable из release-тега.
- Включать PAM и Kerberos 5.
- Использовать `libcrypto.a` и headers из собственного OpenSSL bundle, а не shared libcrypto из репозитория.
- crypto, zlib и zstd линковать статически, сохраняя необходимые динамические системные интеграции.
- Тесты не запускать, man-страницы удалять.
