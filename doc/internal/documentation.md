# Development and documentation conventions

This document describes the development and review process for build
profiles in `badsysadm/docker`. The authoritative build architecture,
project layout, dependency rules and build acceptance criteria are defined
in [nell/README.md](../../nell/README.md); they are not repeated here.

For staged work use [plan rules](plans.md), and for architectural decisions
use [ADR rules](adr.md). Use the
[project preparation template](../templates/project.md) to record the
details of a new project, not to redefine the build contract.

## Preparing a change

- Examine the affected implementation, its root Makefile registration
  and relevant accepted project-level or shared ADRs.
- For a new upstream version or build profile, establish the exact
  upstream release, its official build procedure, dependencies, installed
  components and licensing. Compare it with a completed profile of a
  similar toolchain where useful.
- Record project-specific requirements and exclusions before implementation.
  Unrelated deployment changes or features require a separately agreed scope.
- Architectural exceptions follow the [ADR process](adr.md). The original
  build contract remains authoritative until a change to it is approved.

## Verification and evidence

Build verification follows the
[checks specified by nell](../../nell/README.md#проверка-сборки).
The development record must distinguish planned checks from observed
results and identify the evidence for each result. Project-specific
validation, when agreed, is recorded separately rather than changing
the standard build contract without approval.

## Documentation maintenance

- Project-specific architectural decisions belong in the existing
  `ADR.md`; cross-project decisions follow [shared ADR rules](adr.md).
- [Plans](plans.md) record agreed staged work and its history, not
  architecture requirements.
- README files are navigation and reference points rather than
  development logs or duplicate task inventories.
- Documentation describes current behavior and links to authoritative
  contracts instead of restating them. Use relative links and preserve
  the rationale and history of accepted decisions.

## Branches and review

Development takes place in a dedicated branch and is submitted for manual
PR/MR review. Merging requires explicit approval. Group related changes in
coherent commits, keep unrelated work outside the branch and do not rewrite
history without approval.
