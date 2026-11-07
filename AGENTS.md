# Development agent instructions

Entry point for agents working on `badsysadm/docker`. Read repository rules
before proposing or editing build profiles. The source of truth for the
`nell` build contract is [nell/README.md](nell/README.md); the detailed
workflow and templates are under [doc/](doc/README.md).

## Before changing a build profile

1. Read [development conventions](doc/internal/documentation.md) and
   [plan workflow](doc/internal/plans.md).
2. Inspect the affected `nell/<section>/<project>/` files, the root
   [Makefile](Makefile) and [mk/core.mk](mk/core.mk).
3. Inspect at least one **existing completed build of a similar toolchain**
   as a reference, without copying unrelated assumptions.
4. Read project `ADR.md`, any relevant [ADRs](doc/adr/) and the
   [ADR rules](doc/internal/adr.md).
5. Verify upstream tag, source tree, official build instructions, dependencies,
   resulting paths and required executable/assets. Do not assume a network
   daemon belongs to the `net` section merely because it listens on a port.

## Scope and conflicts

- Answer questions without editing code unless explicitly instructed to edit.
- Change only files within the agreed scope; do not add tests, dependencies,
  service units, scripts, or architectural changes on your own initiative.
- Respect [nell/README.md](nell/README.md), including the three build stages,
  `/target` output, `FROM scratch`, and no test execution in image builds.
- If an instruction conflicts with documented architecture, existing
  requirements, accepted decisions or the purpose of a component, **report
  the conflict and request approval** before implementation. Record approved
  architectural exceptions through the [ADR process](doc/internal/adr.md).
- Do not weaken build checks to make an unverified change appear successful.

## Work process

- Use the root `make <project>` target; do not replace it with a standalone
  `docker build`, `kaniko` or a direct compiler invocation as the official
  verification path.
- Develop in a separate branch and create a PR/MR for manual review.
  Do not merge without explicit user approval.
- Prefer one commit for a coherent multi-file update. Preserve unrelated
  branch changes; never force-push without approval.
- State separately what was inspected, what was actually built, what the user
  verified, and what remains untested.
- Record meaningful decisions in `ADR.md` (current per-project convention)
  or a numbered shared [ADR](doc/adr/) where cross-project architecture changes.
  Plans are not a substitute for decisions; completed plans remain historical.
