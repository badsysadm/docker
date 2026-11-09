#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
import tempfile

from pathlib import Path


ROOT = Path(__file__).resolve().parent
CONNECTORS = ROOT / "connectors"
from config import DATA

MODULES = {
    "nvd": ("nvd/import.py", "nvd/converter.py", "nvd-purl.txt"),
    "debian": ("debian/import.py", "debian/converter.py", "debian-purl.txt"),
    "bdu": ("bdu/import.py", "bdu/converter.py", "fstec-purl.txt"),
    "kubernetes": (
        "kubernetes/import.py",
        "kubernetes/converter.py",
        "kubernetes-purl.txt",
    ),
}


def merge():
    sources = [DATA / scripts[2] for scripts in MODULES.values()]
    destination = DATA / "merged-purl.txt"

    for source in sources:
        if not source.is_file():
            raise FileNotFoundError(source)

    with tempfile.NamedTemporaryFile(dir=DATA, delete=False) as tmp:
        temporary = Path(tmp.name)

    try:
        subprocess.run(
            ["sort", "-u", "-o", str(temporary), *map(str, sources)],
            env={**os.environ, "LC_ALL": "C"},
            check=True,
        )

        os.replace(temporary, destination)
    finally:
        temporary.unlink(missing_ok=True)

    print(f"Объединённый индекс: {destination}")


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "command",
        choices=("get", "convert", "merge", "refresh", "verify"),
    )

    parser.add_argument(
        "module",
        nargs="?",
        choices=MODULES,
    )

    args = parser.parse_args()

    if args.command in ("merge", "refresh", "verify"):
        if args.module:
            parser.error(
                f"Команда {args.command} не принимает модуль"
            )

        if args.command == "merge":
            merge()
        else:
            result = subprocess.run(
                [sys.executable, str(ROOT / ("dpkg-cvecheck.py" if args.command == "verify" else f"{args.command}.py"))]
            )
            sys.exit(result.returncode)

        return

    modules = [args.module] if args.module else MODULES

    for module in modules:
        importer, converter, _ = MODULES[module]

        script = importer if args.command == "get" else converter

        print(f"[{module}] {args.command}", flush=True)

        subprocess.run(
            [sys.executable, str(CONNECTORS / script)],
            cwd=ROOT,
            check=True,
        )


if __name__ == "__main__":
    main()
