# Development and documentation conventions

These rules apply to build profiles in `badsysadm/docker`. Read the
[existing nell contract](../../nell/README.md) first. For plans see
[plans.md](plans.md); for ADRs see [adr.md](adr.md).

## Sources of truth and scope

- The working Dockerfiles, root Makefile and `mk/core.mk` establish the
  implemented pipeline; `nell/README.md` defines its intended constraints.
  Accepted project and shared ADRs explain architectural decisions.
- Inspect upstream sources **at the pinned release**, not only its changing
  default branch. Verify official build flags, toolchain versions, source
  paths, relevant installation artifacts and license.
- Read a completed `nell` project using a similar toolchain before adding
  a new one. Do not copy unrelated functionality or introduce an alternative
  build layout without approval.
- Agree on the project's section based on its role; a listening network
  port does not by itself determine the section.
- Change only what was requested. A question alone does not authorize code
  changes. Do not add tests, dependencies, service units, scripts or other
  architectural changes without approval. Distinguish unknowns from facts.
- If an instruction conflicts with established architecture, requirements,
  accepted decisions or the purpose of a component, identify the conflict
  and obtain agreement **before** implementing an exception, using
  [ADR rules](adr.md).
- Do not weaken build checks or security requirements to make an
  unverified implementation appear successful.

## Build profile contract

| File | Responsibility |
| --- | --- |
| `01_src.Dockerfile` | Fetch the pinned upstream source into `/src`; publish source-only stage |
| `02_dep.Dockerfile` | Install build dependencies via `debian/control` / `mk-build-deps`; prepare external dependencies before compiling |
| `03_bin.Dockerfile` | Compile and install only required runtime artifacts in `/src/target`; publish `FROM scratch` with `/target` |
| `debian/control` | Reference build dependencies, not an alternate output packaging layout |
| `ADR.md` | Project-specific architectural decisions, trade-offs and consequences |
| Root `Makefile` | Register the target, section and default version |

Follow the [project template](../templates/project.md) for detailed review
criteria. Respect the current `nell/README.md` rule to link external
dependencies statically, allowing `libc` to remain dynamic when relevant.
Go/Rust runtimes may produce entirely static executables. Do not add
dependencies just to mirror another project's implementation.

Treat local static files, web bundles, schemas, certificates and other
runtime assets as part of the project when upstream requires them. Prepare
network-fetched material at the dependency stage where the pipeline permits
it; `03_bin` should not rely on downloading new dependencies. Verify
whether browser assets require CDNs at runtime.

## Builds and verification

- The official entry point is `make <project>`; use the build defined by
  the repository rather than a hand-written alternative.
- Do not compile or run tests as part of the three-stage image build:
  existing `nell` policy explicitly disables tests.
- A build is not accepted until the root target has succeeded and its
  two successive output hashes match, with appropriate review of
  dynamically linked libraries and resulting runtime files.
- Check tool-specific behavior when relevant (e.g. binary version,
  configuration paths, web assets, data formats), but do not silently add
  those checks to Dockerfiles.
- Report verification precisely: a proposed command is not an executed
  test; user-confirmed logs must not be represented as agent-run tests.

## Documentation maintenance

- Keep project-specific decisions in their existing `ADR.md`. Use
  shared [ADRs](../adr/) for decisions affecting multiple projects;
  do not retroactively change old decisions without the ADR process.
- Use [plans](../plans/) for agreed staged work, not as a source of new
  autonomous tasks.
- Keep README files as navigation and architecture guidance, not a
  changelog or a duplicated backlog.
- Use relative links, accurately reflect the source and avoid stating
  unsupported behavior or successful verification.
- Keep service units and deployment/configuration separate from the build
  profile unless the user explicitly requests them; copying a service unit
  into `/target` requires explicit agreement.

## Branches and review

Work on a separate branch, submit one PR/MR for manual review and wait for
the user to authorize merging. Batch logically related changes in one
commit where possible. Never rewrite the branch or modify unrelated
projects merely for convenience.
