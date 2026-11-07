# Development documentation

Development workflow and document templates for `badsysadm/docker`.

## Authoritative references

| Document | Purpose |
| --- | --- |
| [nell/README.md](../nell/README.md) | Build architecture, project layout and acceptance criteria |
| [Makefile](../Makefile) and [mk/core.mk](../mk/core.mk) | Implemented build targets and orchestration |
| [Development conventions](internal/documentation.md) | Development process and review |
| [Plan workflow](internal/plans.md) | Planning and progress records |
| [ADR workflow](internal/adr.md) | Architectural decision lifecycle |
| [Common build problems](internal/build-troubleshooting.md) | Recurring Autotools/M4 failures |

## Templates

| Template | Purpose |
| --- | --- |
| [Plan](templates/plan.md) | Staged development record |
| [ADR](templates/adr.md) | Architectural decision record |
| [Common build problem](templates/build-problem.md) | Entry for the build troubleshooting page |

Instructions specific to automated development agents are maintained in
[AGENTS.md](../AGENTS.md).
