# 0006. Calculator registry is a plain static list assembled by the consuming tab, not an `injectable`/`get_it` multi-binding

**Status:** Accepted
**Date:** 2026-09-19
**Feature:** docs/roadmap.md section 2.1.4 "Calculators" Slice 2 (relevance filtering + See All/See Relevant toggle); section 3.1 "Calculators" (All calculators list, Calculator Relevance table)

## Context

Slice 2 introduces `CalculatorDefinition` (id, `CalculatorType`, Portuguese `name`, optional icon, `isRelevant` predicate, `onTap` entry point) as the shared unit every calculator sub-feature under `lib/features/calculators/` will eventually register, so `PatientCalculatorsTab` can render a relevant-only or full-by-type list without knowing about individual calculators. Only BMI registers this slice; 9 more `CalculatorType`s are expected in later slices (Energy Expenditure, Enteral/Parenteral Nutrition, Nitrogen Balance, Protein Needs, Screening, Water Needs, Weight, Weight Loss Classification — some of these will themselves back multiple `CalculatorDefinition`s, e.g. Weight's 5 sub-types).

Two questions had to be settled before `mobile-dev` could build this without re-deriving architecture:

1. **How do `CalculatorDefinition`s get collected into the list the tab renders** — a DI multi-binding (`get_it`'s `getAll<T>()`) or a plain list built by the consuming widget?
2. **Where does the coupling between a calculator's `onTap` and the concrete cubit that owns bottom-sheet/save flow live** — `CalculatorDefinition.onTap` is `void Function(BuildContext)` (po's proposal) specifically so the shared `CalculatorDefinition` entity itself never imports `PatientDetailsCubit`/`PatientDetailsStateLoaded`. But *something* concrete has to close over the cubit to open BMI's bottom sheet and call `saveBmiCalculation()`. If that glue is written inside `lib/features/calculators/bmi/`, that sub-feature would have to import `PatientDetailsCubit` from `lib/features/patients/details/` — which already depends on `lib/features/calculators/bmi/` (via `SaveBmiCalculationUseCase`), creating a **feature-level import cycle** between `patients/details` and `calculators/bmi`.

## Decision

**Registry mechanism:** a plain, non-injected `List<CalculatorDefinition>` assembled inside `PatientCalculatorsTab.build()` (or a small private helper it calls), not a `get_it` multi-binding.

- `get_it` (`^9.2.1`/resolved `7.7.0`) does support `getAll<T>()`, but only after calling `enableRegisteringMultipleInstancesOfOneType()` once at bootstrap, and `injectable` requires a distinct `@Named` tag per implementation bound to the same interface (confirmed against `injectable-3.0.0`'s README — there is no built-in "inject `List<T>`, auto-collect all `@Injectable(as: T)`" feature). That's meaningfully more DI ceremony than this slice's actual need justifies.
- Canonical section order for the "See All" grouped view is already fixed by `CalculatorType`'s declared enum order (10 values, fixed by po's scope) — so a multi-binding's registration order buys nothing; the grouped view must iterate `CalculatorType.values` and bucket definitions regardless of how they were collected.
- Each calculator's `onTap` needs its own feature-specific cubit glue anyway (see coupling decision below), which only `PatientCalculatorsTab` can provide without a cycle — so there is no code that could be "auto-collected" without also being widget-specific. A multi-binding registry would only be gathering metadata (id/type/name/icon/isRelevant) while `onTap` still gets bolted on per-tab, i.e. two partially-overlapping registration mechanisms instead of one.

**Coupling boundary:** `lib/features/calculators/bmi/` (and every future calculator sub-feature) exposes only a pure, cubit-free relevance predicate and reuses its existing use case/repository — it never imports anything from `lib/features/patients/details/`. The full `CalculatorDefinition` (including `onTap`) is constructed inside `PatientCalculatorsTab`, which already legitimately depends on both `PatientDetailsCubit` (its own feature) and `lib/features/calculators/*` (existing precedent — it already calls `cubit.saveBmiCalculation()`, itself backed by `SaveBmiCalculationUseCase` from `calculators/bmi`). This keeps the dependency direction single: `patients/details → calculators/*`, never the reverse.

**What "adding calculator #2" looks like in a later slice:**
1. Build the new calculator sub-feature under `lib/features/calculators/<name>/` per the standard layering (own tables/models/repositories/use cases), same as BMI.
2. Export one pure relevance-predicate function/value from that sub-feature (e.g. `bool isEnergyExpenditureRelevant(CalculatorRelevanceContext ctx)`), living in that sub-feature's `domain/`.
3. In `PatientCalculatorsTab`, append one `CalculatorDefinition(...)` entry to the list built in `build()`, wiring `onTap` to whatever bottom-sheet/cubit-method glue that calculator needs (mirroring BMI's `_openXxxBottomSheet` pattern).
4. No edits to `lib/features/calculators/domain/` shared code (`CalculatorDefinition`, `CalculatorRelevanceContext`, `FilterRelevantCalculators`, `CalculatorType` grouping/rendering) are required — those are calculator-count-agnostic already, since `CalculatorType`'s 10 values are fixed by the roadmap's finalized calculator list.

## Consequences

**Easier:** no DI bootstrap changes, no `@Named` bookkeeping across up to ~15+ future `CalculatorDefinition` registrations, no risk of `get_it`'s multi-instance mode being silently misconfigured. Feature dependency direction (`patients/details → calculators/*`) stays acyclic and matches the direction that already exists in the codebase.

**Harder / ruled out:** adding a new calculator is not fully "zero-touch" — it requires one small, expected edit to `PatientCalculatorsTab` (append one list entry + its `onTap` glue), not shared/domain-layer code. If a second host screen for calculators is ever introduced (currently there is only one — the patient details Calculators tab), that host would need its own copy of this same assembly step; acceptable for now since only one host exists and is likely to for the foreseeable future (calculators are always patient-scoped).

**Follow-up:** none required now. Revisit only if a second calculator-list host appears (extract the list-assembly step into a shared factory at that point) or if the sheer number of `onTap` glue closures makes `PatientCalculatorsTab` unwieldy (candidate refactor: move each calculator's glue into its own `<name>_calculator_entry.dart` file under `patients/details/presentation/widgets/`, still assembled into the same list in the tab).

## Alternatives considered

- **`get_it` `getAll<T>()` multi-binding**, each calculator sub-feature registering `@Named("bmi") @Injectable(as: CalculatorDefinitionProvider)`. Rejected: extra DI ceremony (bootstrap flag, per-impl `@Named`) for no real benefit here, since `onTap` glue still has to be assembled per-host-widget regardless (see coupling boundary above), and canonical ordering is already enforced by `CalculatorType.values`, not registration order.
- **Let `calculators/bmi` (and future sub-features) import `PatientDetailsCubit` directly**, building the full `CalculatorDefinition` including `onTap` inside the sub-feature. Rejected: creates a `patients/details ↔ calculators/bmi` import cycle (the reverse dependency already exists via `SaveBmiCalculationUseCase`), and hard-codes every calculator sub-feature to one specific host cubit even though patient-scoped calculators are plausibly the only host today but shouldn't be assumed permanent.
- **Generic `onTap` signature carrying a host-agnostic callback bundle instead of raw `BuildContext`** (e.g. `onTap: (params) => ...` where `params` bundles resolved weight/height/age primitives, no `BuildContext`/cubit at all). Rejected for this slice: bigger redesign of the already-shipped Slice 1 `_openBmiBottomSheet` flow than the requirement calls for ("zero behavior change for BMI's tap flow" is an explicit constraint); `void Function(BuildContext)` is simpler and sufficient given the coupling boundary above already isolates the cubit dependency to the one legitimate place.
