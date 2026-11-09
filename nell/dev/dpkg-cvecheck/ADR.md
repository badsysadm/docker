# ADR: CVE index preparation during NELL build

## Status
Accepted for build verification.

## Context
The project ships a Python-based Debian source package verifier and a
consolidated CVE index. The index is assembled from remotely published feeds.
The source of the project is the local `src/` tree in this repository.
OpenVEX requires a document timestamp, while using the wall-clock build time
would make otherwise identical VEX reports differ between builds.

## Decision
- The `01_src` stage copies the maintained `src/` tree from the NELL build
  context; this is a first-party project rather than an external upstream clone.
- `02_dep` uses `debian/control` as the single source for build
  dependencies and installs them with `mk-build-deps`.
- As an explicit exception to the usual NELL build-stage separation, `02_dep`
  runs `make build` (fetch, convert, merge and refresh). The vulnerability
  feeds are mutable external inputs.
- `03_bin` runs only `make install` to populate `/src/target` from the
  prepared index, then packages the result into a scratch image; it does not
  rebuild or update the index.
- The scratch image contains only `/target/usr/bin/dpkg-cvecheck` and
  `/target/var/lib/cve/db.txt`. Python and dpkg are runtime requirements
  of the target host, not bundled binaries.
- All remote-feed importers use a uniform failure policy: retry a failed or
  interrupted download or decoding operation up to three times with bounded
  delays, and print the source, attempt number and human-readable reason.
  After the final failure, stop the build with an explicit diagnostic.
  Incomplete feeds must never replace the last successfully downloaded data.
- OpenVEX document timestamps are derived from `SOURCE_DATE_EPOCH` when
  provided, otherwise from the date in `debian/changelog`. The selected time
  is normalized to UTC (RFC 3339) and participates in deterministic document
  identification. This deliberately represents reproducible build metadata,
  not necessarily the actual instant when a VEX decision was made.
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
- Rebuilding VEX from the same decisions, package version and timestamp
  inputs yields stable document metadata; changing `SOURCE_DATE_EPOCH` or the
  changelog date changes the generated timestamp and document identifier.
