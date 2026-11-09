import re
import xml.etree.ElementTree as ET

from pathlib import Path
from urllib.parse import unquote


SOURCE = ".buildcve/fstec-cve.xml"
DESTINATION = ".buildcve/fstec-purl.txt"
ALIASES = str(Path(__file__).resolve().parents[2] / "aliases")

CVE_PATTERN = re.compile(r"^CVE-\d{4}-\d{4,}$")
BDU_PATTERN = re.compile(r"^BDU:\d{4}-\d+$")


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


def make_purl(vendor: str, name: str) -> str:
    vendor = vendor.strip()
    name = name.strip()

    if not name:
        return ""

    if vendor.lower() in ("n/a", "na", "none", "unknown", "-", "*"):
        vendor = ""

    if vendor:
        return normalize_purl(f"pkg:bdu/{vendor}/{name}")

    return normalize_purl(f"pkg:bdu/{name}")


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


def extract_identifiers(vul):
    cves = {
        value
        for identifier in vul.findall("./identifiers/identifier")
        if (value := (identifier.text or "").strip())
        and CVE_PATTERN.fullmatch(value)
    }

    if cves:
        yield from sorted(cves)
    else:
        bdu = (vul.findtext("identifier") or "").strip()

        if BDU_PATTERN.fullmatch(bdu):
            yield bdu


def extract_software(vul):
    for soft in vul.findall("./vulnerable_software/soft"):
        vendor = soft.findtext("vendor") or ""
        name = soft.findtext("name") or ""

        purl = make_purl(vendor, name)

        if purl:
            yield purl


def convert_fstec_database(
    source: str = SOURCE,
    destination: str = DESTINATION,
    aliases_file: str = ALIASES,
) -> int:
    aliases = load_aliases(aliases_file)

    output = Path(destination)
    output.parent.mkdir(parents=True, exist_ok=True)

    count = 0
    unmatched = 0
    bdu_count = 0
    cve_count = 0

    context = ET.iterparse(source, events=("start", "end"))
    _, root = next(context)

    with open(output, "w", encoding="utf-8") as dst:
        for event, element in context:
            if event != "end" or element.tag != "vul":
                continue

            identifiers = set(extract_identifiers(element))

            purls = {
                aliases.get(purl, purl)
                for purl in extract_software(element)
            }

            if not identifiers or not purls:
                unmatched += 1
            else:
                for purl in sorted(purls):
                    for identifier in sorted(identifiers):
                        dst.write(f"{purl} {identifier}\n")
                        count += 1

                        if identifier.startswith("BDU:"):
                            bdu_count += 1
                        else:
                            cve_count += 1

            element.clear()
            root.clear()

    print(f"Связей PURL/BDU: {bdu_count}")
    print(f"Связей PURL/CVE: {cve_count}")
    print(f"Всего связей: {count}")
    print(f"Записей без идентификатора или ПО: {unmatched}")
    print(f"Алиасов: {len(aliases)}")

    return count


if __name__ == "__main__":
    convert_fstec_database()
