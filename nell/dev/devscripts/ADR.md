# ADR: Выбранные инструменты devscripts через PAR::Packer

## Статус
Принято для проверки сборкой.

## Контекст
Для Debian-сборки и анализа пакетов нужны отдельные инструменты devscripts.
В `nell` внешние Perl-модули предпочтительно упаковывать вместе с программой.

## Решение
- Основной источник — официальный архив devscripts 2.26.13.
- Perl через `pp -B -I lib`: `mk-build-deps`, `debuild`,
  `dpkg-depcheck`, `debdiff`, `debc`, `hardening-check`,
  `dscverify` и `dch` (upstream `debchange.pl`).
- Явно упаковать динамически загружаемые `Dpkg::Changelog::Parse`,
  `Dpkg::Vendor::Default` и `Dpkg::Vendor::Debian`.
- `debclean`, `dpkg-genbuilddeps`, `debsign` — оригинальные shell-скрипты.
- `suspicious-source` — оригинальный Python-скрипт вместе с
  `devscripts.logger`; не упаковывать его через `pp`.
- Не собирать документацию и тесты.

## Ограничения
- Shell и Python-инструменты требуют соответствующий интерпретатор.
  Для `suspicious-source` нужен также Python-модуль `magic`.
- Инструменты по-прежнему используют внешние программы, в частности
  `dpkg-buildpackage`, `dpkg`, `apt-get`, `equivs-build`,
  `strace`, `readelf`, `gpg`, `lintian` и `apt-file`, в зависимости
  от вызываемой команды. `PAR::Packer` не заменяет эти зависимости.
- `ldd` по основному бинарнику не проверяет зависимости извлекаемых
  PAR XS-модулей; следует проверять их отдельно.
- Необходимы проверки CLI и реальных сценариев, воспроизводимости
  SHA-256 и точного списка статически встроенных модулей для
  `Static-Built-Using`. До этого профиль не считать проверенным.

## Ссылки
- https://sources.debian.org/src/devscripts/2.26.13/
- https://metacpan.org/pod/pp
