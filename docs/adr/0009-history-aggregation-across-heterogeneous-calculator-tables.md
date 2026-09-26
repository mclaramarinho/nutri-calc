# 0009. History aggregation across 14 heterogeneous calculator sources via per-source use cases + a thin orchestrator

**Status:** Accepted
**Date:** 2026-09-26
**Feature:** [docs/roadmap.md §2.1.4 Patient Details - Tabs, History, Slice 11](../roadmap.md#214-patient-details---tabs)

## Context

The History tab must show all 18 shipped calculator results, grouped by the existing 10-value `CalculatorType` enum, latest-first, reading from 13 distinct source tables (`BMI`, `ENERGY_EXPENDITURES`, `NITROGEN_BALANCES`, `PROTEIN_NEEDS`, `WATER_NEEDS`, `ENTERAL_NUTRITIONS_DRIPPING`/`SPEED`/`VOLUME`, `GLUCOSE_INFUSION_RATES`, `WEIGHT_LOSS_CLASSIFICATIONS`, `SCREENING_MUST`/`NRS_2002`/`STRONG_KIDS`, and `WEIGHTS` for the 5 Weight sub-types, disambiguated by `weightType` per ADR 0007). None of these calculator repositories currently expose a "get all for patient" method except `WeightRepository.getWeights` — every other repository only has a `createX` method (BMI's `createBmi` is representative). A single aggregation point has to be designed before `mobile-dev` can build it without re-deriving how 14 heterogeneous shapes become one list.

## Decision

**One generic `HistoryEntryEntity`** (`lib/features/calculators/domain/entities/history_entry_entity.dart`), the common shape every source is normalized to:

```dart
class HistoryEntryEntity extends Equatable {
  final String id;                 // row id in its own source table
  final String patientId;
  final CalculatorType type;       // grouping key (existing enum, ADR/roadmap-fixed order)
  final HistorySourceType sourceType; // routes get/delete to the right leaf use case (see below)
  final String label;              // tile title — reuses the exact PT-BR strings already
                                    // used as each calculator's `CalculatorDefinition.name`
                                    // in patient_calculators_tab.dart (e.g. "Gotejamento",
                                    // "MUST", or WeightTypeEnum.label for Weight sub-types)
  final String resultSummary;      // pre-formatted display string for the tile/bottom sheet
  final List<InputParamEntity> inputParams;
  final DateTime createdAt;
}
```

**`HistorySourceType`** (`lib/features/calculators/domain/entities/history_source_type_enum.dart`) is a new 14-value enum — one per queryable source (13 calculator tables + `weight`, since `WEIGHTS` backs 5 `CalculatorType.weight` sub-types) — distinct from `CalculatorType` (10 values, grouping) and from `CalculatorIds` (18 values, save-flow ids, ADR 0008). It exists purely to key the get/delete dispatch tables below; it is domain-pure (no dependency on `AppDatabaseTables`, keeping the existing domain/infra boundary — only repository impls import `AppDatabaseTables`).

**One `GetXHistoryUseCase` per source (14 total)**, each living in its own existing calculator/weight sub-feature's `domain/use_cases/`, same shape:

```dart
abstract class GetBmiHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}
@Injectable(as: GetBmiHistoryUseCase)
class GetBmiHistoryUseCaseImpl implements GetBmiHistoryUseCase {
  const GetBmiHistoryUseCaseImpl({required this._repository});
  final BmiRepository _repository;
  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getBmis(patientId); // NEW repo method, mirrors getWeights
    return res.when(
      ok: (models) => Ok(models.map((m) => HistoryEntryEntity(
        id: m.id, patientId: m.patientId,
        type: CalculatorType.bmi, sourceType: HistorySourceType.bmi,
        label: "IMC",
        resultSummary: "IMC: ${m.value.toStringAsFixed(1)} (${_classificationLabel(m.classification)})",
        inputParams: m.inputParams, createdAt: m.createdAt,
      )).toList()),
      error: (e) => Error(e),
    );
  }
}
```

Each of the 12 non-Weight calculator repositories gains a `getX(patientId)` read-all method (mirrors `WeightRepository.getWeights`, backed by `AppDatabaseService.read(.x, where: 'patientId = ?', ...)`) — this is genuinely new, since today only `createX` exists per calculator repository. Weight's `GetWeightHistoryUseCase` does **not** duplicate `WeightRepository`/`GetWeightsUseCase` — it wraps the existing `GetWeightsUseCase` and maps each `WeightEntity` to a `HistoryEntryEntity` using `WeightTypeEnum.label` (already shipped) and a formatter extracted from `patient_measurements_tab.dart`'s existing private `_formatWeightValue` (moved to a reusable place — see "Result-summary formatting reuse" below). This keeps the fan-out uniform: 14 `GetXHistoryUseCase`s, no special-cased branch for Weight in the orchestrator.

**Formatting (the "result summary") is authored once, at the source**, inside each `GetXHistoryUseCase`, not in a central switch statement in the History feature. This mirrors ADR 0006's precedent ("each sub-feature owns its own glue") and keeps the orchestrator itself trivial (see below) — adding calculator #19 later means adding one more `GetXHistoryUseCase` file, not editing a shared switch.

**A thin orchestrator, not a DI multi-binding fan-out on the cubit:**

```dart
abstract class GetPatientCalculatorHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}
@Injectable(as: GetPatientCalculatorHistoryUseCase)
class GetPatientCalculatorHistoryUseCaseImpl implements GetPatientCalculatorHistoryUseCase {
  const GetPatientCalculatorHistoryUseCaseImpl({
    required this._getBmiHistory, required this._getEnergyExpenditureHistory,
    /* ...12 more, one per HistorySourceType... */
  });
  // ...14 injected GetXHistoryUseCase fields...

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final all = <HistoryEntryEntity>[];
    for (final fetch in [_getBmiHistory, _getEnergyExpenditureHistory, /* ... */]) {
      final res = await fetch(patientId);
      // Graceful degradation: one source failing does not blank the whole
      // tab — see Consequences.
      res.when(ok: (v) => all.addAll(v), error: (_) {});
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Ok(all);
  }
}
```

`injectable`'s regular constructor injection (14 distinct interface types) is used — **not** `get_it`'s `getAll<T>()`/multi-binding, for the same reasons ADR 0006 already rejected it (extra DI ceremony, `@Named` bookkeeping, no ordering benefit since grouping is by `CalculatorType.values` regardless of fetch order). The orchestrator, not `PatientDetailsCubit`, owns the 14-way fan-out: `PatientDetailsCubit` injects exactly **one** new use case (`GetPatientCalculatorHistoryUseCase`) instead of 14, keeping its already-large constructor (18 calculator save use cases) from doubling.

**Grouping/ordering is a pure presentation-layer step**, not baked into the entity or orchestrator: `PatientHistoryTab` buckets the flat, orchestrator-returned `List<HistoryEntryEntity>` by `CalculatorType.values` (same iteration-order precedent as `CalculatorList._buildAllView`), skips empty buckets, and relies on the orchestrator's global sort for latest-first within each bucket (a global sort by `createdAt` is stable and already latest-first per bucket once grouped, since it's just a filter over an already-sorted list).

## Consequences

- Adding calculator #19 in a later slice means: one repository method (`getX`), one `GetXHistoryUseCase`, one line in the orchestrator's constructor + fetch list. No `PatientHistoryTab`/`HistoryEntryEntity` change required — matches ADR 0006/0008's "impossible to half-wire" property.
- A single slow/failing source (e.g. a corrupted `SCREENING_MUST` row throwing during `fromJson`) degrades gracefully — that group is simply empty/incomplete rather than blanking the entire History tab with one error dialog. This is a new, explicit policy (no precedent existed for partial-failure multi-source aggregation) — logged here rather than silently decided in code. Tradeoff: a genuine read failure is invisible to the user (no error surfaced for that one source). Acceptable per po's spec, which only defines an all-succeeded happy path and an all-empty state, not partial-failure UX — revisit if QA/po want a "some results may be missing" affordance later.
- `PatientDetailsCubit`'s constructor grows by exactly 1 (the orchestrator use case), not 14 — the 14 leaf `GetXHistoryUseCase`s are only ever injected into `GetPatientCalculatorHistoryUseCaseImpl`, never into the cubit directly.
- Rules out per-entry lazy/paginated loading (everything is fetched eagerly per source, per patient) — acceptable given every other tab in this app already eagerly loads a patient's full list (weights, heights, body measurements) with no pagination precedent.

## Alternatives considered

- **`get_it` `getAll<HistoryProvider>()` multi-binding**, each calculator sub-feature self-registering. Rejected for the same reasons as ADR 0006: extra bootstrap ceremony, `@Named` per impl, no ordering benefit since `CalculatorType.values` already fixes group order regardless of collection order.
- **Central switch statement in `PatientHistoryTab` or the orchestrator, reading raw models per table and formatting `resultSummary` there.** Rejected: would require the History feature to import 13+ calculator-specific model/classification types, creating exactly the kind of central God-object switch ADR 0006 avoided for `onTap` wiring — and would duplicate classification-label logic that (ideally) already exists closer to each calculator's own domain.
- **Cubit-owned fan-out** (`PatientDetailsCubit` constructor-injects all 14 `GetXHistoryUseCase`s directly, no orchestrator). Rejected: doubles an already-large (18-param) constructor for no behavioral benefit; the orchestrator is trivially unit-testable in isolation from the cubit.
