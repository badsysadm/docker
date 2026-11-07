# Development plan workflow

Plans are used when the user agrees to staged work on a new build profile
or a substantial refactor. Routine one-file fixes do not require a new
plan unless requested. Follow [development rules](documentation.md).

## Before proposing a plan

1. Inspect existing [plans](../plans/) and reuse any active plan for the
   same project and scope.
2. Read `nell/README.md`, relevant root Makefile rules, the project's
   files and existing ADRs.
3. Inspect the corresponding upstream release instructions and an
   established build profile of a similar language/toolchain.
4. Separate current implementation, agreed requirements, proposals,
   deferred work and missing evidence.

## Granularity and structure

Use one active plan per `nell/<section>/<project>` for work within the
same approved scope. Store it as `doc/plans/<project>.md`, following the
[plan template](../templates/plan.md).

A plan must identify purpose, scope, exclusions, references, agreed choices,
dependencies, ordered stages, acceptance criteria, verification and deferred
work. Stages use checkboxes; each item must have a tangible result.
The plan scope and build rules remain authoritative throughout execution.

## Approval and execution

- Present a proposal and obtain approval unless the user already
  authorized its stages.
- Follow agreed stages in order, with user-requested checkpoints.
- Update an active plan only with agreed changes and verified progress.
  Keep unperformed verification unchecked.
- When a significant design decision arises, follow [ADR rules](adr.md).
  Record the decision separately instead of burying rationale in a plan.
- Do not introduce tests, extra verification scripts, runtime service units,
  deployment changes or unrelated features as implicit plan tasks.

## Completion and historical preservation

Before declaring completion, review all significant design choices for
missing ADRs, confirm scope and state which checks actually ran. Mark a
plan completed only when its accepted deliverables are complete.
**Completed plans are immutable historical records**: never silently edit
their stages, agreements or evidence retroactively. A new scope requires
a new agreed plan.
