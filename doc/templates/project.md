# New nell project — development template

This is a checklist for a new project, **not** a replacement for
[nell/README.md](../../nell/README.md). Complete with actual upstream
data; omit unsupported components.

## Identity and upstream

| Field | Value |
| --- | --- |
| Project / Make target | `<project>` |
| Section (by function) | `<section>` |
| Official source URL | `<url>` |
| Release tag / version | `<tag>` / `<version>` |
| Source commit (if needed) | `<sha>` |
| Toolchain and minimum versions | `<versions>` |
| License | `<license>` |
| Comparable existing nell project | `<project>` |

## Required files

```text
nell/<section>/<project>/
├── 01_src.Dockerfile
├── 02_dep.Dockerfile
├── 03_bin.Dockerfile
├── ADR.md
└── debian/
    └── control
```

Add the target's `section` and pinned default `version` to the root
`Makefile`; use the existing targets as the syntax reference.

## Build contract

- [ ] `01_src` clones/downloads the pinned upstream version into `/src`.
- [ ] `02_dep` uses `mk-build-deps` and `debian/control`.
- [ ] External dependencies/toolchains are pinned and prepared before `03_bin`.
- [ ] `03_bin` compiles the required application without new downloads.
- [ ] Required executable files and runtime assets are installed under `/src/target`.
- [ ] External libraries follow the `nell` static-link policy; note any
      exception in an approved ADR.
- [ ] Final stage is `FROM scratch`, copying only `/src/target/` to `/target/`.
- [ ] Documentation, tests and development artifacts are excluded from
      the output; no tests are compiled or run by image stages.
- [ ] Service units, configuration, secrets and runtime storage match the
      approved deliverables, without unrelated files in the artifact.
- [ ] Project `ADR.md` records nonstandard decisions and consequences.

## Runtime contents

| Installed file / directory | Reason required |
| --- | --- |
| `/target/<path>` | `<reason>` |

List every necessary executable and relevant assets (Web UI, schemas,
plugins, libraries). Explain which settings the eventual runtime needs;
do not embed secrets or choose deployment paths without agreement.

## Verification evidence

| Check | Outcome / source of evidence |
| --- | --- |
| `make <project>` | Not executed / actual result |
| Two consecutive SHA-256 sets | Not executed / actual result |
| Runtime files and dynamic dependencies | Not inspected / actual result |
| Upstream behavior relevant to project | Not checked / actual result |

Verification is performed via the root Makefile. Record successful checks
only when supported by actual results.

## Review

- Branch: `<branch>`
- PR/MR: `<link>`
- Agreed exclusions / deferred items: `<items>`
- Manual review status: `<status>`
