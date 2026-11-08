# ADR: Quilt as original Bash-based patch management tools

## Статус

Принято для проверки сборкой.

## Контекст

Quilt 0.69 — преимущественно набор Bash-команд для управления
сериями патчей. В отличие от devscripts и debhelper, эти команды
не следует искусственно преобразовывать в Perl/PAR-архивы.

## Решение

- Использовать официальный архив исходников Debian quilt 0.69
  (оригинальный upstream tarball).
- Собирать стандартными upstream `configure`, `make`, `make install`
  с `--prefix=/usr` и `DESTDIR=/src/target`.
- Сохранить оригинальные скрипты `quilt`, служебные команды и файлы,
  установленные upstream для работы quilt, включая `/usr/share/quilt`.
- Не собирать и не запускать тесты.
- Удалить документацию, локализации и необязательные shell completion
  из конечных артефактов.
- Сборочные зависимости устанавливать через `mk-build-deps` по
  собственному `debian/control`, как в devscripts и debhelper.

## Ограничения и проверки

- Quilt вызывает внешние программы (например, `patch`, `diff`,
  `gawk`, `sed`, `grep`, `ed`, `diffstat`); они должны
  присутствовать в рабочем окружении. Профиль их не встраивает.
- Скрипты требуют Bash; создаваемые upstream исполняемые бинарные
  компоненты необходимо проверить на отсутствие сторонних
  динамических библиотек, кроме libc.
- Проверить наличие `quilt` и `guards`, а также служебных runtime
  файлов в `/target`.
- Проверить `quilt --version` и реальный сценарий
  `new` / `add` / `refresh` / `pop` / `push`.
- Проверить `make quilt`, двойную сборку и одинаковые SHA-256.
- `Static-Built-Using` заполнять только по фактически встроенным
  статическим сторонним библиотекам, если они будут обнаружены.

## Ссылки

- https://packages.debian.org/source/sid/quilt
- https://deb.debian.org/debian/pool/main/q/quilt/
- https://savannah.nongnu.org/projects/quilt/
