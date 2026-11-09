"""Разбор решений CVE и списка бинарных Debian-пакетов."""

import re

from dataclasses import dataclass
from pathlib import Path


ID_PATTERN = re.compile(r"(?:CVE-\d{4}-\d{4,}|BDU:\d{4}-\d+)")
PACKAGE_PATTERN = re.compile(r"[a-z0-9][a-z0-9+.-]+")
JUSTIFICATIONS = frozenset({
    "component_not_present",
    "vulnerable_code_not_present",
    "vulnerable_code_not_in_execute_path",
    "vulnerable_code_cannot_be_controlled_by_adversary",
    "inline_mitigations_already_exist",
})


@dataclass(frozen=True)
class Decision:
    identifier: str
    status: str
    comment: str
    introduced: str | None = None


def binary_packages(path: Path = Path("debian/control")) -> list[str]:
    packages = []
    fields = {}

    def finish():
        package = fields.get("Package")
        if package is not None:
            if not PACKAGE_PATTERN.fullmatch(package):
                raise ValueError(f"{path}: неверное имя бинарного пакета: {package}")
            if package in packages:
                raise ValueError(f"{path}: повторный бинарный пакет: {package}")
            packages.append(package)
        fields.clear()

    with path.open(encoding="utf-8") as src:
        for number, line in enumerate(src, 1):
            if not line.strip():
                finish()
            elif line[0].isspace():
                continue
            else:
                key, separator, value = line.partition(":")
                if not separator:
                    raise ValueError(f"{path}:{number}: неверное поле control")
                fields[key] = value.strip()

    finish()
    if not packages:
        raise ValueError(f"{path}: отсутствуют поля Package")
    return packages


def load_decisions(path: Path) -> dict[str, Decision]:
    if not path.is_file() or path.is_symlink():
        raise ValueError(f"Отсутствует обычный файл решений: {path}")

    decisions = {}
    with path.open(encoding="utf-8") as src:
        for number, line in enumerate(src, 1):
            if not line.strip() or line.lstrip().startswith("#"):
                continue

            content, separator, comment = line.partition("#")
            if not separator or not comment.strip():
                raise ValueError(
                    f"{path}:{number}: требуется непустой комментарий после #"
                )

            fields = content.split()
            if len(fields) not in (2, 3):
                raise ValueError(
                    f"{path}:{number}: ожидается ID [introduced:<версия>] статус # описание триажа"
                )

            identifier = fields[0]
            status = fields[-1]
            introduced = None
            if len(fields) == 3:
                item = fields[1]
                if not item.startswith("introduced:") or not item.removeprefix("introduced:"):
                    raise ValueError(f"{path}:{number}: требуется introduced:<версия> перед fixed")
                introduced = item.removeprefix("introduced:")
            if not ID_PATTERN.fullmatch(identifier):
                raise ValueError(
                    f"{path}:{number}: неверный идентификатор {identifier}"
                )

            if status.startswith("fixed:"):
                if not status.removeprefix("fixed:"):
                    raise ValueError(f"{path}:{number}: не указана версия исправления")
            elif status.startswith("not_affected:"):
                if introduced is not None:
                    raise ValueError(f"{path}:{number}: introduced допустим только с fixed")
                justification = status.removeprefix("not_affected:")
                if justification not in JUSTIFICATIONS:
                    raise ValueError(
                        f"{path}:{number}: неверный justification {justification}"
                    )
            else:
                raise ValueError(f"{path}:{number}: недопустимый статус {status}")

            if identifier in decisions:
                raise ValueError(f"{path}:{number}: повторный {identifier}")

            decisions[identifier] = Decision(identifier, status, comment.strip(), introduced)

    if not decisions:
        raise ValueError(f"Пустой файл решений: {path}")
    return decisions
