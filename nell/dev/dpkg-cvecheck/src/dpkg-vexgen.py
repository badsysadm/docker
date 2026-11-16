#!/usr/bin/env python3

"""Генерация отдельных OpenVEX-отчётов для бинарных Debian-пакетов."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import uuid

from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.parse import quote

from triage import binary_packages, load_decisions


DECISIONS = Path("debian/cve")
DESTINATION = Path("debian/tmp/usr/share/vex")
CONTEXT = "https://openvex.dev/ns/v0.2.0"


def changelog_field(name):
    return subprocess.check_output(
        ["dpkg-parsechangelog", "-l", "debian/changelog", "-S", name],
        text=True,
    ).strip()


def issued_at():
    instant = parsedate_to_datetime(changelog_field("Date"))
    return instant.astimezone(timezone.utc).isoformat(timespec="seconds").replace(
        "+00:00", "Z"
    )


def verify():
    installed = shutil.which("dpkg-cvecheck")
    if installed:
        command = [installed]
    else:
        local = Path(__file__).resolve().with_name("dpkg-cvecheck.py")
        if not local.is_file():
            raise FileNotFoundError("dpkg-cvecheck не найден")
        command = [sys.executable, str(local)]

    subprocess.run(command, check=True)


def document(package, version, author, timestamp, decisions):
    product = f"pkg:deb/debian/{package}@{quote(version, safe='')}"
    statements = []

    for identifier, decision in sorted(decisions.items()):
        status, _, parameter = decision.status.partition(":")
        statement = {
            "vulnerability": {"name": identifier},
            "products": [{"@id": product}],
            "status": status,
            "status_notes": decision.comment,
        }
        if status == "not_affected":
            statement["justification"] = parameter
        statements.append(statement)

    identity = json.dumps(
        [product, author, timestamp, statements],
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )

    return {
        "@context": CONTEXT,
        "@id": f"urn:uuid:{uuid.uuid5(uuid.NAMESPACE_URL, identity)}",
        "author": author,
        "timestamp": timestamp,
        "version": 1,
        "statements": statements,
    }


def generate():
    packages = set(binary_packages())
    version = changelog_field("Version")
    author = changelog_field("Maintainer")
    timestamp = issued_at()

    # Validate all source decision files before creating any report.
    reports = {}
    if DECISIONS.exists():
        if not DECISIONS.is_dir():
            raise ValueError(f"Не является каталогом решений: {DECISIONS}")

        for path in sorted(DECISIONS.iterdir()):
            if not path.is_file() or path.is_symlink():
                raise ValueError(f"Недопустимый объект в каталоге решений: {path}")
            if path.name not in packages:
                raise ValueError(
                    f"Нет бинарного пакета {path.name} в debian/control"
                )
            decisions = load_decisions(path)
            reports[path.name] = document(
                path.name, version, author, timestamp, decisions
            )

    # The checker is the authoritative gate for completeness and fixed versions.
    verify()

    if not reports:
        print("Файлы решений отсутствуют; VEX-отчёты не создаются")
        return

    DESTINATION.mkdir(parents=True, exist_ok=True)
    # Prepare all outputs before replacing any existing file.
    staged = {}
    try:
        for package, report in sorted(reports.items()):
            fd, temporary = tempfile.mkstemp(
                dir=DESTINATION, prefix=f".{package}-", suffix=".tmp"
            )
            staged[package] = Path(temporary)
            with os.fdopen(fd, "w", encoding="utf-8") as output:
                json.dump(report, output, ensure_ascii=False, indent=2)
                output.write("\n")

        for package, temporary in sorted(staged.items()):
            target = DESTINATION / f"{package}.vex.json"
            os.replace(temporary, target)
            print(f"OpenVEX: {target}")
    finally:
        for temporary in staged.values():
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        generate()
    except (
        OSError,
        ValueError,
        OverflowError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"Ошибка vexgen: {error}", file=sys.stderr)
        sys.exit(1)
