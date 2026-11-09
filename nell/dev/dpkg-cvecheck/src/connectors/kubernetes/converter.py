#!/usr/bin/env python3

import json
import re
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(".buildcve/kubernetes-cve.json")
DESTINATION = Path(".buildcve/kubernetes-purl.txt")
ALIASES = ROOT / "aliases"

CVE = re.compile(r"^CVE-\d{4}-\d{4,}$")

VERSION = re.compile(
    r"(?<![\w.])(?:[<>=]+\s*)?v?\d+\.\d+|(?:[<>=]+\s*)v?\d+",
    re.I,
)

HEADING = re.compile(r"^\s*(?:#{1,6}\s*|\*\*)(.+?)(?:\*\*)?\s*$")


def normalize(value):
    value = unquote(value).lower().replace(" ", "")
    return re.sub(r"[^\w.+~-]", "_", value)


def normalize_purl(purl):
    if not purl.startswith("pkg:"):
        raise ValueError(f"Invalid PURL: {purl}")

    kind, separator, name = purl[4:].partition("/")

    if not separator or not kind or not name:
        raise ValueError(f"Invalid PURL: {purl}")

    return f"pkg:{normalize(kind)}/{normalize(name)}"


def load_aliases(path):
    aliases = {}

    with path.open(encoding="utf-8") as source:
        for number, line in enumerate(source, 1):
            fields = line.split("#", 1)[0].split()

            if not fields:
                continue

            target, *alternatives = [
                normalize_purl(value) for value in fields
            ]

            for name in alternatives:
                if name == target:
                    continue

                if name in aliases and aliases[name] != target:
                    raise ValueError(
                        f"{path}:{number}: conflicting alias {name}"
                    )

                aliases[name] = target

    def resolve(name):
        visited = set()

        while name in aliases:
            if name in visited:
                raise ValueError(f"Circular alias: {name}")

            visited.add(name)
            name = aliases[name]

        return name

    return {
        name: resolve(name)
        for name in aliases
    }


def sections(content):
    current = None
    in_code = False

    for line in content.splitlines():
        text = line.strip()

        if text.startswith("```"):
            in_code = not in_code
            continue

        if in_code:
            continue

        match = HEADING.match(text)

        is_heading = (
            text.startswith("#")
            or (text.startswith("**") and text.endswith("**"))
        )

        if is_heading and match:
            heading = match.group(1).strip(" *:").lower()

            if heading.startswith("affected component"):
                current = "components"
            elif heading.startswith("affected version"):
                current = "versions"
            else:
                current = None

            continue

        if text.lower().rstrip(":") in (
            "affected components",
            "affected component",
            "affected versions",
        ):
            current = (
                "components"
                if "component" in text.lower()
                else "versions"
            )
            continue

        if current and text:
            yield current, text


def osv_components(content):
    components = set()
    collecting = False
    buffer = []

    for line in content.splitlines():
        text = line.strip()

        if not collecting:
            if text.lower() == "```json osv":
                collecting = True
                buffer = []
            continue

        if text.startswith("```"):
            data = json.loads("\n".join(buffer))

            for affected in data.get("affected", []):
                package = affected.get("package") or {}
                name = package.get("name")

                if isinstance(name, str) and name.strip():
                    components.add(name.strip())

            collecting = False
        else:
            buffer.append(line)

    return components


def clean(name):
    name = re.sub(
        r"^[\s*\-`]+|[\s*`:.]+$",
        "",
        name,
    )

    name = re.sub(
        r"^(?:all\s+)?versions?\s+of\s+(?:the\s+)?",
        "",
        name,
        flags=re.I,
    )

    name = re.sub(
        r"^all\s+",
        "",
        name,
        flags=re.I,
    )

    if "-" in name:
        name = re.sub(
            r"\s+(?:controller|binary)\s*$",
            "",
            name,
            flags=re.I,
        )

    name = re.sub(
        r"\s+versions?(?:\s+prior\s+to)?$",
        "",
        name,
        flags=re.I,
    )

    name = name.strip()

    if not name:
        return ""

    if name.lower() in (
        "all",
        "versions",
        "version",
        "affected",
        "the following",
        "none",
    ):
        return ""

    if len(name.split()) > 6:
        return ""

    if any(char in name for char in "[]()!?#:"):
        return ""

    return name


