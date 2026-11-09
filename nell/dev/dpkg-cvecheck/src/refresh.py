#!/usr/bin/env python3

import os
import re
import subprocess
import tempfile

from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parent
ALIASES = ROOT / "aliases"
from config import DATA

MERGED = DATA / "merged-purl.txt"


def normalize(value: str) -> str:
    value = unquote(value).lower().replace(" ", "")
    return re.sub(r"[^\w.+~-]", "_", value)


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

    return {
        alias: resolve(alias)
        for alias in aliases
    }


def refresh():
    aliases = load_aliases(ALIASES)

    if not MERGED.is_file():
        raise FileNotFoundError(MERGED)

    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=MERGED.parent,
        delete=False,
    ) as tmp:
        temporary = Path(tmp.name)

    changed = 0
    total = 0

    try:
        with open(MERGED, encoding="utf-8") as src, open(
            temporary, "w", encoding="utf-8"
        ) as dst:
            for line in src:
                purl, identifier = line.split(None, 1)

                normalized = normalize_purl(purl)
                target = aliases.get(normalized, normalized)

                if target != purl:
                    changed += 1

                dst.write(f"{target} {identifier.strip()}\n")
                total += 1

        subprocess.run(
            ["sort", "-u", "-o", str(temporary), str(temporary)],
            env={**os.environ, "LC_ALL": "C"},
            check=True,
        )

        os.replace(temporary, MERGED)
    finally:
        temporary.unlink(missing_ok=True)

    print(f"Обработано связей: {total}")
    print(f"Изменено PURL: {changed}")
    print(f"Алиасов: {len(aliases)}")
    print(f"Обновлённый индекс: {MERGED}")


if __name__ == "__main__":
    refresh()
