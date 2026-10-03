# ADR: util-linux build profile

## Status
Accepted.

## Decision
- Build from the official kernel.org release archive.
- Disable NLS, asciidoc, Python libmount, systemd, SELinux, cryptsetup and btrfs integration.
- Keep liblastlog2 and PAM lastlog2 enabled.
- Build the selected low-level utilities as static programs.
- Do not run tests and remove installed documentation.
