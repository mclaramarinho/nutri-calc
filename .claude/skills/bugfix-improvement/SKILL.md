---
name: bugfix-improvement
description: Runs a reported bug or improvement through nutri_calc's bugfix pipeline - qa (reproduce), po (align with requirement), optional senior-designer, senior-analyst (solution), mobile-dev, tech-lead, qa (verify) - with explicit human validation gates between stages. Use when the user reports a bug or asks for an improvement to existing behavior and wants it handled properly rather than fixed blind.
---

# Bugfix / Improvement Pipeline

Takes a reported bug (or a requested improvement to existing behavior) from "something's wrong" to a reviewed fix, through nutri_calc's specialist subagents with the human validating at every decision point — not just at the end.

This pipeline is **driven directly by you** (the main session), not delegated to the `orchestrator` subagent. The `orchestrator` assumes it runs a pipeline to completion without stopping (see `.claude/agents/orchestrator.md` point 5); this pipeline's whole point is that it stops for the human at fixed gates. Drive each stage yourself via `Task`, and actually stop and wait for the human at every gate below — don't paraphrase the gate as a rhetorical question and keep going.

Read `CLAUDE.md` before starting if you haven't this session — every stage assumes its conventions.

## Session title

From the very start of the pipeline (before invoking `qa` in step 1), title the chat/session `<PREFIX> <Bug/Improvement Identification>`, where `<Bug/Improvement Identification>` is a short stable identifier for this report (same one used in output file names) and `<PREFIX>` is kept current as the pipeline moves through these states:

- **ONGOING** — a stage is actively running (default state whenever you're driving a `Task` invocation).
- **AWAITING HUMAN** — stopped at one of the intermediate gates (1.1, 2.1, 3.1, 4.1, or the optional 4.2) waiting for the human's input before the next stage can run.
- **COMPLETED** — the pipeline has reached step 8: the fix is implemented, reviewed, and verified, and is now ready for the human's final manual test + code review (or already shipped).

Switch back to **ONGOING** as soon as the human responds at a gate and you resume driving the pipeline. Update the title at each transition rather than only at the start.

## Pipeline

```
1. qa (reproduce)
1.1 HUMAN GATE — validates QA's repro
2. po (align with requirement)
2.1 HUMAN GATE — only if po flags inconsistencies
3. senior-designer (optional — only if UI/UX is affected)
3.1 HUMAN GATE — only if step 3 ran
4. senior-analyst (solution)
4.1 HUMAN GATE — mandatory
4.2 HUMAN (optional) — implements external services themselves, reports back
4.2.1 senior-analyst — revalidates solution against what the human set up (only if 4.2 happened)
5. mobile-dev (implement)
6. tech-lead (review)
7. qa (verify fix + regression)
8. HUMAN GATE — manual test + code review
```

### 1. qa — reproduce

Invoke `qa` with the user's report verbatim. Ask it to:
- Actually attempt to reproduce the problem (run the app/tests, don't just read code and assume) — use the `run-nutri-calc` skill if driving the running app is needed to observe the behavior.
- Write up the bug in detail: exact steps to reproduce, expected vs. actual behavior, and evidence (test output, screenshot via `run-nutri-calc`, stack trace, whatever was used to confirm it). These details must be written in .claude/outputs/qa/<bug_identification>_reproduction.md
- Say explicitly if it **could not** reproduce the problem — that's a valid, important outcome, not a failure to report anyway.

**1.1 HUMAN GATE (mandatory).** Present QA's repro write-up as-is. Ask the human to confirm it matches what they actually saw, or correct it. Do not proceed to `po` until they do. If QA could not reproduce it, this gate is where the human decides whether to keep going (e.g. give QA more detail) or stop.

### 2. po — align with requirement

Invoke `po` with QA's validated repro. Ask it to check the bug against `docs/roadmap.md`: is this genuinely a deviation from the documented requirement, or does the report conflict with the requirement, invent behavior that was never specified, or actually describe a scope/feature decision rather than a bug? Ask it to flag any inconsistency explicitly rather than resolve it unilaterally, and to write its findings to `.claude/outputs/po/<bug_identification>_inconsistencies.md` (per `CLAUDE.md`'s output-file convention) instead of editing `docs/roadmap.md` directly at this point — `po`'s own default is to write straight to `docs/roadmap.md`, so this needs to be explicit in the prompt you send it.

- **No inconsistencies found** → skip 2.1, go straight to step 3.
- **Inconsistencies found** → **2.1 HUMAN GATE (mandatory).** Present po's findings from the output file. The human records their decision for each inconsistency (it's a bug / it's actually intended / requirement needs updating / etc.) directly in that same file. Once they've done so, invoke `po` a second time, pointing it at the annotated file, and ask it to: read the human's decisions, update `docs/roadmap.md` for any decision that changes the documented requirement, and confirm back which inconsistencies are resolved and how.

### 3. senior-designer — optional

Only invoke if the fix plausibly touches UI/UX (layout, states, copy, interaction) rather than being purely internal logic/persistence. When in doubt, ask the human at gate 1.1 or 2.1 rather than guessing. If skipped, say so and move to step 4.

**3.1 HUMAN GATE (mandatory, only if step 3 ran).** Present the proposed design changes. The human approves or asks for changes before step 4.

### 4. senior-analyst — solution

Invoke `senior-analyst` with the validated bug report (and design output, if any). Ask for a concrete technical solution — root cause, files/layers affected, concrete plan — not just "here's a fix idea."

**4.1 HUMAN GATE (mandatory).** Present the proposed solution. The human approves or asks for changes before implementation starts.

**4.2 HUMAN (optional).** If the solution needs something outside the Flutter app itself (external DB config, Firebase console setup, n8n, third-party service setup — see `senior-analyst`'s "When the requirement outgrows the mobile app" section), stop here and let the human do that setup themselves. Wait for them to come back and describe what they did and how it's accessed.

**4.2.1 senior-analyst re-validates (only if 4.2 happened).** Hand the human's description back to `senior-analyst` and ask it to revalidate/adjust its solution against the real setup, asking the human for more specifics if what they described isn't concrete enough to build against.

### 5. mobile-dev — implement

Invoke `mobile-dev` with the validated solution (and design, if any). No additional human gate here — gate 4.1 already approved the plan this executes.

### 6. tech-lead — review

Invoke `tech-lead` on the diff. If it finds real problems, loop back to `mobile-dev` to fix and re-review (cap at 2 rounds, same as `orchestrator`'s convention) before proceeding — don't push a known-broken fix to QA.

### 7. qa — verify

Invoke `qa` to confirm: the original repro from step 1 no longer reproduces, and nothing else regressed (run the relevant existing tests, not just new ones). Report pass/fail per the original bug, not just "tests pass."

### 8. HUMAN GATE — final

Present a concise summary: original report, root cause, what changed (files), tech-lead's review outcome, QA's verification result. Ask the human to do their own manual test and code review before considering this done. This is the pipeline's terminal state — don't auto-close/merge/commit on their behalf unless they ask.

## Handling blockers mid-pipeline

If any stage reports something that needs a human decision before continuing (ambiguous root cause, conflicting requirement, a real product tradeoff), stop and surface it — don't push forward on a guess. This applies even outside the fixed gates above.

## When not to use this

For a trivial, obvious one-line fix (typo, off-by-one, clearly-wrong constant) where reproduction and root cause are already self-evident from the report, just fix it directly and say so — running six agents and four human gates on a one-line fix wastes the human's time as much as the tokens. Use judgment; when unsure, prefer running the pipeline over skipping it, since the human gates are cheap for them to blow through if the fix really is trivial.
