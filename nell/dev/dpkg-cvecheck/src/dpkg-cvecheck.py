#!/usr/bin/env python3

import subprocess
import sys

from pathlib import Path

from triage import binary_packages, load_decisions


DB = Path("debian/cve")
INDEX = Path("/var/lib/cve/db.txt")


def changelog_field(field):
    return subprocess.check_output(
        [
            "dpkg-parsechangelog",
            "-l",
            "debian/changelog",
            "-S",
            field,
        ],
        text=True,
    ).strip()


def version_compare(current, operator, required):
    result = subprocess.run(
        ["dpkg", "--compare-versions", current, operator, required],
        check=False,
    )

    if result.returncode == 2:
        raise ValueError(
            f"Ошибка сравнения версий: {current} и {required}"
        )

    return result.returncode == 0


def version_ge(current, required):
    return version_compare(current, "ge", required)


def index_identifiers(path, purl):
    if not path.is_file():
        raise FileNotFoundError(path)

    found = set()

    with open(path, encoding="utf-8") as src:
        for line in src:
            current_purl, separator, identifier = (
                line.rstrip("\n").partition(" ")
            )

            if separator and current_purl == purl:
                found.add(identifier.strip())

    return found


def verify():
    package = changelog_field("Source")
    version = changelog_field("Version")
    purl = f"pkg:protego/{package}"
    packages = binary_packages()

    vulnerabilities = index_identifiers(INDEX, purl)
    errors = []
    total_decisions = 0

    if DB.exists() and not DB.is_dir():
        raise ValueError(f"Не является каталогом решений: {DB}")

    if DB.is_dir():
        for path in sorted(DB.iterdir()):
            if not path.is_file() or path.is_symlink():
                raise ValueError(f"Недопустимый объект в каталоге решений: {path}")
            if path.name not in packages:
                raise ValueError(
                    f"Файл решений {path} не соответствует бинарному пакету "
                    "из debian/control"
                )

    for binary in packages:
        path = DB / binary
        if not path.exists():
            if vulnerabilities:
                errors.append(
                    f"{binary}: не найден файл решений {path}"
                )
            continue

        decisions = load_decisions(path)
        total_decisions += len(decisions)

        for identifier in sorted(vulnerabilities):
            if identifier not in decisions:
                errors.append(
                    f"{binary}: {identifier}: отсутствует решение в локальной базе"
                )

        for identifier, decision in sorted(decisions.items()):
            if not decision.status.startswith("fixed:"):
                continue

            required = decision.status.removeprefix("fixed:")
            if decision.introduced is not None and not version_compare(
                decision.introduced, "lt", required
            ):
                errors.append(
                    f"{binary}: {identifier}: introduced {decision.introduced} "
                    f"должен быть ниже fixed {required}"
                )
            if not version_ge(version, required):
                errors.append(
                    f"{binary}: {identifier}: версия {version} ниже {required}"
                )

    print(f"Исходный пакет: {package}")
    print(f"Версия: {version}")
    print(f"PURL: {purl}")
    print(f"Бинарных пакетов: {len(packages)}")
    print(f"Уязвимостей в индексе: {len(vulnerabilities)}")
    print(f"Решений в локальной базе: {total_decisions}")

    if errors:
        print("\nПроверка не пройдена:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1

    print("Проверка пройдена")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(verify())
    except (
        OSError,
        ValueError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"Ошибка verify: {error}", file=sys.stderr)
        sys.exit(1)
