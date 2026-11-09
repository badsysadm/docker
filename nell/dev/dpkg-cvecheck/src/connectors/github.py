import sys
import json
import os
import tarfile
import tempfile
import urllib.request

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from config import DATA


URL = "https://github.com/github/advisory-database/archive/refs/heads/main.tar.gz"

def make_purl(package: dict) -> str:
    return f"pkg:{package['ecosystem']}/{package['name']}".lower()

def update_github_cve_database(
    path: Path = DATA / "github-cve.jsonl",
    url: str = URL,
) -> int:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)

    categories = {"github-reviewed", "malware"}
    count = 0

    with tempfile.TemporaryFile() as archive_file:
        with urllib.request.urlopen(url) as response:
            while chunk := response.read(1024 * 1024):
                archive_file.write(chunk)

        archive_file.seek(0)

        fd, temporary_path = tempfile.mkstemp(
            prefix=".github-cve-",
            suffix=".jsonl.tmp",
            dir=output.parent,
        )

        try:
            with os.fdopen(fd, "w", encoding="utf-8") as db:
                with tarfile.open(
                    fileobj=archive_file,
                    mode="r:gz",
                ) as archive:
                    for member in archive:
                        parts = Path(member.name).parts

                        if (
                            not member.isfile()
                            or not member.name.endswith(".json")
                            or len(parts) < 4
                            or parts[1] != "advisories"
                            or parts[2] not in categories
                        ):
                            continue

                        with archive.extractfile(member) as f:
                            advisory = json.load(f)

                        advisory_id = advisory["id"]
                        affected = advisory["affected"]

                        if not affected:
                            raise ValueError(
                                f"Advisory {advisory_id}: missing affected"
                            )

                        purls = {
                            make_purl(item["package"])
                            for item in affected
                        }

                        cves = [
                            alias
                            for alias in advisory.get("aliases", [])
                            if alias.startswith("CVE-")
                        ]

                        for purl in sorted(purls):
                            record = {
                                **advisory,
                                "category": parts[2],
                                "purl": purl,
                                "cve": cves[0] if cves else None,
                            }

                            db.write(
                                json.dumps(
                                    record,
                                    ensure_ascii=False,
                                    separators=(",", ":"),
                                ) + "\n"
                            )

                            count += 1

            os.replace(temporary_path, output)

        finally:
            if os.path.exists(temporary_path):
                os.unlink(temporary_path)

    return count


if __name__ == "__main__":
    print(
        f"Сохранено записей: {update_github_cve_database()}"
    )
