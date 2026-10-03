# ADR: APT build profile

## Status
Accepted.

## Decision
- Build APT from the Debian upstream repository and apply the local build/PAX patches.
- Build the pinned OpenSSL dependency locally as static libraries.
- Link APT's external compression, crypto and support libraries statically while leaving libc dynamic.
- Disable NLS and documentation.
- Use a fixed `SOURCE_DATE_EPOCH` to improve reproducibility.
