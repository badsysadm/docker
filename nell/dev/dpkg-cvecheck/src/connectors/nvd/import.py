import sys
import gzip
import json
import os
import tempfile
import time
import urllib.request

from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import CVE_BUILD_DIR


URL = "https://nvd.nist.gov/feeds/json/cve/2.0/nvdcve-2.0-{year}.json.gz"


def update_nvd_cve_database(
    path: Path = CVE_BUILD_DIR / "nvd-cve.jsonl",
    url: str = URL,
    first_year: int = 2002,
    last_year: int | None = None,
) -> int:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)

    if last_year is None:
        last_year = datetime.now().year

    count = 0

    fd, temporary_path = tempfile.mkstemp(
        prefix=".nvd-cve-",
        suffix=".jsonl.tmp",
        dir=output.parent,
    )

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as db:
            for year in range(first_year, last_year + 1):
                feed_url = url.format(year=year)

                print(f"Загрузка NVD {year}...", flush=True)

                request = urllib.request.Request(
                    feed_url,
                    headers={
                        "User-Agent": "CVE-Collector/1.0",
                    },
                )

                for attempt in range(1, 4):
                    try:
                        with urllib.request.urlopen(
                            request,
                            timeout=120,
                        ) as response:
                            with gzip.GzipFile(fileobj=response) as compressed:
                                feed = json.load(compressed)
                        break
                    except (EOFError, OSError, json.JSONDecodeError) as error:
                        if attempt == 3:
                            raise
                        print(
                            f"NVD {year}: ошибка загрузки ({error}), "
                            f"повтор {attempt}/2...",
                            flush=True,
                        )
                        time.sleep(5 * attempt)

                vulnerabilities = feed["vulnerabilities"]

                if feed["totalResults"] != len(vulnerabilities):
                    raise ValueError(
                        f"NVD {year}: expected "
                        f"{feed['totalResults']} records, "
                        f"got {len(vulnerabilities)}"
                    )

                for item in vulnerabilities:
                    cve = item["cve"]

                    db.write(
                        json.dumps(
                            cve,
                            ensure_ascii=False,
                            separators=(",", ":"),
                        ) + "\n"
                    )

                    count += 1

                print(
                    f"NVD {year}: {len(vulnerabilities)} CVE, "
                    f"всего {count}",
                    flush=True,
                )

        os.replace(temporary_path, output)

    finally:
        if os.path.exists(temporary_path):
            os.unlink(temporary_path)

    return count


if __name__ == "__main__":
    print(
        f"Сохранено записей: {update_nvd_cve_database()}"
    )
