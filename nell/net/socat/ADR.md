# ADR: socat с TLS, Readline и TCP Wrappers

## Статус
Принято для проверки сборкой.

## Контекст
Для адресов OpenSSL, Readline и TCP Wrappers нужны соответствующие
библиотеки; их отключение сокращает возможности socat.

## Решение
- Сохранить OpenSSL, Readline и TCP Wrappers.
- Брать OpenSSL и ncurses из профилей nell; Readline и
  TCP Wrappers — из Debian.
- Линковать эти библиотеки статически.

## Последствия
- Сохраняются TLS-адреса, адрес READLINE и поддержка TCP Wrappers.
- Исполняемые файлы не зависят от динамических версий этих библиотек.

## Альтернативы
- Отключить необязательные интеграции: не выбрано из-за потери возможностей.

## Ссылки
- [Профиль сборки](03_bin.Dockerfile)
- https://www.dest-unreach.org/socat/
