# ADR: профиль сборки procps

## Статус
Принято.

## Решение
- Собирать procps-ng 4.0.7 из upstream release tarball.
- Сохранять основные procfs utilities: ps, top, free, vmstat, pgrep, pkill, pidof, sysctl и watch.
- Линковать внешние зависимости статически, libc оставлять динамической.
- Отключить NLS.
- Не включать SELinux integration.
- Не включать systemd integration.
- Не включать NUMA support.
- Тесты не запускать.
- Документацию и локали не оставлять в конечном bundle.

## Последствия
- Основные process/system utilities доступны без сторонних shared-библиотек.
- libc и dynamic loader остаются динамическими.
- В `ps` недоступны SELinux security context и systemd-specific process/session metadata.
- systemd login/session integration отсутствует.
- NUMA-specific отображение и статистика недоступны.
