# ADR: libnfnetlink library profile

## Status

Accepted

## Context

libnfnetlink is required as a reusable library dependency for statically linked NELL applications.

## Decision

Build the upstream library as a reusable NELL profile and export its headers, libraries and pkg-config metadata without embedding them into consumer bundles.

## Consequences

Consumers can link against the static archive while shared libraries and development metadata remain available from the same image.

## Alternatives considered

Relying on Debian development packages was rejected because the required static archive is not available in the target build environment.

## References

- [NELL build contract](../../README.md)
- [Build implementation](03_bin.Dockerfile)
