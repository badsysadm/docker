# Agent instructions

Entry point for LLM agents working in `badsysadm/docker`. This file is
an agent workflow guide, not a duplicate of the development rules.

## Required reading

1. Read [development conventions](doc/internal/documentation.md) and
   the [nell build contract](nell/README.md).
2. Read [plan rules](doc/internal/plans.md) and the project's active
   plan, if one exists.
3. Read relevant project `ADR.md`, shared [ADR rules](doc/internal/adr.md),
   and the affected source and build files.
4. Use the [documentation index and templates](doc/README.md) when creating
   or updating development documentation.

## Agent behavior

- Treat questions as requests for an answer, **not** authorization to
  change files. Make edits only when explicitly requested.
- Before implementing, compare the requested change with the documented
  contracts and approved decisions. **Report conflicts and request
  agreement**, rather than inventing exceptions or silently bypassing
  requirements. Follow the ADR process for approved architectural exceptions.
- Keep within the requested scope. Do not infer authorization from an
  unchecked plan item, a template or a proposed follow-up.
- When using the GitHub connector, prefer one commit for each coherent
  multi-file batch: prepare a tree from the current branch, commit on the
  current HEAD, and update the ref with the expected HEAD. Never force-push
  without explicit approval.
- Report what was actually verified separately from proposed commands,
  user-reported results and checks not performed. Never imply that a build
  or test was run when it was not.
