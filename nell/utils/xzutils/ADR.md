# ADR: XZ Utils build profile

## Status
Accepted.

## Decision
- Build from the upstream release tag with CMake.
- Build static liblzma and disable shared-library output.
- Disable NLS, XZ documentation and Doxygen output.
- Do not run tests and remove any installed documentation.
