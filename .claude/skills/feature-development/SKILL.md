---
name: feature-development
description: Runs a nutri_calc feature/change through the full specialist pipeline - po, senior-designer, senior-analyst, mobile-dev, qa, tech-lead, po - end to end. Use when the user wants a feature or non-trivial change developed properly rather than hand-implemented directly, or explicitly asks to run the feature-development pipeline/workflow.
---

# Feature Development Pipeline

Delivers a feature/change through nutri_calc's full specialist pipeline in a fixed order:

```
po → senior-designer → senior-analyst → mobile-dev → qa → tech-lead → po
```

Each subagent is defined under `.claude/agents/`. Read this project's `CLAUDE.md` before starting if you haven't already this session — every stage assumes its conventions.

## How to run this

Invoke the `orchestrator` subagent via `Task`, giving it:
- The user's original request, verbatim.
- This exact pipeline order (`po → senior-designer → senior-analyst → mobile-dev → qa → tech-lead → po`) as the one to follow, rather than letting it choose a shorter pipeline — this skill exists specifically for cases where the full pipeline is wanted.
- Instruction to only skip `senior-designer` if the request genuinely has no UI surface (e.g. a pure calculator-logic or persistence change) — otherwise run every stage.

The `orchestrator` handles the actual sequencing, context handoff between stages, and blocker/re-review looping (see `.claude/agents/orchestrator.md`) — this skill just pins the pipeline shape and hands off.

## What each stage hands to the next

- **po (1st pass)** → produces/updates the requirement in `docs/roadmap.md`, resolves or surfaces inconsistencies.
- **senior-designer** → produces UI/UX requirements (layout, states, copy, interactions), documents new conventions in `docs/design/`.
- **senior-analyst** → produces a concrete implementation plan and, if needed, ADRs under `docs/adr/`.
- **mobile-dev** → implements per the plan and design, runs `flutter analyze` and any directly-relevant existing tests.
- **qa** → writes/runs tests against the `docs/roadmap.md` requirement, reports gaps and defects.
- **tech-lead** → reviews the diff for architecture/SOLID/clean-code adherence and the project-specific checklist in `.claude/agents/tech-lead.md`; findings loop back to `mobile-dev` (and re-review) before proceeding.
- **po (validation pass)** → confirms the shipped result matches the requirement, updates status/tech-debt/next-steps in `docs/roadmap.md`.

## When not to use this

For a trivial fix, a pure bug fix with an obvious cause, or a no-behavior-change refactor, use the `orchestrator` subagent directly (or just do the work) instead of forcing every stage — see `.claude/agents/orchestrator.md`'s pipeline-selection guidance.
