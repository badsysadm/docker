# ADR: профиль сборки systemd

## Статус
Принято.

## Решение
- Использовать Meson/Ninja и release build.
- Не устанавливать тесты; man и HTML документацию отключать.
- Сохранять PAM, NSS, resolver, audit, SELinux, AppArmor, seccomp, cryptsetup, TPM2, networkd, resolved, logind и остальные явно включённые системные интеграции.
- Полную статическую сборку не использовать, так как systemd зависит от PAM, NSS, resolver и других динамических системных интерфейсов.
- Собственный OpenSSL использовать из `bin/security/openssl:3.6.5`; Debian `libssl-dev` не использовать.
- kmod использовать из Debian build-зависимости `libkmod-dev`, как в исходной рабочей сборке.
- `libsystemd` собирать статически с PIC, сохраняя существующие shared-link режимы для компонентов, явно заданные исходным профилем.
- После установки удалять man, info и doc из конечного bundle.
- File-system maintenance helpers and kernel configuration services are split into optional `systemd-filesystem` and `systemd-kernel` Debian packages, so lightweight containers can omit host-only functionality without removing core service-manager units.
- TPM2-специфичные исполняемые файлы, PCRLock/NvPCR-данные, systemd units и cryptsetup TPM2-плагин поставлять отдельным необязательным Debian-пакетом `systemd-tpm2`; `systemd` и `systemd-boot` не должны требовать его установки.

## Последствия
- systemd сохраняет полный набор системных интеграций исходной рабочей сборки и поэтому имеет допустимые динамические runtime-зависимости.
- OpenSSL контролируется собственной `nell`-сборкой, а libkmod берётся из Debian build environment.
- Обновление OpenSSL или версии Debian libkmod требует пересборки systemd.
- Большой набор включённых возможностей увеличивает число build- и runtime-зависимостей.
- При изменении feature-профиля необходимо отдельно проверять PAM/NSS/resolver и загрузочные компоненты.
- Документация в конечном bundle отсутствует.
- Установка `systemd-tpm2` выбирается отдельно для систем с TPM2; это разделение пакетов само по себе не исключает TPM2-код и библиотеки из общих бинарников, собираемых с `-Dtpm2=enabled`.
