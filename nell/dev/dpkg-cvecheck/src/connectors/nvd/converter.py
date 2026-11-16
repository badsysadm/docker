import sys
import json
import re

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR
from urllib.parse import unquote


SOURCE = CVE_BUILD_DIR / "nvd-cve.jsonl"
DESTINATION = CVE_BUILD_DIR / "nvd-purl.txt"
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


def make_purl(vendor: str, name: str) -> str:
    vendor = vendor.strip().lower()

    if vendor in ("n/a", "na", "none", "unknown", "-", "*"):
        vendor = ""

    if vendor:
        return normalize_purl(f"pkg:nvd/{vendor}/{name}")

    return normalize_purl(f"pkg:nvd/{name}")


def split_cpe(criteria: str) -> list[str]:
    parts = []
    current = []
    escaped = False

    for char in criteria:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            parts.append("".join(current))
            current = []
        else:
            current.append(char)

    if escaped:
        current.append("\\")

    parts.append("".join(current))

    if len(parts) != 13 or parts[:2] != ["cpe", "2.3"]:
        raise ValueError(f"Invalid CPE: {criteria}")

    return parts


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
                        f"Aliases line {number}: "
                        f"conflicting alias {alias}"
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


def extract_affected(cve: dict):
    for affected in cve.get("affected", []):
        for item in affected.get("affectedData", []):
            yield make_purl(
                item.get("vendor", ""),
                item.get("packageName") or item["product"],
            )


def extract_cpe(cve: dict):
    def walk(node):
        for match in node.get("cpeMatch", []):
            parts = split_cpe(match["criteria"])
            yield make_purl(parts[3], parts[4])

        for child in node.get("children", []):
            yield from walk(child)

    for configuration in cve.get("configurations", []):
        for node in configuration.get("nodes", []):
            yield from walk(node)


def convert_nvd_database(
    source: Path = SOURCE,
    destination: Path = DESTINATION,
    aliases_file: str = ALIASES,
) -> int:
    aliases = load_aliases(aliases_file)

    output = Path(destination)
    output.parent.mkdir(parents=True, exist_ok=True)

    count = 0
    unmatched = 0

    with (
        open(source, encoding="utf-8") as src,
        open(output, "w", encoding="utf-8") as dst,
    ):
        for line in src:
            cve = json.loads(line)
            cve_id = cve["id"]

            purls = {
                aliases.get(purl, purl)
                for extract in (extract_affected, extract_cpe)
                for purl in extract(cve)
            }

            if not purls:
                unmatched += 1
                continue

            for purl in sorted(purls):
                dst.write(f"{purl} {cve_id}\n")
                count += 1

    print(f"Связей PURL/CVE: {count}")
    print(f"CVE без идентификатора ПО: {unmatched}")
    print(f"Алиасов: {len(aliases)}")

    return count


if __name__ == "__main__":
    convert_nvd_database()
