# ADR: diffutils build profile

## Status
Accepted.

## Decision
- Build from the official GNU release tarball.
- Disable NLS.
- Use the common `/usr`, `/etc`, `/var`, `/sbin` and `/usr/lib64` build layout.
- Do not run tests and remove installed man/info documentation.
