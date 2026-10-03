# ADR: профиль сборки AIDE

## Статус
Принято.

## Решение
- Для AIDE допустима полная статическая сборка.
- В качестве crypto backend использовать Nettle: `--with-nettle --without-gcrypt`. Одновременное использование Nettle и libgcrypt upstream не поддерживает.
- Nettle выбран из-за более простой цепочки статических зависимостей; libgcrypt потребовал бы также libgpg-error без функциональной необходимости для текущего профиля.
- Включать контроль POSIX ACL, xattr, Linux capabilities и ext filesystem attributes: `--with-posix-acl --with-xattr --with-capabilities --with-e2fsattrs`.
- Эти атрибуты входят в стандартную группу AIDE `X` и используются compound-группами, включая `R`, `L` и `>`.
- Отключать SELinux, curl, audit и locale.
- `audit` нужен только для отправки результатов в Linux Audit Framework и не влияет на набор проверяемых атрибутов.
- `curl` не нужен, так как сетевые database/report backends не используются.
- Release tarball содержит готовые autotools-файлы; перед `configure` обновлять timestamps `configure`, `Makefile.in` и `aclocal.m4`, чтобы `make` не пытался вызвать несовместимую версию `aclocal`.

## Последствия
- При необходимости Linux Audit Framework потребуется включить audit и добавить libaudit.
- При переходе на libgcrypt потребуется добавить статическую цепочку зависимостей libgcrypt, включая libgpg-error.
- Сетевые database/report backends недоступны без curl.
- Поддержка SELinux и locale в текущем профиле отсутствует.
