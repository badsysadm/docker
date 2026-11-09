# dpkg-cvecheck / dpkg-vexgen — development plan

**Status:** Active
**Project:** `nell/dev/dpkg-cvecheck`
**Scope approved:** User authorized execution on 2026-11-09.

## Purpose and deliverables

Extend the existing Debian CVE triage workflow with an OpenVEX generator and
align the decision file syntax with the chosen VEX terminology. Generate one
VEX JSON document per binary Debian package, using the decisions and their
mandatory one-line explanations in `debian/cve/<binary-package>`.

Deliverables:
- Updated project documentation describing the new triage and VEX contracts.
- An updated `dpkg-cvecheck` validator and a `dpkg-vexgen` command.
- Per-binary-package `debian/tmp/usr/share/vex/<binary-package>.vex.json`
  artifacts, installed into the corresponding binary Debian packages.
- Migrated existing Trivy decision file and documented build integration.

## Exclusions and dependencies

- This plan does not change CVE feeds, aliasing, index merging, version-range
  extraction, or the policy of conservative matching followed by manual triage.
- No automatic decisions or new `under_investigation` status.
- No tests, supplementary test infrastructure, or unrelated changes to NELL
  build profiles without separate authorization; verification is limited to
  agreed manual inspections and build checks.
- Depend on the current `dpkg-cvecheck.py`, `src/Makefile`,
  `04_deb.Dockerfile`, Debian metadata, and the established NELL packaging
  flow. The generator must not require external CVE feeds at generation time.
- Local triage supports only `fixed` and `not_affected`; `affected` and
  `under_investigation` are deliberately excluded. Confirmed vulnerabilities
  must be fixed before release, while untriaged findings block verification.

## References

