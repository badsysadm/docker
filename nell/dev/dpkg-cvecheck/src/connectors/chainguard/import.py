#!/usr/bin/env python3

import json
import os
import sys
import tarfile
import tempfile
import urllib.request

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR


URL = "https://packages.cgr.dev/chainguard/v3/osv/chainguard-osv.tar.gz"
DESTINATION = CVE_BUILD_DIR / "chainguard-cve.jsonl"


def get():
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    fd, temporary = tempfile.mkstemp(
        prefix=".chainguard-cve-",
        suffix=".jsonl.tmp",
        dir=DESTINATION.parent,
    )

    count = 0

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            with urllib.request.urlopen(URL, timeout=120) as response:
                with tarfile.open(fileobj=response, mode="r|gz") as archive:
                    for member in archive:
                        if not member.isfile() or not member.name.endswith(".json"):
                            continue

                        stream = archive.extractfile(member)
                        if stream is None:
                            raise ValueError(f"Cannot read Chainguard advisory: {member.name}")

                        with stream:
                            advisory = json.load(stream)

                        if not advisory.get("id", "").startswith("CGA-"):
                            raise ValueError(f"Unexpected Chainguard advisory: {member.name}")

                        output.write(
                            json.dumps(
                                advisory,
                                ensure_ascii=False,
                                separators=(",", ":"),
                            ) + "\n"
                        )
                        count += 1

        if count == 0:
            raise ValueError("Chainguard archive contains no OSV advisories")

        os.replace(temporary, DESTINATION)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

    print(f"Сохранено Chainguard OSV: {count}")
    print(f"Файл: {DESTINATION}")


if __name__ == "__main__":
    get()
