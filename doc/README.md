# Development documentation

This directory defines the development workflow and document templates,
adapted from the `badsysadm/self` documentation conventions to the
`badsysadm/docker` build repository.

## Authoritative references

| Document | Purpose |
| --- | --- |
| [nell/README.md](../nell/README.md) | Existing build architecture and verification contract |
| [Makefile](../Makefile) and [mk/core.mk](../mk/core.mk) | Real targets, staging and reproducibility procedure |
| [Development conventions](internal/documentation.md) | Rules for new profiles, changes and evidence |
| [Plan workflow](internal/plans.md) | Agreed stages and preservation of completed plans |
| [ADR workflow](internal/adr.md) | Decisions, exceptions and their lifecycle |

## Templates

| Template | Use |
| --- | --- |
| [Project](templates/project.md) | Checklist and structure for adding a `nell` project |
| [Plan](templates/plan.md) | Staged work when the user approves a substantial change |
| [ADR](templates/adr.md) | Decision record for a significant architectural choice |

New, explicitly approved multi-stage plans belong under [plans/](plans/).
Shared architecture decisions belong under [adr/](adr/). Existing project
`nell/<section>/<project>/ADR.md` files remain valid and must not be
moved merely because this documentation directory was introduced.

Documentation describes verified behavior and records actual verification
results. Instructions specific to LLM agents are maintained separately in
[AGENTS.md](../AGENTS.md).
