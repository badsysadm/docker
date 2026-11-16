# CVE Connectors

Набор независимых Python-коннекторов для загрузки сведений об уязвимостях, формирования единого индекса соответствий `PURL CVE` и проверки локальной базы решений о применимости и исправлениях при сборке Debian-пакетов.

## Структура проекта

```text
.
├── aliases
├── connectors/
│   ├── bdu/
│   │   ├── import.py
│   │   └── converter.py
│   ├── chainguard/
│   │   ├── import.py
│   │   └── converter.py
│   ├── debian/
│   │   ├── import.py
│   │   └── converter.py
│   ├── kubernetes/
│   │   ├── import.py
│   │   └── converter.py
│   ├── nvd/
│   │   ├── import.py
│   │   └── converter.py
│   └── github.py
├── Makefile
├── config.py
├── refresh.py
├── dpkg-cvecheck.py
├── dpkg-vexgen.py
└── README.md
```

`Makefile` организует загрузку, конвертацию, объединение индексов и содержит отдельную цель `verify`. Файлы решений `debian/cve/<binary-package>` находятся в исходном Debian-пакете, который проверяется, а не в каталоге `src/` утилиты. Коннекторы запускаются отдельными процессами и не импортируют код друг друга. `github.py` существует отдельно, но не входит в сборочный цикл.

## Источники и файлы

| Источник | Загрузчик | Конвертер | Исходный файл | Промежуточный индекс |
|---|---|---|---|---|
| NVD | `connectors/nvd/import.py` | `connectors/nvd/converter.py` | `.buildcve/nvd-cve.jsonl` | `.buildcve/nvd-purl.txt` |
| Debian Security Tracker | `connectors/debian/import.py` | `connectors/debian/converter.py` | `.buildcve/debian-cve.json` | `.buildcve/debian-purl.txt` |
| БДУ ФСТЭК | `connectors/bdu/import.py` | `connectors/bdu/converter.py` | `.buildcve/fstec-cve.xml` | `.buildcve/fstec-purl.txt` |
| Chainguard OSV v3 | `connectors/chainguard/import.py` | `connectors/chainguard/converter.py` | `.buildcve/chainguard-cve.jsonl` | `.buildcve/chainguard-purl.txt` |
| Kubernetes Official CVE Feed | `connectors/kubernetes/import.py` | `connectors/kubernetes/converter.py` | `.buildcve/kubernetes-cve.json` | `.buildcve/kubernetes-purl.txt` |

Общий индекс: **`.buildcve/merged-purl.txt`**.

Загрузка (`get`) и конвертация (`convert`) разделены: уже загруженные исходные данные можно преобразовывать повторно, не обращаясь к внешним источникам.

### Особенности источников

- **NVD:** построчная обработка JSONL; сопоставление программного обеспечения по сведениям из NVD; поисковые PURL преимущественно вида `pkg:generic/...`.
- **Debian:** используются исходные пакеты Debian Security Tracker; PURL вида `pkg:deb/debian_<source-package>`. Временные обозначения `TEMP-*` в выходной индекс не включаются.
- **БДУ ФСТЭК:** XML обрабатывается потоково. Если запись содержит CVE, создаются пары с CVE; если CVE отсутствуют, используется идентификатор `BDU:...`. Не нужно дублировать одну запись одновременно под CVE и BDU.
- **Chainguard (отключён от Makefile из-за недоступности источника):** используется полный архив OSV v3; из `affected[].package` формируются ключи `pkg:chainguard/<package>` и `pkg:wolfi/<package>`, из `upstream` — идентификаторы CVE. Диапазоны версий и статусы триажа фида не фильтруются; анализ применимости остаётся ручным. Пакеты с другими экосистемами игнорируются. Для Trivy добавлены соответствия `pkg:chainguard/trivy` и `pkg:wolfi/trivy`.
- **Kubernetes:** все CVE официального JSON-фида сохраняются с единым ключом `pkg:kubernetes/kubernetes`. Конвертер не разбирает текст бюллетеней, не выделяет отдельные компоненты и не применяет алиасы.

Конвертеры NVD, Debian, БДУ и (при ручном запуске) Chainguard применяют соответствия из `src/aliases` при формировании промежуточных индексов. Kubernetes сохраняет исходный ключ `pkg:kubernetes/kubernetes` без алиасов.

