# New nell project — preparation template

The requirements for directory layout, build stages, linking, packaging,
Makefile registration and verification live exclusively in
[nell/README.md](../../nell/README.md). This template records
**project-specific facts and results**; it does not restate those rules.

## Identity and upstream

| Field | Value |
| --- | --- |
| Project / Make target | `<project>` |
| Section | `<section>` |
| Official source URL | `<url>` |
| Release tag / version | `<tag>` / `<version>` |
| Source commit (if relevant) | `<sha>` |
| Toolchain and version | `<toolchain>` |
| License | `<license>` |
| Comparable existing project | `<project>` |

## Upstream build information

- Official build reference: `<url or source path>`
- Required external dependencies: `<names and versions>`
- Required language/toolchain components: `<details>`
- Project-specific build flags: `<flags>`
- Additional runtime assets: `<assets or none>`

## Output contents

| Artifact | Purpose / consumer |
| --- | --- |
| `<installed path>` | `<reason>` |

## Decisions and exceptions

- Project-specific ADR: `<relative link>`
- Other accepted decisions: `<links or none>`
- Approved exclusions or deviations: `<description or none>`

## Verification record

Use the acceptance criteria in
[nell/README.md](../../nell/README.md#проверка-сборки).

| Check / reference | Actual result | Evidence |
| --- | --- | --- |
| `<check>` | `<result or not performed>` | `<log or reference>` |

## Review

- Branch: `<branch>`
- PR/MR: `<link>`
- Manual review status: `<status>`
