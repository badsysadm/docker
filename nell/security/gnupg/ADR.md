# ADR: GnuPG build profile

## Status
Accepted.

## Decision
- Build GnuPG together with pinned libgpg-error, libgcrypt, libassuan, libksba and npth sources.
- Build those internal dependencies as static libraries under `/usr/local`.
- Link zlib and bzip2 statically.
- Disable NLS, scdaemon, gpgsm and dirmngr for the target profile.
- Do not run tests and remove installed documentation from the bundle.
