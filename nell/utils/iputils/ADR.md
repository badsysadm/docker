# ADR: iputils build profile

## Status
Accepted.

## Decision
- Build from the upstream release archive with Meson/Ninja.
- Build arping, clockdiff, ping and tracepath.
- Link libcap, libidn2 and libunistring statically while leaving libc dynamic.
- Disable tests, gettext and generated man/HTML documentation.
