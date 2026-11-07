# ADR: профиль сборки Calino

## Статус
Принято для проверки сборкой.

## Контекст
Calino 0.42.0 — веб-клиент CalDAV/CardDAV на React, TypeScript и Vite.
Официальная production-сборка создаёт статический каталог `dist/`.
Для его обслуживания нужен отдельный HTTP-сервер, но сам Calino не
требует серверного JavaScript runtime. Проект использует pnpm и
фиксирует версии зависимостей в `pnpm-lock.yaml`.

## Решение
- Получать исходники из официального тега `v0.42.0`.
- Использовать Node.js 25 на Debian для сборки и pnpm 10.30.3.
- Устанавливать build-зависимости на этапе `dep` через `mk-build-deps`,
  а JavaScript-зависимости — через `pnpm install --frozen-lockfile`.
- На этапе `bin` запускать `pnpm exec vite build`, как в официальном
  Dockerfile, без отдельного запуска тестов или TypeScript-проверок.
- Не вызывать `scripts/update-sample-events.mjs`: сценарий меняет
  даты демонстрационных событий по текущему месяцу и нарушает
  повторяемость сборки.
- Помещать только содержимое `dist/` в `/target/usr/share/calino/`.
- Не включать Node.js, Caddy, конфигурацию Angie и системные службы
  в итоговый образ. Статические ресурсы обслуживает внешний веб-сервер.
- Сохранить upstream build-time параметры `VITE_SITE_URL`,
  `CALINO_ENABLE_SW`, `CALINO_GITHUB_REPO`,
  `CALINO_CONTACT_EMAIL` и `CALINO_SELF_HOSTED`.

## Последствия
- Конечный bundle не содержит исполняемых бинарных файлов и
  динамических библиотек, поэтому правило статической линковки к нему
  неприменимо.
- Для маршрутов SPA необходим fallback веб-сервера на `index.html`.
- CalDAV/CardDAV-сервер должен разрешать CORS для origin Calino
  либо использоваться собственный прокси; это задача развёртывания.
- Параметры Vite и Calino встраиваются в файлы при сборке.
- Проверки `make calino`, содержимого bundle и двух SHA-256 сборок
  остаются невыполненными до запуска в инфраструктуре.

## Рассмотренные альтернативы
- Поставлять Caddy вместе с Calino, как upstream Docker-образ:
  отклонено для `nell`, поскольку конечный артефакт представляет
  собой набор статических файлов, а веб-сервер разворачивается отдельно.
- Запускать `pnpm build`: отклонено из-за календарно-зависимого
  обновления `sample-events.ics` и дополнительной проверки типов.

## Ссылки
- https://github.com/Ivan-Malinovski/calino/tree/v0.42.0
- https://github.com/Ivan-Malinovski/calino/blob/v0.42.0/Dockerfile
- https://github.com/Ivan-Malinovski/calino/blob/v0.42.0/docs/DOCKER.md
- ../../../README.md
