# Architecture Decision Records (ADR)

One file per non-obvious architecture/design decision. Purpose: let future work (and future Claude sessions) reuse a decision instead of re-deriving it — read the relevant ADRs before re-analyzing a topic that already has one.

## When to write one

- A choice with real tradeoffs was made (a pattern, a library, a data-modeling call, a deviation from `CLAUDE.md` conventions).
- Something that isn't obvious from reading the code alone (why, not what).
- Skip trivial/obvious choices — that's what over-documentation looks like, and it costs tokens for no benefit later.

## Naming

`docs/adr/NNNN-short-title.md`, zero-padded, sequential (check existing files for the next number).

## Template

```markdown
# NNNN. Title

**Status:** Proposed | Accepted | Superseded by NNNN | Deprecated
**Date:** YYYY-MM-DD
**Feature:** link to the relevant docs/roadmap.md section, if any

## Context
What requirement/constraint/inconsistency triggered this decision. Keep it to what's needed to justify the decision — not a restatement of the whole feature spec.

## Decision
What was decided. Be concrete (interfaces, table/column names, package choices, folder placement).

## Consequences
What this makes easier, what it makes harder, what it rules out. Any follow-up work created (link a docs/roadmap.md tech-debt entry if one was added).

## Alternatives considered
Briefly — option, why rejected. Only options that were seriously considered, not a brainstorm dump.
```

## Index

Keep this list current — one line per ADR — so an agent can decide relevance without opening every file.

| ADR | Title | Status |
| --- | ----- | ------ |
| [0001](0001-database-schema-migrations.md) | Database schema migrations via sqflite version + self-describing versioned fields | Accepted |
| [0002](0002-approuter-pop-generic-result.md) | `AppRouter.pop` gains a generic optional result parameter | Accepted |
