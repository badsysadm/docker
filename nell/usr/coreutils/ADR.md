# ADR: coreutils build profile

## Status
Accepted.

## Decision
- Build from the official GNU release tarball.
- Build coreutils as a single binary with symlink frontends.
- Disable NLS.
- Do not regenerate autotools files from tarball timestamps.
- Do not run tests and remove `/usr/share` from the final bundle.
