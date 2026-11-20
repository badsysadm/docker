# ADR: Линковка утилиты fsverity с libfsverity

## Статус

Принято для проверки сборкой.

## Контекст

Upstream позволяет собирать утилиту `fsverity` как с `libfsverity.a`,
так и с `libfsverity.so` через `USE_SHARED_LIB`. При этом разделяемая
библиотека нужна сторонним потребителям.

## Решение

- Сохранить штатную статическую линковку утилиты `fsverity` с
  `libfsverity.a`, не включая `USE_SHARED_LIB`.

## Последствия

Утилита не зависит при запуске от отдельной `libfsverity.so`;
разделяемая библиотека остаётся доступна другим приложениям.

## Альтернативы

- `USE_SHARED_LIB=1`: не выбрано, поскольку добавляет утилите
  runtime-зависимость от `libfsverity.so`.

## Ссылки

- [Профиль сборки](03_bin.Dockerfile)
- https://github.com/ebiggers/fsverity-utils/blob/v1.7/Makefile
