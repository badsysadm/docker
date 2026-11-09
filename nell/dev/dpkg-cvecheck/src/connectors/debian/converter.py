import sys
import json
import re

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR
from urllib.parse import unquote


SOURCE = CVE_BUILD_DIR / "debian-cve.json"
DESTINATION = CVE_BUILD_DIR / "debian-purl.txt"
ALIASES = str(Path(__file__).resolve().parents[2] / "aliases")

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


def make_purl(package: str) -> str:
    return normalize_purl(f"pkg:deb/debian/{package}")


def load_aliases(path: str) -> dict[str, str]:
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


def convert_debian_database(
    source: Path = SOURCE,
    destination: Path = DESTINATION,
    aliases_file: str = ALIASES,
) -> int:
    aliases = load_aliases(aliases_file)

    with open(source, encoding="utf-8") as src:
        feed = json.load(src)

    output = Path(destination)
    output.parent.mkdir(parents=True, exist_ok=True)

    count = 0

    with open(output, "w", encoding="utf-8") as dst:
        for package, vulnerabilities in feed.items():
            purl = make_purl(package)
            purl = aliases.get(purl, purl)

            for cve_id in vulnerabilities:
                if not cve_id.startswith("CVE-"):
                    continue

                dst.write(f"{purl} {cve_id}\n")
                count += 1

    print(f"Связей PURL/CVE: {count}")
    print(f"Алиасов: {len(aliases)}")

    return count


if __name__ == "__main__":
    convert_debian_database()
