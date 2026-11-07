# Development and documentation conventions

These rules apply to build profiles in `badsysadm/docker`. The
[existing nell contract](../../nell/README.md) defines build architecture.
Related workflows are described in [plans.md](plans.md) and [adr.md](adr.md).

## Sources of truth and scope

- Dockerfiles, the root Makefile and `mk/core.mk` define the implemented
  pipeline; `nell/README.md` defines its intended constraints. Accepted
  project and shared ADRs record the reasons for architectural decisions.
- Build profiles use a pinned upstream version. Build flags, toolchains,
  source paths, installed artifacts and licensing must correspond to that
  version, not to an unrelated upstream revision.
- New profiles follow established `nell` patterns for the corresponding
  toolchain. Deviations from the accepted architecture require approval.
- Project sections classify software by function, not by implementation
  details such as which ports a process opens.
- Changes remain within the approved project scope. Additional tests,
  dependencies, service units, scripts and architectural changes require
  approval when they extend that scope.
- Architectural exceptions require approval and documentation under the
  [ADR process](adr.md). Existing build and security checks remain in force
  unless an approved architectural decision changes their requirements.

## Build profile contract

| File | Responsibility |
| --- | --- |
| `01_src.Dockerfile` | Obtain the pinned upstream source under `/src`; publish the source stage |
| `02_dep.Dockerfile` | Install build dependencies through `debian/control` / `mk-build-deps`; prepare external dependencies |
| `03_bin.Dockerfile` | Build and install required runtime artifacts in `/src/target`; publish `FROM scratch` with `/target` |
| `debian/control` | Declare reference build dependencies, not an alternate output layout |
| `ADR.md` | Record project-specific architectural decisions and consequences |
| Root `Makefile` | Define target, section and pinned default version |

The [project template](../templates/project.md) provides the review
checklist. External dependencies follow the static-linking policy in
`nell/README.md`; `libc` may remain dynamic where applicable. Go and
Rust toolchains may produce entirely static executables.

Runtime assets such as locally served web bundles, schemas, certificates
and plugins are part of a build when required by the application. Materials
downloaded from upstream belong in a network-enabled source/dependency
stage; the final compilation stage must not require new downloads. A
self-contained Web UI must not depend on runtime access to a CDN.

## Builds and verification

- The official build entry point is the root `make <project>` target.
- The three-stage image build does not compile or execute tests under the
  existing `nell` policy.
- Build acceptance requires a successful root target and identical SHA-256
  sets from two successive builds. Runtime contents and relevant dynamic
  dependencies must match the approved build profile.
- Project-specific validation (binary version, configuration paths,
  web assets, data format) is performed separately when agreed; those
  checks are not implicitly part of a Dockerfile build.
- Verification records identify commands, results and sources of evidence;
  planned checks remain distinct from completed checks.

## Documentation maintenance

- Existing project-level `ADR.md` files are the record for project
  decisions. Cross-project decisions belong under [shared ADRs](../adr/).
- [Plans](../plans/) record agreed staged work and its history; they do
  not supersede architecture requirements or ADRs.
- README files provide navigation and architecture guidance, not
  development logs or duplicate task inventories.
- Documentation uses relative links and describes actual behavior,
  supported configuration and observed verification results.
- Service units, deployment configuration, secrets and runtime state are
  separate from build outputs unless explicitly included in the approved
  profile.

## Branches and review

Development takes place in a dedicated branch and is submitted for manual
PR/MR review. Merging requires explicit approval. Logically related
changes are grouped in coherent commits, and unrelated changes stay outside
the branch. History is not rewritten without approval.
