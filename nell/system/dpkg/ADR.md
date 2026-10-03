# ADR: dpkg build profile

## Status
Accepted.

## Decision
- Build dpkg from its upstream Git tag and apply the local build/PAX patches.
- Build static libraries and disable shared-library output.
- Disable dselect, start-stop-daemon, developer documentation and NLS.
- Keep update-alternatives enabled.
- Do not run tests and remove installed documentation.
