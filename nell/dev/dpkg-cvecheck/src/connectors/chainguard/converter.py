#!/usr/bin/env python3

import json
import re
import sys

from pathlib import Path
from urllib.parse import unquote

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR


SOURCE = CVE_BUILD_DIR / "chainguard-cve.jsonl"
DESTINATION = CVE_BUILD_DIR / "chainguard-purl.txt"
ALIASES = Path(__file__).resolve().parents[2] / "aliases"
CVE_PATTERN = re.compile(r"^CVE-\d{4}-\d{4,}$")


def normalize(value: str) -> str:
    value = unquote(value).lower().replace(" ", "")
    return re.sub(r"[^a-z0-9._+~-]", "_", value)


def normalize_purl(purl: str) -> str:
    if not purl.startswith("pkg:"):
        raise ValueError(f"Invalid PURL: {purl}")

    package_type, separator, package_name = purl[4:].partition("/")
    if not separator or not package_type or not package_name:
        raise ValueError(f"Invalid PURL: {purl}")

    return f"pkg:{normalize(package_type)}/{normalize(package_name)}"


def load_aliases(path: Path) -> dict[str, str]:
    aliases = {}

    with open(path, encoding="utf-8") as src:
        for number, line in enumerate(src, 1):
            line = line.split("#", 1)[0].strip()
            if not line:
                continue

            purls = [normalize_purl(purl) for purl in line.split()]
            target = purls[0]

            for alias in purls[1:]:
                if alias == target:
                    continue
                if alias in aliases and aliases[alias] != target:
                    raise ValueError(
                        f"Aliases line {number}: conflicting alias {alias}"
                    )
                aliases[alias] = target

    def resolve(purl: str) -> str:
        seen = set()
        while purl in aliases:
            if purl in seen:
                raise ValueError(f"Circular alias: {purl}")
            seen.add(purl)
            purl = aliases[purl]
        return purl

    return {alias: resolve(alias) for alias in aliases}


def convert():
    aliases = load_aliases(ALIASES)
    count = 0
    advisories = 0

    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    with (
        SOURCE.open(encoding="utf-8") as source,
        DESTINATION.open("w", encoding="utf-8") as output,
    ):
        for line in source:
            advisory = json.loads(line)
            advisories += 1
            identifiers = {
                identifier
                for identifier in advisory.get("upstream", [])
                if CVE_PATTERN.fullmatch(identifier)
            }

            if not identifiers:
                continue

            purls = set()
            for affected in advisory.get("affected", []):
                package = affected.get("package", {})
                ecosystem = package.get("ecosystem", "").lower()
                name = package.get("name", "")
                if ecosystem not in ("chainguard", "wolfi") or not name:
                    continue

                purl = normalize_purl(f"pkg:{ecosystem}/{name}")
                purls.add(aliases.get(purl, purl))

            for purl in sorted(purls):
                for identifier in sorted(identifiers):
                    output.write(f"{purl} {identifier}\n")
                    count += 1

    print(f"Chainguard OSV: {advisories} записей")
    print(f"Связей PURL/CVE: {count}")
    print(f"Алиасов: {len(aliases)}")
    print(f"Индекс: {DESTINATION}")


if __name__ == "__main__":
    convert()
