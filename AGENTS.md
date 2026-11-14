# Agent instructions

Entry point for LLM agents working in `badsysadm/docker`. Project rules
and engineering requirements belong to the linked documentation, not here.

## Required reading

1. Read [development conventions](doc/internal/documentation.md) and
   the [nell build contract](nell/README.md).
2. Read [plan rules](doc/internal/plans.md) and the project's active
   plan, if one exists.
3. Read the relevant project `ADR.md`, shared [ADR rules](doc/internal/adr.md),
   and affected source and build files.
4. Use the [documentation index and templates](doc/README.md) when creating
   or updating development documentation.
5. When a build problem occurs, consult
   [common build problems](doc/internal/build-troubleshooting.md) before
   diagnosing or proposing a fix. Use
   [the entry template](doc/templates/build-troubleshooting.md) when
   documenting a recurring issue.

## Agent behavior

- Treat questions as requests for an answer, **not** authorization to
  change files. Make edits only when explicitly requested.
- Before making changes, inspect the upstream source and official build
  instructions **at the pinned release**, not just the default branch.
  Compare a completed project with a similar toolchain, but do not copy
  unrelated assumptions or dependencies.
- Do not infer a project's section from whether it listens on a network
  port. Check the component's purpose and existing section conventions;
  ask for agreement when its classification is uncertain.
- Before implementing, compare the request with the documented contracts,
  established architecture, requirements, accepted decisions and the
  component's purpose. **Report conflicts and obtain agreement before
  implementing an exception.** Follow the [ADR process](doc/internal/adr.md)
  for approved architectural exceptions; never silently work around one.
- Keep within the requested scope. Do not infer authorization from an
  unchecked plan item, template or proposed follow-up. Do not add tests,
  dependencies, service units, verification commands or other unrelated
  changes on your own initiative, and never weaken checks to manufacture
  apparent success.
- When using the GitHub connector, prefer one commit per coherent
  multi-file batch: prepare a tree from the current branch, commit on its
  current HEAD and update the ref with the expected HEAD. Do not force-push
  without explicit approval.
- Treat ADRs strictly as records of specific, nontrivial architectural
  decisions and their rationale, not as containers for context or as
  summaries of a project. Before adding anything to an ADR, verify that it
  is an architectural choice rather than a routine implementation detail
  or a requirement already established elsewhere. Do not copy shared
  rules, release versions, source retrieval commands, build instructions,
  test policy, verification checklists or progress into an ADR. If the
  project has no distinct architectural decisions, keep its mandatory
  `ADR.md` concise, but preserve every required section of the ADR template.
  Before declaring that no decisions exist, examine nonstandard build and
  installation choices (including staging and upstream Makefile semantics)
  and document their rationale. Follow [ADR rules](doc/internal/adr.md).
- Report what was actually verified separately from proposed commands,
  user-reported results and checks not performed. Never imply that a build
  or test was run when it was not.

## Pre-commit review

Before every commit, review the full diff against the user's request and
the rules linked above. In particular:

- Do not put tests, diagnostics or artifact checks in build Dockerfiles.
- Do not remove installed headers, libraries, pkg-config metadata or runtime
  data without establishing that they are unnecessary.

Do not commit changes that violate these requirements.
