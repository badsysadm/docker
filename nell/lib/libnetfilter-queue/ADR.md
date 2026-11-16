# ADR: Профиль libnetfilter_queue

## Статус

Принято.

## Контекст

Suricata использует NFQUEUE, но использование Debian libnetfilter-queue-dev не позволяет гарантировать выбор статического архива из NELL. Библиотека зависит от libmnl и libnfnetlink.

## Решение

Собирать libnetfilter_queue в отдельном профиле, используя библиотеки libmnl и libnfnetlink из профилей NELL. Производить статический и разделяемый варианты с PIC. Использовать `-ffunction-sections` и `-fdata-sections`, чтобы при финальной статической линковке с `--gc-sections` потребители могли исключить неиспользуемые секции; `--gc-sections` также применяется при сборке самого профиля. Применять FORTIFY, защиту стека (`-fstack-protector-strong`, `-fstack-clash-protection`), аппаратную защиту потока управления (`-fcf-protection=full`) и нулевую инициализацию автоматических переменных (`-ftrivial-auto-var-init=zero`), а при линковке — RELRO и немедленное разрешение символов (`-z relro`, `-z now`).

## Последствия

Для сборки необходимы образы libmnl и libnfnetlink; Suricata может получать заголовки и статический архив libnetfilter_queue без переноса разделяемой библиотеки.

## Рассмотренные альтернативы

Использование Debian libnetfilter-queue-dev отвергнуто в пользу контролируемого статического архива NELL.

## Ссылки

- [Правила NELL](../../README.md)
- [Реализация](03_bin.Dockerfile)