## Команды

Команды формирования индекса запускаются из каталога `nell/dev/dpkg-cvecheck/src/`:

```bash
make build
make get
make convert
make merge
make refresh
```

| Команда | Назначение |
|---|---|
| `build` | Выполнить `get`, `convert` и `refresh` для всех четырёх активных источников. |
| `get` | Загрузить исходные данные NVD, Debian, БДУ ФСТЭК и Kubernetes. |
| `convert` | Пересоздать все промежуточные индексы из локальных исходных данных. |
| `merge` | Объединить промежуточные индексы, отсортировать и удалить идентичные строки. |
| `refresh` | Выполнить `merge` и применить текущие алиасы к объединённому индексу. |
| `verify` | Запустить `dpkg-cvecheck.py` относительно текущего каталога. Цель `make verify` из `src/` не проверяет сторонний Debian-пакет; используйте установленную команду `dpkg-cvecheck` из корня пакета. |

Для проверки перейдите в **корень проверяемого Debian-пакета**
(с `debian/control`, `debian/changelog` и `debian/cve/`)
и выполните установленный `dpkg-cvecheck`. Команда `dpkg-vexgen`
также запускается оттуда и самостоятельно вызывает проверку.

### Типовой цикл обновления

```bash
make build
```

Для пересоздания индекса из уже загруженных исходных данных можно выполнить:

```bash
make convert
make refresh
```

После изменения `aliases` достаточно `make refresh`, если промежуточные индексы уже актуальны.

**Важно:** `merge` не читает `aliases`. Если выполнить `merge` отдельно после `refresh`, ранее заменённые PURL могут вновь появиться в объединённом файле.

## Формат индекса

Каждая строка содержит ровно одну пару: PURL и идентификатор уязвимости, разделённые пробелом.

```text
pkg:protego/openjdk CVE-2024-12345
pkg:deb/debian_openjdk-11 CVE-2018-3136
pkg:kubernetes/kubernetes CVE-2025-1974
pkg:generic/example BDU:2022-03163
```

Примеры показывают формат записей; не все приведённые сочетания означают подтверждённую запись в текущем индексе.

Индекс не хранит описания CVE, уровни критичности и диапазоны уязвимых версий. Исходные данные источников остаются в соответствующих файлах `.buildcve/`.

Один CVE может соответствовать нескольким PURL. При `merge` удаляются **только полные дубликаты строк**: одинаковые PURL и идентификатор. Для сортировки и дедупликации используется системная `sort -u` с `LC_ALL=C`. Итог создаётся во временном файле и заменяется атомарно; промежуточные индексы не изменяются.

## Алиасы PURL

Файл **`aliases` в каталоге `nell/dev/dpkg-cvecheck/src/`** задаёт соответствия вариантов названий ПО одному целевому PURL. Первая колонка — каноническое имя для нашего индекса, остальные — его алиасы:

```text
pkg:protego/openjdk pkg:generic/openjdk pkg:generic/oracle/openjdk pkg:generic/redhat/java-17-openjdk pkg:generic/sun_openjdk
pkg:protego/python pkg:generic/python pkg:generic/python_cpython
pkg:protego/openssl pkg:generic/opensslsoftwarefoundation_openssl
```

Например, при конвертации строка

```text
pkg:generic/sun_openjdk CVE-2009-0723
```

должна превратиться в

```text
pkg:protego/openjdk CVE-2009-0723
```

Нормализация приводит имена к нижнему регистру, декодирует процентное кодирование, удаляет пробелы и заменяет неподдерживаемые символы подчёркиванием; при этом и исходный PURL, и записи `aliases` должны нормализоваться одинаково. Поддерживаются цепочки алиасов; конфликты и циклы считаются ошибками. Эти PURL используются как внутренние поисковые ключи и не обязательно совпадают с каноническим форматом Package URL сторонних экосистем.

`pkg:protego/<имя>` — принятый проектом целевой PURL для проверки собственных исходных пакетов. `verify` не должен повторно применять алиасы: он читает уже нормализованный `merged-purl.txt`.

## База решений о применимости и исправлениях

