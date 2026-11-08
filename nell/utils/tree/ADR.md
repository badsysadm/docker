# ADR: профиль сборки tree

## Статус
Принято.

## Контекст
Upstream Makefile трактует `DESTDIR` как каталог бинарника, а не staging root.

## Решение
- Устанавливать `tree` вручную через `install -Dm755` в
  `/src/target/usr/bin/tree`.

## Последствия
- Штатная цель `make install` не используется.

## Альтернативы
- Переопределение путей в `make install`: не выбрано.

## Ссылки
- [03_bin.Dockerfile](03_bin.Dockerfile)
- [Правила ADR](../../../doc/internal/adr.md)
