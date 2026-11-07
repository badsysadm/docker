# Architecture Decision Records

ADRs record why significant technical decisions were accepted, their
scope, consequences and real alternatives. They are not task lists,
test transcripts or operational manuals.

## Scope and location

- Existing `nell/<section>/<project>/ADR.md` files remain the record
  for project-specific build-profile decisions.
- Cross-project architecture changes or exceptions to
  `nell/README.md` use `doc/adr/NNNN-short-title.md`, with sequential
  four-digit numbers and the [ADR template](../templates/adr.md).
- Each decision has one authoritative record; duplicate ADRs are avoided.

## Required sections

1. A specific decision title (`ADR-NNNN` for shared records).
2. Status: Proposed, Accepted, Superseded or Deprecated.
3. Context: problem, constraints and evidence.
4. Decision: agreed design and its boundaries.
5. Consequences: benefits, costs and limitations.
6. Alternatives considered: alternatives actually evaluated.
7. References: implementation, related ADRs and documentation.

## Content boundaries

- ADRs describe only architectural choices specific to their scope and
  the rationale for those choices. Do not repeat the common build,
  development or operational requirements already documented in
  `nell/README.md` or other authoritative rules; link to them instead.
- Do not pin or record concrete software, toolchain or dependency
  versions, release tags or commit hashes in ADRs. Version selection
  belongs to build files and version configuration, not architecture.
- Do not record routine implementation steps, file moves, typo fixes,
  test execution status or progress history. These belong in commits,
  pull requests or work plans.
- An ADR may document a project-specific exception to common rules,
  but only after explicit approval; describe the exception and its
  rationale, without duplicating the underlying global rule.

## Approval and maintenance

Architecture changes that conflict with accepted requirements require
explicit approval before implementation and an ADR documenting the
exception. A proposed decision is not binding until accepted.
Accepted reasoning remains historically accurate. Substantial changes
of direction use a successor ADR, with the prior record marked as
superseded and linked to its replacement. Factual corrections do not
rewrite the historical decision.
