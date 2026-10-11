# ADR: профиль сборки AppArmor

## Статус
Предложено, ожидает подтверждения и проверки сборкой.

## Решение
- Использовать upstream tag `v4.1.8` из gitlab.com/apparmor/apparmor.
- Собирать `libapparmor`, `apparmor_parser`, `binutils`, правила `profiles` и systemd-интеграцию.
- Не собирать Python/Perl/Ruby bindings, `utils`, `changehat` PAM/Apache modules, regression tests.
- Собирать `libapparmor.a` и публичную `libapparmor.so` для потребителей ABI.
- Линковать `apparmor_parser` и бинарные утилиты со статической libapparmor.
- Не использовать общие цели `all`/`install`, создающие документацию; собирать `arch` и устанавливать `install-arch`.
- Не устанавливать man/info/doc и локали.
- Сохранять policy profiles в `/etc/apparmor.d` и systemd unit.
- Конечный образ `FROM scratch`, артефакты в `/target`.

## Последствия и вопросы для проверки
- Python-утилиты aa-enforce, aa-complain, aa-logprof и др. отсутствуют в первом профиле.
- Публичная `libapparmor.so` намеренно остаётся: это собственная библиотека AppArmor, а не динамическая внешняя зависимость бинарников.
- Проверить команды ELF (`readelf -d`) и отсутствие дополнительных NEEDED, кроме libc и системных загрузочных библиотек.
- Проверить конкретные профили и загрузку через systemd.
- Проверить два совпадающих SHA-256 в стандартном pipeline.
- До этих проверок статус сборки не считать успешным.
