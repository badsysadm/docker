# Частые проблемы сборки

## Autotools: неожиданный повторный запуск `aclocal`

**Симптом:** `make` пытается перегенерировать `configure` или `Makefile.in`
и падает из-за версии Autotools.

**Причина:** временные метки сгенерированных файлов в release-архиве.

**Решение:** если архив уже содержит готовые Autotools-файлы, обновить
метки перед `configure`:

```sh
find . -type f \( -name configure -o -name Makefile.in -o -name aclocal.m4 \) -exec touch {} +
```

Если используется `autoreconf`, этот приём обычно не требуется.

## M4: запятая в подставляемых флагах

**Симптом:** после `autoreconf` сгенерированный `configure` падает с
`syntax error near unexpected token 'else'`.

**Причина:** аргументы M4 разделяются запятыми. Флаги вида
`-Wl,-Bstatic`, вставленные в тело M4-макроса, могут нарушить его
разбор.

**Решение:** не вставлять такие флаги в M4-макрос без корректного
экранирования; для линковщика GCC можно использовать форму без запятых:

```sh
-Xlinker -Bstatic -lcap-ng -Xlinker -Bdynamic
```

## Статическая линковка OpenSSL: отсутствуют символы zlib и zstd

**Симптом:** при сборке CMake с собственными статическими
`libssl.a` и `libcrypto.a` этап линковки `curltest` завершается
ошибками `undefined reference`. Например:

```text
libcrypto.a(libcrypto-lib-c_zlib.o): undefined reference to `inflate'
libcrypto.a(libcrypto-lib-c_zlib.o): undefined reference to `deflate'
libcrypto.a(libcrypto-lib-c_zstd.o): undefined reference to `ZSTD_decompressStream'
libcrypto.a(libcrypto-lib-c_zstd.o): undefined reference to `ZSTD_compressStream2'
```

**Причина:** OpenSSL собран с поддержкой zlib и zstd. При использовании
`libcrypto.a` зависимости этого статического архива не подтягиваются
линковщиком автоматически: в команду линковки потребителя должны входить
также библиотеки zlib и zstd. Наличие заголовков и `libcrypto.a` само
по себе недостаточно.

**Решение:** предоставить `libz.a` и `libzstd.a` (в `nell` —
предпочтительно из существующих профилей) и явно добавить их к
линковке потребителя **после** `libcrypto.a`:

```sh
... /usr/local/lib/libssl.a /usr/local/lib/libcrypto.a \
    /usr/local/lib/libz.a /usr/local/lib/libzstd.a
```

Это схема порядка библиотек, а не самостоятельная команда сборки.
Конкретные пути должны соответствовать файлам в build-окружении.
Для CMake следует включить транзитивные зависимости в настройки
линковки соответствующих целей; настройка
`OPENSSL_USE_STATIC_LIBS=ON` выбирает статический OpenSSL, но сама
по себе не гарантирует добавление зависимостей его архива.

**Проверка:** в фактической команде линковки проблемной цели должны
присутствовать статические библиотеки zlib и zstd. Если вместо
`undefined reference` появляется `cannot find`, нужно проверить
наличие и пути самих архивов. Не следует устранять ошибку отключением
поддержки zlib или zstd в OpenSSL.
