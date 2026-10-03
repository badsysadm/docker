# docker

Сборка модулей из исходников выполняется через Kaniko. Основные модули находятся в `nell/`.

## Структура модуля

```text
nell/<section>/<module>/
├── 01_src.Dockerfile
├── 02_dep.Dockerfile
├── 03_bin.Dockerfile
├── ADR.md
└── debian/control
```

- `01_src.Dockerfile` — получает исходники и формирует `src`-образ.
- `02_dep.Dockerfile` — добавляет build-зависимости и формирует `dep`-образ.
- `03_bin.Dockerfile` — собирает конечные артефакты в `/target`.
- `ADR.md` — фиксирует принятый профиль сборки и его последствия.

Правила оформления и компиляции описаны в [nell/README.md](nell/README.md).

## Регистрация в Makefile

Модуль регистрируется в корневом `Makefile` через section и version:

```make
nftables: section = net
nftables: version ?= 1.1.7
```

После этого полная сборка запускается:

```bash
make nftables
```

Версию можно переопределить:

```bash
make nftables version=1.1.8
```

## Как работает полная сборка

`make <module>` выполняет:

1. Проверяет наличие `src/<section>/<module>:<version>` в registry. Если образа нет — собирает `01_src.Dockerfile` и публикует его.
2. Проверяет наличие `dep/<section>/<module>:<version>`. Если образа нет — собирает `02_dep.Dockerfile` и публикует его.
3. Собирает `03_bin.Dockerfile`.
4. Считает SHA-256 всех полученных файлов.
5. Повторно собирает `03_bin.Dockerfile` и сравнивает SHA-256 для проверки воспроизводимости.

`03_bin` автоматически в registry не публикуется.

## Ручной дебаг

Любой этап можно запустить отдельно:

```bash
make nell/net/nftables/03_bin.Dockerfile version=1.1.7
```

Makefile подготовит Kaniko rootfs и запустит Dockerfile через `systemd-run` с его каталогом в качестве build context.

Результат `03_bin` после сборки доступен в:

```text
.build/rootfs/target/
```

Например, проверить динамические зависимости:

```bash
readelf -d .build/rootfs/target/usr/sbin/nft
```

При проблемах со сборкой удобнее запускать отдельно `01_src`, `02_dep` или `03_bin`, передавая нужную версию через `version=...`.

## Подсказки

### Ручной запуск Kaniko через systemd-run

```bash
systemd-run -t \
  -p RootDirectory=/root/test/image \
  -p Environment=SSL_CERT_DIR=/kaniko/certs \
  -p BindReadOnlyPaths=/etc/resolv.conf \
  -p BindReadOnlyPaths=/etc/ssl/certs:/kaniko/certs \
  /kaniko/executor \
    --no-push \
    --force \
    --context git://github.com/badsysadm/docker \
    --context-sub-path test \
    --cleanup \
    --tar-path /kaniko/test.tar.gz
```

### Запуск QEMU

```bash
qemu-system-x86_64 -enable-kvm -m 2G \
  -bios .build/rootfs/usr/share/ovmf/OVMF.fd \
  -kernel .build/rootfs/src/custom.EFI \
  -nographic \
  -serial mon:stdio \
  -device virtio-net-pci,netdev=n1 \
  -netdev tap,id=n1,ifname=tap0,script=no,downscript=no \
  -boot menu=on,splash-time=0
```

### Публикация OCI-образа через skopeo

```bash
skopeo copy --dest-tls-verify=false \
  oci:.build/rootfs/kaniko/oci/ \
  docker://oci.badsysadm.local:80/get/source:latest
```

### Ручная сборка Perl по этапам

```bash
make nell/perl/01_src.Dockerfile
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://oci.badsysadm.local:80/src/perl/perl:5.44.0

make nell/perl/02_dep.Dockerfile
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://oci.badsysadm.local:80/dep/perl/perl:5.44.0

make nell/perl/03_bin.Dockerfile
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://oci.badsysadm.local:80/bin/perl/perl:5.44.0

make nell/perl/04_deb.Dockerfile
skopeo copy --dest-tls-verify=false oci:.build/rootfs/kaniko/oci/ docker://oci.badsysadm.local:80/deb/perl/perl:5.44.0
```

Пример публикации отдельного package image:

```bash
skopeo copy --dest-tls-verify=false \
  oci:.build/rootfs/kaniko/oci \
  docker://oci.badsysadm.local:80/pkg/libs/openssl:3.6.5
```
