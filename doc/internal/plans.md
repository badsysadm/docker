# Development plan workflow

Plans document agreed staged work on a new build profile or a substantial
refactor. Routine fixes do not require a separate plan unless requested.
The [development conventions](documentation.md) apply throughout.

## Prerequisites

An active plan is based on the current project implementation, the
[nell build contract](../../nell/README.md), relevant ADRs, upstream
release instructions and an existing comparable build profile. Existing
active plans for the same project and scope take precedence over creating
parallel plans. The plan distinguishes implemented behavior, approved
requirements, proposals, exclusions and unverified assumptions.

## Granularity and structure

There is at most one active plan for a given
`nell/<section>/<project>` and agreed scope. Plans are stored as
`doc/plans/<project>.md` using the [plan template](../templates/plan.md).

Each plan records its purpose, scope, exclusions, references, approved
design, dependencies, ordered stages, acceptance criteria, verification
and deferred work. Stage entries use checkboxes with tangible outcomes.
Plan scope and existing build rules remain binding throughout execution.

## Approval and execution

- A plan begins as `Proposed` and becomes `Active` only after the
  proposed scope and stages are approved.
- Stages are completed in their agreed order, including any required
  review checkpoints.
- Active plans record agreed scope changes and verified progress.
  Unperformed verification remains unchecked.
- Significant architectural decisions are recorded according to the
  [ADR rules](adr.md), not solely in the plan.
- Tests, supplementary verification scripts, runtime services, deployment
  changes and unrelated features require separate authorization when
  outside the plan's approved scope.

## Completion and historical preservation

Completion requires the accepted deliverables and a review of significant
decisions for missing ADRs. The record identifies which checks were
actually performed. Completed plans remain immutable historical records,
including their agreed stages and evidence. New scope requires a new
agreement rather than retroactive edits.
