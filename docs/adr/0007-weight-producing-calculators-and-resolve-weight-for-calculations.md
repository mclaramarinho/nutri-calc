# 0007. Weight-producing calculators persist into `WEIGHTS`; `resolveWeightForCalculations` contract and retrofit scope; dedicated state quadruple per calculator

**Status:** Accepted
**Date:** 2026-09-23
**Feature:** [docs/roadmap.md 2.1.4 Calculators, Slice 8](../roadmap.md#calculators) ("Slice 8 planned" note)

## Context

Slice 8 unblocks the 5 "Weight sub-type" calculators (Ideal, Adequation, Adjusted-Dry-Weight, Adjusted-Obesity, Estimated) that were flagged as blocked since Slice 7. Three decisions needed to be made explicit before `mobile-dev` could implement the first of the 5 (Ideal Weight) without re-deriving architecture:

1. Every other calculator (BMI, Energy Expenditure, Nitrogen Balance, ...) persists into its own dedicated table. Weight sub-type calculators instead write into the pre-existing `WEIGHTS` table (product requirement, roadmap 2.1.4: "The calculated weight should be saved in the existing Weights table"). This is a real deviation from the established one-table-per-calculator convention and needed to be recorded, not silently followed.
2. The "consider for calculations" override chain (a calculated weight can be marked as the reference to use going forward, falling back to the nearest earlier weight that was itself marked as such) needed a single resolution function multiple current and future calculators depend on — its contract, precondition, and ownership needed to be fixed once.
3. ~13 existing call sites already do "grab the newest weight" (`weights.first`/`weights[0]`) across `patient_calculators_tab.dart`, `patient_details_cubit.dart`, and `weight_loss_classification_relevance.dart`. Once `resolveWeightForCalculations` exists, should these be retrofitted to respect the override, or left as `weights.first` until a later slice?

## Decision

**(a) `WEIGHTS`-not-own-table for weight-producing calculators.** Ideal Weight (and the other 4 blocked Weight sub-types, later) write a plain new row into `WEIGHTS` with `weightType` set to the corresponding `WeightTypeEnum` case (already reserved since Slice 1) and `considerForCalculations` set from the calculator's own confirmation-sheet checkbox — not a new `IDEAL_WEIGHTS` table. `WEIGHTS` gains exactly one new column to support this: `inputParams` (`TableSqlTypes.json`, `NOT NULL DEFAULT '[]'`, `sinceVersion: 9`; `kAppDatabaseVersion` 8 → 9), so weight rows carry the same `{key,label,value}` traceability every other calculator table has had since its own creation. This is an `ALTER TABLE`-style migration (mirroring Slice 1's `considerForCalculations`/`weightType` addition), not a new-table migration. Existing manual-scale rows backfill `inputParams` to `"[]"` via the column `DEFAULT`.

This is a deliberate, scoped exception to the "each calculator gets its own table" convention: these 5 calculators' entire purpose is to produce a *weight*, which every other weight-consuming calculator already reads through the `WEIGHTS` table/`GetWeightsUseCase`. Giving each its own table would require every consumer to also query 5 extra tables and merge/re-sort by date to find "the weight to use," duplicating exactly the logic `WEIGHTS` already centralizes.

**(b) `resolveWeightForCalculations` contract.**

```dart
// lib/features/measurements/weight/domain/use_cases/resolve_weight_for_calculations.dart
class ResolveWeightForCalculations {
  const ResolveWeightForCalculations();

  /// Returns the weight to use for calculations: the first entry (in list
  /// order) with `considerForCalculations == true`, or `null` if none.
  ///
  /// Precondition: [weights] is already ordered newest-first (the ordering
  /// `GetWeightsUseCase` already guarantees). This function does NOT
  /// re-sort defensively — every real call site already receives this
  /// ordering, and a second, possibly-diverging sort policy here was
  /// rejected as unnecessary complexity/perf cost. Garbage-in/garbage-out
  /// if a caller violates the precondition (not this function's job to
  /// guard against; document, don't assert).
  WeightEntity? call(List<WeightEntity> weights) {
    for (final w in weights) {
      if (w.considerForCalculations) return w;
    }
    return null;
  }
}
```

