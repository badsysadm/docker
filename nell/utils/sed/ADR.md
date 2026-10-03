# ADR: sed build profile

## Status
Accepted.

## Decision
- Build from the official GNU release tarball.
- Disable NLS.
- Preserve release autotools files instead of regenerating them because of timestamp differences.
- Do not run tests and remove installed documentation.
