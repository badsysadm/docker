#!/usr/bin/env python3

import json
import re
from pathlib import Path


SOURCE = Path(".buildcve/kubernetes-cve.json")
DESTINATION = Path(".buildcve/kubernetes-purl.txt")
PURL = "pkg:kubernetes/kubernetes"
CVE = re.compile(r"^CVE-\d{4}-\d{4,}$")


def convert():
    with SOURCE.open(encoding="utf-8") as source:
        feed = json.load(source)

    identifiers = set()

    for item in feed["items"]:
        identifier = item.get("id", "")

        if not CVE.fullmatch(identifier):
            raise ValueError(
                f"Unexpected vulnerability identifier: {identifier}"
            )

        identifiers.add(identifier)

    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    with DESTINATION.open("w", encoding="utf-8") as output:
        for identifier in sorted(identifiers):
            output.write(f"{PURL} {identifier}\n")

    print(f"CVE в источнике: {len(feed['items'])}")
    print(f"CVE в индексе: {len(identifiers)}")
    print(f"Индекс: {DESTINATION}")


if __name__ == "__main__":
    convert()
