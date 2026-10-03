# ADR: dialog build profile

## Status
Accepted.

## Decision
- Build from the official Invisible Island release archive with normal TLS certificate verification.
- Enable wide-character ncurses support.
- Link ncursesw and tinfo statically while leaving libc dynamic.
- Install the executable under `/bin`.
- Do not run tests and remove installed documentation.
