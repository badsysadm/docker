# ADR: debootstrap runtime layout

## Status
Accepted.

## Context
debootstrap is primarily a shell program with optional Perl helpers.
Wrapping the program in PAR::Packer would change the established upstream
execution model.

## Decision
Install the upstream shell scripts and runtime library in their original
layout using upstream `make install`. Keep the Perl interpreter as an
external runtime dependency. Apply the local, narrowly scoped OpenPGP
InRelease whitespace patch without changing repository signatures.

## Consequences
The resulting bundle requires external runtime tools and an installed
Perl interpreter rather than providing a bundled executable.

## Alternatives considered
PAR::Packer was rejected because packaging the shell entrypoint as
a Perl executable would not preserve the upstream execution model.

## References
- `03_bin.Dockerfile`
- `patches/nell-inrelease-trailing-whitespace.patch`
- `../../README.md`
