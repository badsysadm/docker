import sys
import os
import ssl
import shutil
import tempfile
import urllib.request
import zipfile

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from config import DATA


URL = "https://bdu.fstec.ru/files/documents/vulxml.zip"
DESTINATION = DATA / "fstec-cve.xml"


def update_fstec_cve_database(
    path: str = DESTINATION,
    url: str = URL,
) -> int:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)

    context = ssl._create_unverified_context()

    with tempfile.TemporaryDirectory(dir=output.parent) as tmp:
        archive_path = Path(tmp) / "vulxml.zip"
        xml_path = Path(tmp) / "vulxml.xml"

        with (
            urllib.request.urlopen(url, context=context) as response,
            open(archive_path, "wb") as dst,
        ):
            shutil.copyfileobj(response, dst)

        with zipfile.ZipFile(archive_path) as archive:
            name = next(
                name
                for name in archive.namelist()
                if name.lower().endswith(".xml")
            )

            with (
                archive.open(name) as src,
                open(xml_path, "wb") as dst,
            ):
                shutil.copyfileobj(src, dst)

        size = xml_path.stat().st_size
        os.replace(xml_path, output)

    return size


if __name__ == "__main__":
    size = update_fstec_cve_database()
    print(f"Сохранено байт: {size}")
