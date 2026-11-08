# ADR: tcpdump с libpcap и криптографической поддержкой

## Статус
Принято для проверки сборкой.

## Контекст
Tcpdump использует libpcap для захвата пакетов. Для разбора протоколов
и проверки криптографических данных сохраняется интеграция с OpenSSL.

## Решение
- Использовать официальный upstream tcpdump.
- Сохранить поддержку libpcap, OpenSSL и libcap-ng.
- Использовать libpcap и libcap-ng из Debian build-зависимостей,
  а libcrypto, zlib и zstd — из существующих профилей `nell`.
- Отключить интеграцию с libsmi и SMB dissector.

## Последствия
- Поставляется tcpdump для захвата и анализа сетевого трафика.
- Декодирование MIB через libsmi и SMB dissector недоступны.

## Альтернативы
- Собирать собственную libpcap вместе с tcpdump: не выбрано, поскольку
  Debian предоставляет статическую библиотеку разработки.

## Ссылки
- https://github.com/the-tcpdump-group/tcpdump
- ../../README.md
