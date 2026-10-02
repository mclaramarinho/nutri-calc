# User Personas

Who `nutri_calc` is designed for, and the usage context that should inform UI/UX decisions. Written for Roadmap Priority 8 ("Design System audit & expansion").

**Explicit limitation:** this is not user research. No interviews, surveys, or usability sessions with real dietitians/nutritionists have been conducted for this app. Everything below is derived from evidence already present in the codebase, `docs/roadmap.md`, and `CLAUDE.md` — i.e. inferred from what the product already does and the copy it already uses, not observed from real users. Each point below is tagged **[confirmed]** (directly stated in CLAUDE.md/roadmap or directly observable in shipped code/copy) or **[inferred]** (a reasonable UX conclusion drawn from confirmed evidence, not itself stated anywhere). Treat `[inferred]` points as working assumptions to revisit if real user feedback ever becomes available — don't cite them as settled fact in future design docs without re-checking.

---

## Primary persona: the consulting dietitian/nutritionist

**[confirmed]** The app's target user is a dietitian or nutritionist (`CLAUDE.md`: "a Flutter app used by dietitians/nutritionists to manage patients and run clinical nutrition calculators").

### Context of use

- **[inferred]** Used during or immediately after a patient consultation, not as an end-of-day batch-entry tool. Evidence: the app is structured around a single patient's record (Patient Details page with Measurements/Calculators/History tabs) rather than a multi-patient dashboard-first flow; calculators open as bottom sheets over the patient's own data (height/weight/age auto-filled from the patient record) rather than as a standalone generic tool — this only makes sense if the dietitian already has that specific patient in front of them when running a calculation.
- **[inferred]** Mobile, likely one-handed, while physically with the patient (bedside, consult room, or home visit) or momentarily afterward. Evidence: swipe-to-delete gestures (`Dismissible`, one-thumb reachable), bottom sheets anchored to the bottom third of the screen rather than full-screen modals, and a bottom nav/tab-bar layout (`DsBottomNav`, `DsTabView`) — all mobile-ergonomics choices, not patterns a desktop-first tool would need.
- **[inferred]** Interruptible, time-pressured workflow. Evidence: auto-closing success dialogs (no "OK" tap required to continue) and retryable error dialogs that preserve form state behind them (already documented under "Feedback dialogs" in `design-conventions.md`) — both reduce the number of taps/decisions needed to get back to the patient, consistent with someone who can't spend attention acknowledging confirmations mid-consult.

### Domain expertise and terminology

- **[confirmed]** The user is a trained clinical professional, not a lay patient-facing app user. UI copy uses unexpanded clinical shorthand throughout — "IMC" (not "Índice de Massa Corporal"), "nutrição enteral"/"nutrição parenteral" (not spelled out), "TIG" for Taxa de Infusão de Glicose (documented rationale in `design-conventions.md`'s Slice 5 notes: "the term dietitians use in practice," no "full name (abbreviation)" pattern exists anywhere in the app).
- **[inferred]** Precision in terminology matters more than approachability/friendliness of tone. The one case where a plain-language clarifying sentence was added (`DsCheckbox` helper text for "Restrito ao leito") was deliberately scoped to disambiguate one genuinely ambiguous term, not to soften or explain basic clinical vocabulary — implying the house style defaults to trusting the user's domain fluency and only adds explanation where a term could be read more than one way.
- **[inferred]** Numeric precision conventions (`toStringAsFixed(1)` for practical dosing/rate values the dietitian will relay to nursing staff vs. `toStringAsFixed(2)` for small-magnitude clinical ratios like BMI/TIG, documented in `design-conventions.md`) suggest the user cares about not overstating precision — a secondary signal of clinical literacy, not just a display nitpick.

### Workflow shape

- **[confirmed]** Fast, repeated data entry is central: the roadmap and existing patterns (per-measurement swipe-to-delete, "disabled until valid" save buttons, auto-filled derived fields like height/age in calculator sheets) are all optimized for entering a few numbers and getting a result quickly, not for long-form data review.
- **[confirmed]** Forms consistently disable the Save/Calculate action until required fields are valid (`DsButton.disabled`, ADR 0003) rather than allowing submission and showing validation errors after the fact — a prevention-first rather than correction-first validation philosophy, also followed by `DsDateTimePicker`'s "prevent, don't correct" future-date handling.
- **[inferred]** The dietitian runs calculators repeatedly across many patients per day, so cumulative friction (extra taps, unnecessary confirmation dialogs, hard-to-reach targets) compounds — this is the underlying reason the "Feedback dialogs" and gesture conventions above matter as much as they do; a single extra tap is cheap once, expensive ×N patients/day.

---

## Implications for design decisions

- **Information density:** favor compact, scannable layouts (list tiles with at most title/subtitle/overline, not multi-line cards) — the user needs to find one patient/one calculator/one result quickly, not browse leisurely. This is already the shape of `DsListTile` and the Calculators "relevant vs. all" split; new screens should default to the same density rather than adding visual padding/whitespace for its own sake.
- **Touch-target sizing:** assume thumb-reach, one-handed interaction. Swipe gestures, bottom sheets, and bottom-anchored action rows (already DS conventions) should stay the default placement for primary actions over, e.g., top-app-bar icon buttons, which are harder to reach one-handed.
- **Contrast/accessibility:** no accessibility audit has been done and dark mode/RTL are explicitly out of scope for this slice — but given the clinical context (used in varied lighting — bedside, consult rooms, possibly outdoors for home visits) new color tokens should default to clearly distinguishable contrast against white/black rather than closely-spaced grays. This is a flag for a future dedicated accessibility pass, not a decision made here.
- **Terminology precision:** when introducing new copy, default to the clinical shorthand a dietitian already uses (match `CalculatorType`/tile naming precedent) rather than inventing friendlier or more verbose alternatives; only add a clarifying helper line when a term is genuinely ambiguous (the "Restrito ao leito" precedent), not as a general tooltip/onboarding pattern.
- **Error/success feedback:** keep the existing auto-closing-success / explicit-dismiss-retryable-error split (see `design-conventions.md`'s "Feedback dialogs" section) for any new flow — it's already tuned to this user's time pressure, don't introduce a competing pattern (e.g. toasts, snackbars) without a concrete reason tied to this persona.

---

## Secondary/edge considerations (not personas, but worth flagging)

- **[inferred]** Pediatric patients exist in-product (STRONG-Kids screening calculator) — the dietitian persona above may also be treating children, not only adults. No pediatric-specific UI pattern exists yet beyond that one calculator; flagging in case density/terminology choices ever need a pediatric-specific variant.
- **[inferred]** No evidence anywhere in the codebase of a secondary persona (e.g. an admin, a supervising physician, the patient themselves) having any UI surface — the entire app is single-role (the dietitian/nutritionist). Don't design for a second role until the roadmap actually introduces one.