Решения располагаются в `debian/cve/` собираемого исходного пакета.
Имя **каждого обычного файла** должно точно совпадать с именем бинарного
пакета в поле `Package` файла `debian/control`:

```text
debian/
├── changelog
├── control
└── cve/
    ├── trivy
    └── trivy-server
```

Решения не наследуются между бинарными пакетами, даже если они собираются
из одного исходного пакета. Непустая строка имеет строгий формат
`CVEID статус # описание` либо `CVEID introduced:<версия> fixed:<версия> # описание`:

```text
CVE-2024-35192 introduced:0 fixed:0.51.2 # Утечка registry credentials устранена upstream в 0.51.2.
CVE-2026-26189 not_affected:component_not_present # trivy-action не входит в Trivy CLI.
```

- **`introduced:<version>`** — необязательный параметр перед `fixed`, нижняя
  включительная граница уязвимых версий. `introduced:0` означает условное
  начало истории версий, а не установленный факт появления уязвимости.
  Парсер запрещает `introduced` у `not_affected`; проверка требует
  `introduced < fixed` по сравнению версий `dpkg`. При отсутствии поля
  нижняя граница остаётся неизвестной, для будущего feed используется
  консервативная модель.
- **`fixed:<version>`** — вручную заданная первая версия, содержащая
  исправление. Проверка сравнивает с порогом полную версию из
  `debian/changelog` командой `dpkg --compare-versions ... ge ...`.
  При необходимости порог включает Debian-ревизию, например
  `fixed:0.71.0-2`; проверка не устанавливает наличие патча в исходниках.
- **`not_affected:<justification>`** — уязвимость неприменима. Допустимы
  только `component_not_present`, `vulnerable_code_not_present`,
  `vulnerable_code_not_in_execute_path`,
  `vulnerable_code_cannot_be_controlled_by_adversary` и
  `inline_mitigations_already_exist`.
Статусы `affected` и `under_investigation` не принимаются: подтверждённую
уязвимость необходимо исправить до выпуска, а отсутствие завершённого
триажа блокирует проверку. Прежний `not-apply` также недопустим.

Для каждой записи необходим символ `#` и **непустой текст после него**.
Этот текст записывается в поле OpenVEX `status_notes` без подмены
смысла. Допускаются пустые строки и целиком комментированные строки;
неизвестный статус, некорректный ID, отсутствие пояснения, дубликат ID
в одном файле, пустой файл решений либо неизвестное имя бинарного
пакета — ошибки. Одинаковая CVE может иметь разные решения в файлах
разных бинарных пакетов.

## Проверка пакета: `dpkg-cvecheck`

Утилита получает поля `Source` и `Version` из `debian/changelog`,
а допустимые бинарные пакеты — из `debian/control`. Как и раньше,
список потенциальных CVE ищется по `pkg:protego/<source-package>`
в установленном `/var/lib/cve/db.txt`.

Для **каждого** бинарного пакета проверяется полнота решений по всем
найденным CVE. Для каждой `fixed:` записи независимо от присутствия CVE
в новом индексе проверяется версия. Статусы, отличные от `fixed` и
`not_affected`, отклоняются. Отсутствие файла решений при наличии уязвимостей
блокирует проверку. Отсутствие файла при отсутствии CVE допустимо, но
никакой VEX не создаёт.

Проверка полноты консервативна: все CVE исходного пакета требуют
триажа отдельно для каждого бинарного пакета. Это не утверждение,
что уязвимость присутствует в каждом бинарном пакете.

## Генерация OpenVEX: `dpkg-vexgen`

После успешной проверки `dpkg-vexgen` создаёт по одному документу
**OpenVEX v0.2.0** на файл `debian/cve/<binary-package>`:

```text
debian/cve/trivy
    → debian/tmp/usr/share/vex/trivy.vex.json
debian/cve/trivy-server
    → debian/tmp/usr/share/vex/trivy-server.vex.json
```

Идентификатор продукта — versioned PURL
`pkg:deb/debian/<binary-package>@<version>`, где `<version>`
получена из `debian/changelog`, а зарезервированные символы
в версии закодированы по правилам Package URL. Эта модель
предполагает обычную сборку бинарных пакетов с версией исходного
пакета; binNMU и индивидуальное переопределение версий не поддерживаются.

