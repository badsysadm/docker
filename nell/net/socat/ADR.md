# ADR: socat с TLS, Readline и TCP Wrappers

## Статус
Принято для проверки сборкой.

## Контекст
Необходимо сохранить адреса OpenSSL и READLINE, поддержку TCP Wrappers
и обеспечить воспроизводимые бинарники.

## Решение
- Сохранить OpenSSL, Readline и TCP Wrappers без отключения этих интеграций.
- Использовать OpenSSL, ncurses, zlib и Zstandard из профилей nell;
  Readline и TCP Wrappers — из Debian.
- Учитывать статические зависимости OpenSSL от zlib и Zstandard.
- Требовать `WITH_OPENSSL=1` после `configure`, не допуская
  незаметного отключения TLS.
- Фиксировать `SOURCE_DATE_EPOCH=0`, чтобы время сборки не меняло
  содержимое исполняемых файлов.

## Последствия
- Сохраняются TLS-адреса, READLINE и TCP Wrappers.
- При недоступности OpenSSL конфигурация сборки завершается ошибкой.

## Альтернативы
- Отключить необязательные интеграции: не выбрано из-за потери возможностей.

## Ссылки
- [Зависимости](02_dep.Dockerfile)
- [Сборка](03_bin.Dockerfile)
- https://www.dest-unreach.org/socat/
