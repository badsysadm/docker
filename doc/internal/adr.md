# Architecture Decision Records

ADRs explain **why** significant technical decisions were accepted,
what they change and what alternatives were considered. They are not
task lists, test transcripts, or operational manuals.

## Scope and location

- Existing project-level `nell/<section>/<project>/ADR.md` is the
  established place for project-specific build-profile decisions.
  Preserve these files and conventions.
- For cross-project rules, build architecture changes or exceptions to
  `nell/README.md`, use `doc/adr/NNNN-short-title.md` with a
  four-digit sequential number, following the [ADR template](../templates/adr.md).
- Do not create a second ADR restating a decision already recorded.

## Required sections

1. Title with a specific decision (use `ADR-NNNN` for shared ADRs).
2. Status: Proposed, Accepted, Superseded or Deprecated.
3. Context: problem, constraints and evidence.
4. Decision: selected behavior and scope.
5. Consequences: benefits, costs and limitations.
6. Alternatives considered: real alternatives, never invented history.
7. References: implementation, related ADRs and documentation.

## Approval and maintenance

A contradictory architectural change requires explicit user approval
**before** the implementation. Document an accepted exception rather than
silently bypassing existing rules. Do not present a proposal as accepted.
Keep accepted reasoning historically accurate; for a substantial change
of direction, create a successor ADR and mark the former superseded,
linking both. A factual correction may be made without rewriting the
original decision.
