# ADR: tar build profile

## Status
Accepted.

## Decision
- Build from the official GNU release tarball and apply the local build patch.
- Disable NLS and SELinux support.
- Keep external compressor integrations for gzip, bzip2, xz/lzma, lzop and zstd.
- Do not run tests and remove installed documentation.
