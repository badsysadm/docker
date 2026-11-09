#!/usr/bin/env python3

import os
import shutil
import tempfile
import urllib.request

from pathlib import Path


URL = "https://kubernetes.io/docs/reference/issues-security/official-cve-feed/index.json"
DESTINATION = Path(".buildcve/kubernetes-cve.json")


def get():
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(
        dir=DESTINATION.parent,
        delete=False,
    ) as tmp:
        temporary = Path(tmp.name)

    try:
        with urllib.request.urlopen(URL, timeout=60) as response:
            with open(temporary, "wb") as dst:
                shutil.copyfileobj(response, dst)

        os.replace(temporary, DESTINATION)
    finally:
        temporary.unlink(missing_ok=True)

    print(f"Загружен Kubernetes CVE Feed: {DESTINATION}")


if __name__ == "__main__":
    get()