def split_names(name):
    return {
        component
        for part in name.split("/")
        if (component := clean(part))
    }


def from_versions(line):
    line = re.sub(r"^\s*[-*]\s*", "", line)
    line = line.strip().replace("`", "")

    if not line:
        return set()

    # Формат: kubelet: <= v1.34.11

    if ":" in line:
        name, remainder = line.split(":", 1)

        if VERSION.search(remainder) and not VERSION.search(name):
            return split_names(name)

    # Формат: All versions of the CSI Driver for SMB prior to ...

    parts = re.split(
        r"\s+prior\s+to\s+",
        line,
        maxsplit=1,
        flags=re.I,
    )

    if (
        len(parts) == 2
        and parts[0].lower().startswith("all versions of ")
    ):
        return split_names(parts[0])

    # Формат: kubectl v1.34.0 to v1.34.11
    # Формат: Kubernetes Image Builder versions <= v0.1.44

    match = VERSION.search(line)

    if not match or match.start() == 0:
        return set()

    name = line[:match.start()].strip(" -:<>=\\")

    name = re.sub(
        r"\s+versions?$",
        "",
        name,
        flags=re.I,
    )

    if name.lower().startswith((
        "the following",
        "as a result",
        "eol versions",
        "affected versions",
        "this issue",
        "all clusters",
        "these",
    )):
        return set()

    return split_names(name)


def from_components(line):
    line = re.sub(r"^\s*[-*]\s*", "", line)
    line = line.strip().replace("`", "")

    # Формат: This bug affects ingress-nginx.

    match = re.search(
        r"\b(?:this bug|this issue|this vulnerability)"
        r" affects\s+([\w.-]+)",
        line,
        flags=re.I,
    )

    if match:
        return split_names(match.group(1))

    if len(line.split()) > 6:
        return set()

    if line.lower().startswith((
        "any ",
        "all ",
        "if ",
        "you ",
        "environments ",
        "clusters ",
        "users ",
        "components ",
        "the ",
    )):
        return set()

    return split_names(line)


def extract_components(item):
    content = item.get("content_text") or ""

    # Сначала структурированные данные OSV.

    components = osv_components(content)

    if components:
        return components

    # Затем явно обозначенные разделы бюллетеня.

    for section, line in sections(content):
        if section == "components":
            components.update(from_components(line))
        else:
            components.update(from_versions(line))

    return components


def convert():
    aliases = load_aliases(ALIASES)

    with SOURCE.open(encoding="utf-8") as source:
        feed = json.load(source)

    entries = set()
    identifiers = set()
    unknown = []

    for item in feed["items"]:
        identifier = item.get("id", "")

        if not CVE.fullmatch(identifier):
            raise ValueError(
                f"Unexpected vulnerability identifier: {identifier}"
            )

        identifiers.add(identifier)

        components = extract_components(item)

        if not components:
            components = {"kubernetes"}
            unknown.append(identifier)

        for component in components:
            if component.lower() == "kubernetes":
                purl = "pkg:kubernetes/kubernetes"
            else:
                purl = normalize_purl(
                    f"pkg:kubernetes/kubernetes_{component}"
                )

            purl = aliases.get(purl, purl)
            entries.add((purl, identifier))

    indexed = {
        identifier
        for _, identifier in entries
    }

    if indexed != identifiers:
        raise RuntimeError(
            f"Missing CVEs: {sorted(identifiers - indexed)}"
        )

    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    with DESTINATION.open("w", encoding="utf-8") as output:
        for purl, identifier in sorted(entries):
            output.write(f"{purl} {identifier}\n")

    print(f"CVE в источнике: {len(identifiers)}")
    print(f"CVE в индексе: {len(indexed)}")
    print(f"Связей PURL/CVE: {len(entries)}")
    print(f"Без определённого компонента: {len(unknown)}")
    print(f"Алиасов: {len(aliases)}")
    print(f"Индекс: {DESTINATION}")

    if unknown:
        print(
            "Неопределённые CVE: "
            + ", ".join(sorted(unknown))
        )


if __name__ == "__main__":
    convert()