Plain, synchronous, no `Result` wrapper (no failure mode) — same rationale as `FilterRelevantCalculators`. Lives in the weight feature's own domain layer (not `lib/shared/services/calculator/`) because it operates on `WeightEntity`'s data shape, not calculator math.

**Retrofit decision (this ADR's final ruling, resolving the "TBD" the requirements pass left open):** **none of the ~14 existing `weights.first`/`weights[0]` call sites are retrofitted in this slice.** Investigated every site (table in [docs/roadmap.md Slice 8 note](../roadmap.md#calculators)); at every single site, the existing test fixture uses a single-element `weights` list, so `weights.first` and `resolveWeightForCalculations(weights) ?? weights.first` are indistinguishable to the test — a regression that picked the wrong weight among multiple candidates would not be caught anywhere. Per the coordinator's ruling ("if either condition fails, defer with a named reason"), every site is deferred. See the roadmap's resolved TBD for the full per-site table. This is logged as a named "Next" item, not folded into generic tech debt.

**(c) Dedicated state quadruple, not reuse of `saveWeight`'s.** Ideal Weight gets its own `isSavingIdealWeight`/`isIdealWeightSaveError`/`idealWeightSaveErrorMessage`/`isIdealWeightSaved` quadruple on `PatientDetailsStateLoaded`/`PatientDetailsCubit`, following the `copyWith`/`_unset`-sentinel pattern fixed in Slice 5 — not `saveWeight`'s existing trio. Even though both write to `WEIGHTS`, Ideal Weight is a distinct user-initiated action (its own bottom sheet, its own success/error copy) — matches the "new calculator = new quadruple" convention every prior slice has followed (BMI, Energy Expenditure, Nitrogen Balance, Protein Needs, Water Needs, the 3 Enteral Nutrition sub-types, Glucose Infusion Rate, Weight Loss Classification, MUST, NRS-2002, STRONG-Kids all have their own). This will be the 14th quadruple; the tech-lead's `CalculatorSaveStatus` value-object advisory ([priority 9](../roadmap.md#1-roadmap-prioritization)) remains unactioned and is not this slice's scope to fix.

## Consequences

- Makes it easier to add the remaining 4 Weight sub-types later — they follow the exact same "write into `WEIGHTS`, no new table" + `resolveWeightForCalculations`-aware relevance pattern, with no new architectural decision needed.
- Makes it harder to see, at the DB-schema level, that 5 distinct calculators write into one table — mitigated by `weightType`/`inputParams` making each row's provenance explicit, and by this ADR being the canonical reference.
- Rules out (for now) retrofitting the override chain into the ~14 existing "latest weight" call sites. Every one of them continues to silently pick the newest weight regardless of `considerForCalculations`, until a patient's weight-override state is exercised through them — flagged explicitly as a "Next" roadmap item (see roadmap Slice 8 note), not silent tech debt.
- The retrofit's actual blocker is a test-coverage gap, not a code-mechanics one — closing it (adding multi-weight, mixed-`considerForCalculations` fixtures at each site) is a smaller, independent unit of work that unblocks the retrofit later without needing another investigation pass.

## Alternatives considered

- **New `IDEAL_WEIGHTS` (etc.) table per Weight sub-type, consistent with every other calculator** — rejected: would require every "latest weight" consumer to also merge 5 additional per-type tables by date to find the true "current" weight, exactly the indirection `WEIGHTS`+`resolveWeightForCalculations` exists to avoid. The product requirement text is also explicit that this goes in `WEIGHTS`.
- **`resolveWeightForCalculations` re-sorts defensively instead of trusting caller ordering** — rejected: `GetWeightsUseCase` already owns and guarantees the sort; a second sort policy here risks silently diverging from it later and costs a sort on every call for no current benefit.
- **Retrofit every call site now, accepting the coverage gap** — rejected per the coordinator's explicit ruling: a coverage gap at a site is itself disqualifying, regardless of how mechanical the code change looks, because a regression there would ship undetected.
- **Reuse `saveWeight`'s existing state trio for Ideal Weight** — rejected: breaks the established one-quadruple-per-calculator convention for no real benefit, and conflates two independently-triggerable user actions' success/error state.
