---
name: roadmap-review
description: Runs docs/roadmap.md through the po and senior-analyst subagents to find inconsistencies, gaps, and architecture-fit problems, without implementing anything. Use when the user wants the roadmap validated/reviewed/audited, or asks to check the roadmap for inconsistencies before starting new work.
---

# Roadmap Review

Analyzes `docs/roadmap.md` for correctness and feasibility using two subagents, in order:

```
po → senior-analyst
```

This is analysis-only — no code, design, or roadmap-requirement authoring beyond what `po` already owns (fixing inconsistencies it finds directly in the roadmap). Use `feature-development` instead when the goal is to actually build a specific feature.

## How to run this

1. Read `CLAUDE.md` (if not already read this session) and `docs/roadmap.md` in full so you can brief the subagents with specifics rather than "review the roadmap."

2. Invoke `po` via `Task` to validate the roadmap itself (priority 1 in the roadmap's own prioritization table):
   - Read every feature section in `docs/roadmap.md`, including the status legend.
   - Cross-check each feature's documented status against the actual code under `lib/features/<feature>/` — don't trust a status label without checking.
   - Flag: contradictions between requirements, requirements that contradict what's implemented, contradictions with documented ADRs (`docs/adr/`), missing acceptance criteria (empty/error/loading states, validation rules), and unresolved dependencies between features.
   - Fix straightforward inconsistencies directly in `docs/roadmap.md` (per its own conventions); surface ambiguous ones as open questions instead of guessing.
   - Report back a list of findings (fixed vs. still open) rather than silently absorbing everything.

3. Invoke `senior-analyst` via `Task` with the `po` output, to assess architecture fit for what the roadmap currently calls for:
   - For each feature marked incomplete/not-started that has enough detail to evaluate, check whether the plan implied by the requirement fits the existing layered architecture, what would be new vs. reused, and whether it needs a DB schema change (`AppDatabaseTables`) or another unfinished feature first.
   - Call out requirement inconsistencies or missing dependencies it finds that `po` didn't already flag — feed those back to `po` rather than resolving them itself.
   - Do not write an implementation plan or ADR for every feature in the roadmap — only note real architecture-fit risks or blockers; a full implementation plan is `feature-development`'s job for one feature at a time, not this skill's job for the whole roadmap.

4. Summarize both agents' findings for the user: what's inconsistent, what's a real gap, what's blocked on what, and what (if anything) was already fixed directly in `docs/roadmap.md`.

## When not to use this

- To actually implement a roadmap item, use the `feature-development` skill or the `orchestrator` subagent instead.
- For a single feature's requirement refinement (not a whole-roadmap pass), invoke the `po` subagent directly rather than this skill.
