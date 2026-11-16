#!/usr/bin/env python3

import json
import os
import shutil
import sys
import tempfile
import urllib.request

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR
from download import retry_download


URL = "https://kubernetes.io/docs/reference/issues-security/official-cve-feed/index.json"
DESTINATION = CVE_BUILD_DIR / "kubernetes-cve.json"


def get():
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)

    def fetch():
        with tempfile.NamedTemporaryFile(dir=DESTINATION.parent, delete=False) as tmp:
            temporary = Path(tmp.name)

        try:
            with urllib.request.urlopen(URL, timeout=60) as response:
                with open(temporary, "wb") as dst:
                    shutil.copyfileobj(response, dst)

            with temporary.open(encoding="utf-8") as src:
                feed = json.load(src)

            if not isinstance(feed, dict) or not isinstance(feed.get("items"), list):
                raise ValueError("Kubernetes: неожиданный формат JSON-фида")

            os.replace(temporary, DESTINATION)
        finally:
            temporary.unlink(missing_ok=True)

    retry_download("Kubernetes", fetch)
    print(f"Загружен Kubernetes CVE Feed: {DESTINATION}")


if __name__ == "__main__":
    get()
