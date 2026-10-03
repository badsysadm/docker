# ADR: Bash build profile

## Status
Accepted.

## Decision
- Build Bash from the upstream release branch.
- Produce the existing fully static Bash binary.
- Disable NLS, help builtin and rpath; keep the selected runtime features enabled.
- Install the shell into `/bin`.
- Do not run tests and remove installed documentation.
