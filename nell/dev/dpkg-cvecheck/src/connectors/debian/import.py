import json
import os
import sys
import tempfile
import urllib.request

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR
from download import retry_download


def update_debian_cve_database(
    path: Path = CVE_BUILD_DIR / "debian-cve.json",
    url: str = "https://security-tracker.debian.org/tracker/data/json",
) -> int:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)

    def fetch():
        with urllib.request.urlopen(url, timeout=120) as response:
            data = response.read()

        feed = json.loads(data)
        if not isinstance(feed, dict):
            raise ValueError("Debian Security Tracker: неожиданный формат JSON")
        return data

    data = retry_download("Debian Security Tracker", fetch)

    fd, temporary = tempfile.mkstemp(dir=output.parent, prefix=".debian-cve-")
    try:
        with os.fdopen(fd, "wb") as db:
            db.write(data)
        os.replace(temporary, output)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

    return len(data)


if __name__ == "__main__":
    size = update_debian_cve_database()
    print(f"Сохранено байт: {size}")
