# ADR: профиль сборки GnuPG

## Статус
Принято.

## Решение
- Собирать GnuPG вместе с закреплёнными версиями libgpg-error, libgcrypt, libassuan, libksba и npth.
- Эти внутренние зависимости собирать статически в `/usr/local`.
- zlib и bzip2 линковать статически.
- Отключать NLS, scdaemon, gpgsm и dirmngr.
- Тесты не запускать, документацию удалять из bundle.
