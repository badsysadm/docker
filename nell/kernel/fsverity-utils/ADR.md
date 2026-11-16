# ADR: Линковка утилиты fsverity с libfsverity

## Решение

Сохранить предусмотренную upstream статическую линковку утилиты `fsverity`
с `libfsverity.a`, не переключая её на `libfsverity.so` через
`USE_SHARED_LIB`.

## Обоснование

Утилита не должна зависеть при запуске от установленной отдельно
`libfsverity.so`, хотя сама разделяемая библиотека также поставляется
для сторонних потребителей.

## Ссылка

- https://github.com/ebiggers/fsverity-utils/blob/v1.7/Makefile
