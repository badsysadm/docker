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

## Mandatory pre-commit review

Before **every** commit or push, including follow-up fixes within the same
PR, reread the relevant project contract and inspect the complete proposed
diff against the active request. Reading the rules only at the beginning of
the session is not sufficient. Do not publish while a contradiction remains.

Apply these gates to each changed file:

1. **Scope:** Every change must be necessary for the user's approved request.
   Remove unsolicited improvements, diagnostics, cleanups and workarounds.
   Do not silently expand a requested fix into unrelated changes.
2. **Build stages:** Dockerfiles build and install artifacts; they are not a
   venue for test execution, post-build validation or ad hoc diagnostics.
   Do not insert `readelf`, `ldd`, runtime smoke tests, checksum comparisons,
   assertion loops or similar verification into build stages. The build
   contract's acceptance checks are separate from Dockerfile instructions.
   Required compiler/build-system failures are not considered tests.
3. **Installed artifacts:** Before deleting any installed path, inspect what
   upstream installs and whether it is needed by the executable, library,
   development package, downstream NELL profiles or runtime. Do not delete
   headers, `.a`/`.so` libraries, pkg-config metadata, configuration files
   or runtime data merely to minimize an image. Only remove artifacts whose
   exclusion is supported by the NELL contract and the project's actual
   installation layout.
4. **ADR boundary:** For each ADR addition, identify the distinct architectural
   decision and its rationale. Exclude release and dependency versions,
   normal build mechanics, general NELL requirements, verification status,
   TODOs and implementation notes. Preserve the required ADR sections from
   [ADR rules](doc/internal/adr.md); do not replace the template with an
   arbitrary outline.
5. **Consistency:** Compare build flags, dependency sourcing, output files
   and Makefile registration with the upstream pinned release, the NELL
   contract and at least one relevant completed profile. Differences need
   a project-specific reason; conflicts need user approval.

If a gate cannot be satisfied, stop that change and state the concrete
conflict or missing evidence. Do not compensate by inventing a workaround
or by treating an unverified assumption as an accepted decision.
