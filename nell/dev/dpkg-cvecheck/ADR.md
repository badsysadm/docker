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
- `02_dep` uses `debian/control` as the single source for build
  dependencies and installs them with `mk-build-deps`.
- As an explicit exception to the usual NELL build-stage separation, `02_dep`
  runs `make build` (fetch, convert, merge and refresh) and `make install`
  to produce `/src/target`. The vulnerability feeds are mutable external inputs.
- `03_bin` only packages the finished `/src/target` into a scratch image;
  it does not rebuild or update the index.
- The scratch image contains only `/target/usr/bin/dpkg-cvecheck` and
  `/target/var/lib/cve/db.txt`. Python and dpkg are runtime requirements
  of the target host, not bundled binaries.
- No tests or documentation are built or installed.

## Consequences
- Published `src/dev/dpkg-cvecheck:<version>` and
  `dep/dev/dpkg-cvecheck:<version>` images are cached by version by the
  root Makefile. To refresh sources or CVE feeds, rebuild these images with
  a new version or explicitly replace the corresponding cached images.
- Repeated `03_bin` builds are identical for the same `02_dep` snapshot;
  rebuilding `02_dep` may change the index even at the same project version
  because upstream feeds change.
- Debian packaging metadata lives in the standard profile-level `debian/`
  directory and is used by both `02_dep` and `04_deb`.
