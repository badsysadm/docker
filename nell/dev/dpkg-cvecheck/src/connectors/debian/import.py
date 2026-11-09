import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR


def update_debian_cve_database(
    path: Path = CVE_BUILD_DIR / "debian-cve.json",
    url: str = "https://security-tracker.debian.org/tracker/data/json",
) -> int:
    Path(path).parent.mkdir(parents=True, exist_ok=True)

    with urllib.request.urlopen(url) as response:
        data = response.read()

    with open(path, "wb") as db:
        db.write(data)

    return len(data)


if __name__ == "__main__":
    size = update_debian_cve_database()
    print(f"Сохранено байт: {size}")
