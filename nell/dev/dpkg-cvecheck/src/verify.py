#!/usr/bin/env python3

import re
import shlex
import subprocess
import sys

from pathlib import Path


ROOT = Path(__file__).resolve().parent
#DB = ROOT / "debian/protego/cve"
DB = Path("debian/protego/cve")
INDEX = Path("/var/lib/cve/db.txt")

ID_PATTERN = re.compile(r"(?:CVE-\d{4}-\d{4,}|BDU:\d{4}-\d+)")


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


def version_ge(current, required):
    result = subprocess.run(
        ["dpkg", "--compare-versions", current, "ge", required],
        check=False,
    )

    if result.returncode == 2:
        raise ValueError(
            f"Ошибка сравнения версий: {current} и {required}"
        )

    return result.returncode == 0


def load_decisions(directory):
    if not directory.is_dir():
        raise FileNotFoundError(
            f"Не найден каталог базы уязвимостей: {directory}"
        )

    files = sorted(path for path in directory.iterdir() if path.is_file())

    if not files:
        raise ValueError(
            f"Каталог базы уязвимостей пуст: {directory}"
        )

    decisions = {}

    for path in files:
        with open(path, encoding="utf-8") as src:
            for number, line in enumerate(src, 1):
                fields = shlex.split(line, comments=True)

                if not fields:
                    continue

                if len(fields) != 2:
                    raise ValueError(
                        f"{path}:{number}: ожидается ID и значение"
                    )

                identifier, status = fields

                if not ID_PATTERN.fullmatch(identifier):
                    raise ValueError(
                        f"{path}:{number}: неверный идентификатор {identifier}"
                    )

                if status != "not-apply" and not (
                    status.startswith("fixed:") and len(status) > 6
                ):
                    raise ValueError(
                        f"{path}:{number}: неверное значение {status}"
                    )

                if identifier in decisions:
                    raise ValueError(
                        f"{path}:{number}: повторный {identifier}"
                    )

                decisions[identifier] = status

    return decisions


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

    vulnerabilities = index_identifiers(INDEX, purl)

#    directory = DB / package
    directory = DB
    decisions = load_decisions(directory) if directory.is_dir() else {}

    errors = []

    if vulnerabilities and not directory.is_dir():
        errors.append(
            f"Не найден каталог базы уязвимостей для пакета {package}: {directory}"
        )

    for identifier in sorted(vulnerabilities):
        if identifier not in decisions:
            errors.append(
                f"{identifier}: отсутствует решение в локальной базе"
            )

    for identifier, status in sorted(decisions.items()):
        if status == "not-apply":
            continue

        required = status.removeprefix("fixed:")

        if not version_ge(version, required):
            errors.append(
                f"{identifier}: версия {version} ниже {required}"
            )

    print(f"Пакет: {package}")
    print(f"Версия: {version}")
    print(f"PURL: {purl}")
    print(f"Уязвимостей в индексе: {len(vulnerabilities)}")
    print(f"Решений в локальной базе: {len(decisions)}")

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
