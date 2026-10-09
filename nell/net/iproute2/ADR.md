# ADR: профиль сборки iproute2

## Статус
Принято.

## Решение
- Собирать iproute2 7.2.0 из upstream release tarball.
- Сохранять поддержку libmnl, libbpf/libelf и capabilities.
- Собирать внутренние модули без shared libraries через `SHARED_LIBS=n`.
- Не включать xtables, TIRPC, Berkeley DB и SELinux.
- Не устанавливать `routel`, требующий Python runtime.

## Последствия
- Доступны devlink, RDMA, DCB, VDPA, netshaper и DPLL.
- Сохраняется BPF/XDP support.
- `arpd` не собирается.
- tc xtables integration отсутствует.