Документ содержит `@context`, `@id`, `author`, `timestamp`,
`version` и `statements`. Идентификатор документа и порядок
заявлений воспроизводимы, время всегда берётся из даты
`debian/changelog`. Каждое заявление содержит `vulnerability.name`,
`products`, `status` и `status_notes` (дословный текст комментария,
без внешних пробелов).

- `fixed:<версия>` → `status: fixed`.
- `not_affected:<justification>` → `status: not_affected`
  вместе с `justification`.
- `affected` не допускается локальным форматом решений: подтверждённая
  уязвимость должна быть исправлена до выпуска.

`under_investigation` автоматически не генерируется. Генератор
не делает новых выводов о применимости CVE и не обращается к фидам.
Файлы записываются атомарно; невалидный триаж не должен приводить
к публикации частичных отчётов. Через `dh_install` отчёт попадает
**только** в соответствующий бинарный `.deb`.

### Практическое использование при Debian packaging

Из корня исходного пакета с установленным `dpkg-cvecheck` и индексом
`/var/lib/cve/db.txt`:

```sh
dpkg-cvecheck    # необязательный отдельный прогон проверки
dpkg-vexgen      # самостоятельно запускает dpkg-cvecheck
```

Генератор возвращает ошибку при неполном или недопустимом триаже и не
создаёт новые отчёты до успешного завершения проверки. Результат помещается
в `debian/tmp/usr/share/vex/`; перед `dh_install` файл каждого бинарного
пакета должен быть перечислен в соответствующем `debian/<binary-package>.install`.
Например, профиль Trivy использует:

```text
usr/bin/trivy usr/bin/
usr/share/vex/trivy.vex.json usr/share/vex/
```

Сборочная стадия [Trivy](../../../security/trivy/04_deb.Dockerfile) получает
`deb/dev/dpkg-cvecheck:0.1.0`, устанавливает его `.deb`, выполняет
`dh_prep`, копирует содержимое `bin/security/trivy` в `debian/tmp`, затем
вызывает `dpkg-vexgen` и `dh_install`. Из корня репозитория стадию можно
запустить командой:

```sh
make nell/security/trivy/04_deb.Dockerfile version=0.76.2
```

Фактический внутренний ключ индекса пока `pkg:protego/<source-package>`, а
PURL документа — `pkg:deb/debian/<binary-package>@<version>`; их сквозная
кастомизация и унификация отложена в [TODO](../../../../docs/TODO.md).

См. [спецификацию OpenVEX](https://github.com/openvex/spec)
и [план разработки](../../../doc/plans/dpkg-cvecheck.md).

## Диагностика

Если `verify` показывает ноль уязвимостей для пакета, который должен присутствовать в индексе, проверяйте результат преобразования и актуальность алиасов:

```bash
# Какие PURL содержат openjdk в объединённом индексе:
awk '$1 ~ /openjdk/ {print $1}' .buildcve/merged-purl.txt | sort -u

# Сколько строк сопоставлено с нашим каноническим именем:
grep -c '^pkg:protego/openjdk ' .buildcve/merged-purl.txt

# Применить новые алиасы к уже объединённому индексу:
make refresh

# Полностью пересобрать индекс с актуальными алиасами:
make convert
make refresh
```

`grep -c` возвращает ненулевой код, если совпадений нет; это не означает ошибку выполнения `verify`. Команда `jq` к файлам `*-purl.txt` неприменима: они содержат обычный текст `PURL CVE`, а не JSON.

## Зависимости

- Python 3 и стандартная библиотека Python для запуска скриптов (если конкретный коннектор не требует дополнительных библиотек).
- `sort` для объединения индексов.
- `dpkg-parsechangelog` и `dpkg` для проверки исходного пакета и сравнения Debian-версий.
- Сетевой доступ к внешним источникам для команды `get`; для `convert`, `merge`, `refresh` и `verify` данные уже должны находиться локально.

Путь `.buildcve/` — рабочий каталог данных и индексов внутри `nell/dev/dpkg-cvecheck/src/`; его содержимое не является частью исходного дерева репозитория. При запуске `verify` файл `debian/changelog` ищется относительно текущего рабочего каталога, поэтому проверку следует выполнять из корня собираемого Debian-пакета.