- [Build contract](../../nell/README.md)
- [Development workflow](../internal/documentation.md)
- [Plan rules](../internal/plans.md)
- [Project overview and triage policy](../../nell/dev/dpkg-cvecheck/README.md)
- [Detailed CVE index and verification guide](../../nell/dev/dpkg-cvecheck/src/README.md)
- [Current checker](../../nell/dev/dpkg-cvecheck/src/dpkg-cvecheck.py)
- [Current package build](../../nell/dev/dpkg-cvecheck/04_deb.Dockerfile)
- [Project ADR](../../nell/dev/dpkg-cvecheck/ADR.md)
- [Trivy decisions](../../nell/security/trivy/debian/cve/trivy)
- [OpenVEX specification](https://github.com/openvex/spec)

## Agreed design

1. Each regular file directly under `debian/cve/` is named after exactly one
   binary package in the source package's `debian/control`. The file holds
   only decisions for that binary package. Unknown package names, malformed
   records and duplicate vulnerability identifiers within a file are errors.
   The same identifier may have separate decisions for different packages.
2. Each nonempty record has the syntax
   `<CVE-or-BDU-ID> <decision> # <nonempty one-line triage explanation>`.
   The checker rejects a missing or empty explanation. The generator copies
   the explanation verbatim (apart from surrounding whitespace) into the
   OpenVEX `status_notes` field.
3. Supported decisions are:
   - `fixed:<upstream-fixed-version>` — the checker validates the build
     version against the declared upstream fix version; the VEX status is
     `fixed` (without a version suffix).
   - `not_affected:<justification>` — VEX status `not_affected`; the
     justification must be one of the allowed OpenVEX values:
     `component_not_present`, `vulnerable_code_not_present`,
     `vulnerable_code_not_in_execute_path`,
     `vulnerable_code_cannot_be_controlled_by_adversary`,
     `inline_mitigations_already_exist`.
   The old `not-apply` spelling is rejected after migration.
   `affected` and `under_investigation` are not accepted: confirmed
   vulnerabilities must be remediated before release and missing triage
   remains an error.
4. The output format is OpenVEX JSON. For each input
   `debian/cve/<binary-package>`, write
   `debian/tmp/usr/share/vex/<binary-package>.vex.json`. Only packages with
   explicit decision files receive reports; an absent or empty file must not
   imply that no vulnerabilities exist.
5. Each VEX document identifies the particular binary package and its
   package version (not the source package collectively), emits deterministic
   statement ordering and document identity, and uses a stable build
   timestamp from `debian/changelog` to preserve reproducibility.
   The package product identifier, PURL encoding and version source are to
   be specified concretely in Stage 1.
6. Keep the checker as the validation gate; the generator must not turn
   invalid or unverified decisions into a published VEX report. Integrate
   generation after `dh_prep` and before `dh_install`, without silently
   changing the established debhelper sequence. Each report is installed
   into its corresponding binary Debian package, not into all packages.

## Implementation stages

- [x] **Stage 1 — Update README documentation first.** Revise both
  `nell/dev/dpkg-cvecheck/README.md` and `src/README.md` to specify the
  per-binary-package decision-file model, two statuses, mandatory inline
  explanation, allowed justifications, version comparison contract,
  OpenVEX fields and file paths. Review schema-required fields,
  package identity, timestamp and naming,
  and resolve any remaining design questions **before source edits**.
  **Acceptance:** the documented examples are coherent, match the agreed
  requirements and can serve as the implementation contract.
- [x] **Stage 2 — Implement the decision validation model.** Update
  `dpkg-cvecheck.py` to load decision files by binary package from
  `debian/control`, enforce the revised syntax and comments, and retain
  its existing source-CVE coverage and upstream fixed-version checks.
  Explicitly detect missing decisions, prohibited statuses, empty files
  and invalid justifications; avoid making the presence of one binary
  package's decision satisfy another package's verification.
  **Acceptance:** documented validation semantics hold for source packages
  producing one or multiple binary packages.
- [x] **Stage 3 — Implement `dpkg-vexgen`.** Add the CLI using the same
  accepted decision grammar as Stage 2; generate one OpenVEX document per
  binary-package decision file, with `status_notes` from the inline
  comment, the correct `not_affected.justification`, product identity,
  deterministic order/metadata and atomic file replacement. Do not
  synthesize missing justifications, explanatory text or action statements.
  **Acceptance:** generated JSON satisfies the selected OpenVEX schema;
  invalid inputs result in errors and do not publish partial documents.
- [ ] **Stage 4 — Integrate Debian packaging.** Install `dpkg-vexgen`
  alongside `dpkg-cvecheck`, invoke it in `04_deb.Dockerfile` after
  `dh_prep` and before `dh_install` (after staging input artifacts as
  needed), and ensure packaging rules assign
  `usr/share/vex/<binary-package>.vex.json` to the matching binary
  package. Preserve existing NELL stage boundaries and the debhelper
  command sequence; if an architectural conflict emerges, stop for review.
  **Acceptance:** VEX documents appear inside the correct produced
  `.deb` payloads, not merely in `debian/tmp`.
- [ ] **Stage 5 — Migrate current decisions and finalize usage guidance.**
  Rename `nell/security/trivy/debian/cve/main` to
  `nell/security/trivy/debian/cve/trivy`, replace old `not-apply`
  statuses with evidence-based `not_affected:<justification>`, retain
  the actual upstream `fixed:<version>` thresholds and existing inline
  triage explanations, and verify compatibility with the new validation
  and generator contracts. Do not invent missing grounds for
  `not_affected` decisions. Update user-facing usage examples to match
  the implemented commands and paths.
  **Acceptance:** Trivy's decisions are valid under the new grammar and
  its binary package receives its own VEX document.
- [ ] **Stage 6 — Review and acceptance.** Inspect the generated VEX
  schema, reproducibility, Debian package contents, and behavior when a
  binary package has no decisions. Review any architectural impacts
  under the ADR process. Record only observed results, obtain manual
  PR review and explicit approval before merge.
  **Acceptance:** deliverables and evidence are reviewed; no unverified
  check is marked complete.

## Verification

| Check / reference | Expected outcome | Observed outcome / evidence |
| --- | --- | --- |
| README contract review | Both READMEs specify the exact formats before implementation | Documented in commit ee17287; build verification not performed |
| Decision parsing / checker manual review | Mandatory explanations, typed justifications, only fixed and not_affected statuses | Source inspection completed in Stage 2; execution and packaging not performed |
| OpenVEX schema inspection | Per-package documents contain required fields and valid statuses | Compared document structure and status fields against upstream OpenVEX JSON Schema; execution against actual package not performed |
| Multi-binary-package packaging inspection | Each `.deb` contains only its own `usr/share/vex/<name>.vex.json` | Not performed |
| [NELL build checks](../../nell/README.md#проверка-сборки) | Build and reproducibility requirements remain satisfied | Not performed |
| Manual PR review | Approved changes only | Not performed |

## Decisions and related ADRs

The existing [project ADR](../../nell/dev/dpkg-cvecheck/ADR.md) governs the
current build-stage exception. Review whether per-binary OpenVEX generation
introduces a distinct architectural decision requiring a new or updated ADR;
do not treat the implementation checklist as an ADR.

## Deferred work

- Automatic inclusion of vulnerabilities from statically linked dependencies.
- Automated exploitability classification and version-range inference from
  external CVE feeds.
- Support for `affected`, `under_investigation`, or other local triage statuses.
- New test suites or validation utilities beyond those explicitly approved.

## Completion record

Stage 1 documentation completed in ee17287 (refined in f1cc0f2). Stage 2 parser and checker implementation completed by source inspection; execution not performed. Stage 3 generator implemented and reviewed against OpenVEX JSON Schema; build and runtime verification not performed. Stage 4 Trivy packaging recipe prepared (04_deb.Dockerfile, trivy.install, debian/rules); the Debian build and package-content checks have not been performed, so Stage 4 remains open. Stages 5–6 pending.
