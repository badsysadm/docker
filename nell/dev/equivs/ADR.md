# ADR: Equivs с упаковкой Perl через PAR::Packer

## Статус
Принято для проверки сборкой.

## Контекст
`mk-build-deps` использует `equivs-build` для генерации пакета,
объявляющего сборочные зависимости. Upstream `equivs` предоставляет
`equivs-build` и `equivs-control` вместе с шаблонами.

## Решение
- Использовать официальный Debian source archive `equivs 2.3.3`.
- Упаковать Perl-программу `usr/bin/equivs-build` с помощью `pp -B`.
- Оставить `usr/bin/equivs-control` оригинальным shell-скриптом.
- Сохранить `usr/share/equivs` целиком: `template.ctl` и
  `template/debian/*` необходимы во время работы программ.
- Для повторяемости `pp` использовать фиксированное время и настройки
  порядка хеширования Perl.
- Не собирать тесты и документацию.

## Ограничения
- `equivs-build` создаёт пакеты посредством внешних `dpkg`,
  `dpkg-buildpackage`, `debhelper`, `make` и других инструментов.
  Эти команды должны быть доступны в рабочем окружении.
- `equivs-control` требует shell и `cp`.
- Шаблоны используются upstream по абсолютным путям
  `/usr/share/equivs`; профиль поставляет их по этим путям
  после размещения `/target` в корне рабочей системы.
- Необходимо проверить создание реального `.deb` через `equivs-build`
  и работу вместе с `mk-build-deps`, а также повторяемость SHA-256.
- `ldd` по исполняемому файлу PAR не проверяет извлекаемые XS-модули.
  Состав встроенных зависимостей и `Static-Built-Using` требуют проверки.

## Ссылки
- https://sources.debian.org/src/equivs/2.3.3/
- https://manpages.debian.org/unstable/equivs/equivs-build.1.en.html
