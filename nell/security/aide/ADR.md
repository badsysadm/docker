# ADR: Профиль сборки AIDE

## Статус

Принято.

## Контекст

Для AIDE требуется сохранить контроль security-атрибутов файлов, при этом не добавлять функциональность, не используемую в целевом окружении.

AIDE поддерживает два альтернативных криптографических backend для вычисления хешей — Nettle и libgcrypt. Одновременное использование обоих upstream не поддерживает.

Для AIDE допустима полная статическая сборка.

## Решение

Использовать полную статическую сборку:

```text
--enable-static
```

В качестве crypto backend использовать Nettle:

```text
--with-nettle
--without-gcrypt
```

Nettle предоставляет необходимые AIDE алгоритмы хеширования и имеет более простую цепочку статических зависимостей. Использование libgcrypt потребовало бы дополнительной зависимости на libgpg-error без необходимого для текущей конфигурации функционального выигрыша.

Включить контроль security-атрибутов файлов:

```text
--with-posix-acl
--with-xattr
--with-capabilities
--with-e2fsattrs
```

Таким образом AIDE контролирует:

- POSIX ACL;
- extended attributes;
- Linux file capabilities;
- filesystem attributes, изменяемые через `chattr`.

Эти атрибуты входят в стандартную группу `X` AIDE и используются стандартными compound groups, включая `R`, `L` и `>`.

Не включать:

```text
--without-selinux
--without-curl
--without-audit
--without-locale
```

`audit` отвечает только за отправку результата обнаружения изменений в Linux Audit Framework и не влияет на состав проверяемых атрибутов.

`curl` не требуется, поскольку сетевые database/report backends не используются.

SELinux и locale не входят в требуемый профиль AIDE.

## Autotools

Release tarball AIDE содержит готовые autotools-файлы, однако из-за их timestamps `make` может попытаться вызвать конкретную версию `aclocal`.

Чтобы исключить ненужную регенерацию autotools-файлов, перед `configure` обновляются timestamps:

```sh
find . -type f \( -name "configure" -o -name "Makefile.in" -o -name "aclocal.m4" \) -exec touch {} +
```

## Последствия

При необходимости интеграции AIDE с Linux Audit Framework потребуется включить `audit` и добавить `libaudit`.

При переходе с Nettle на libgcrypt потребуется добавить статическую цепочку зависимостей libgcrypt, включая libgpg-error.

Поддержка SELinux в текущем профиле отсутствует.
