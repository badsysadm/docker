# ADR: CVE index preparation during NELL build

## Status
Accepted for build verification.

## Context
The project ships a Python-based Debian source package verifier and a
consolidated CVE index. The index is assembled from remotely published feeds.
The source of the project is the local `src/` tree in this repository.

## Decision
- The `01_src` stage copies the maintained `src/` tree from the NELL build
  context; this is a first-party project rather than an external upstream clone.
- `02_dep` uses `src/debian/control` as the single source for build
  dependencies and installs them with `mk-build-deps`.
- Network-dependent `make get` (fetch and convert) runs only in `02_dep`.
- `03_bin` runs `make refresh` to merge and normalize the downloaded
  intermediate indexes offline, then `make install` to populate
  `/src/target`.
- The scratch image contains only `/target/usr/bin/dpkg-cvecheck` and
  `/target/var/lib/cve/db.txt`. Python and dpkg are runtime requirements
  of the target host, not bundled binaries.
- No tests or documentation are built or installed.

## Consequences
- Published `src/dev/dpkg-cvecheck:<version>` and
  `dep/dev/dpkg-cvecheck:<version>` images are cached by version by the
  root Makefile. To refresh sources or CVE feeds, rebuild these images with
  a new version or explicitly replace the corresponding cached images.
- A reproducible `03_bin` uses the same snapshot from `02_dep`; the
  vulnerability index is not fetched during final assembly.
- Debian packaging metadata lives in `src/debian/control`, because the
  source tree is also independently built as a Debian package; duplicating
  that control file at the NELL profile root would create two dependency
  specifications.
