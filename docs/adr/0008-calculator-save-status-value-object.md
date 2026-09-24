# 0008. `CalculatorSaveStatus` value object replaces per-calculator state quadruples

**Status:** Accepted
**Date:** 2026-09-23
**Feature:** [docs/roadmap.md §2.1.4](../roadmap.md#214-patient-details---tabs), Slice 9 (tech-lead-recommended refactor after Slice 8, commit `6ee77c4`)

## Context

`PatientDetailsStateLoaded`/`PatientDetailsCubit` accumulated 14 near-identical "quadruples" — one per calculator (BMI, Energy Expenditure, Nitrogen Balance, Protein Needs, Water Needs, 3x Enteral Nutrition, Glucose Infusion Rate, Weight Loss Classification, MUST, NRS-2002, STRONG-Kids, Ideal Weight): `isSavingX` / `isXSaveError` / `xSaveErrorMessage` / `isXSaved`, each hand-threaded through the state constructor, `copyWith` (with an `_unset` sentinel for the nullable message), `clearForm`, `props`, a `closedXErrorModal()` cubit method, a `saveXCalculation(...)` cubit method (emit-saving → call use case → emit error-or-saved → 2s auto-reset), and 2 `||`-chained branches in `patient_details_page.dart`'s `BlocConsumer`. This exact duplication caused 2 real bugs (Slices 5, 6 — a method not threading all fields through, silently resetting unrelated calculators' state) and a near-miss in Slice 8 review. With 4 more Weight sub-types unblocked and queued, the pattern was about to reach 18 quadruples. Flagged as an advisory in Slice 5, "triggered" in Slice 6, and made an explicit, urgent tech-lead recommendation after Slice 8 (see roadmap "Slice 9, next up" note).

## Decision

**One `CalculatorSaveStatus` sealed hierarchy**, matching the existing `Result<T, E>` idiom in `lib/core/utils/result/result.dart` (abstract base + concrete subclasses distinguished via `is`-checks/`sealed class`, not a bools-bag):

```dart
// lib/features/calculators/domain/entities/calculator_save_status.dart
sealed class CalculatorSaveStatus extends Equatable {
  const CalculatorSaveStatus();

  bool get isSaving => this is CalculatorSaveStatusSaving;
  bool get isError => this is CalculatorSaveStatusError;
  bool get isSaved => this is CalculatorSaveStatusSaved;
  String? get errorMessage =>
      this is CalculatorSaveStatusError ? (this as CalculatorSaveStatusError).message : null;
  String? get savedMessage =>
      this is CalculatorSaveStatusSaved ? (this as CalculatorSaveStatusSaved).message : null;
}

class CalculatorSaveStatusIdle extends CalculatorSaveStatus {
  const CalculatorSaveStatusIdle();
  @override List<Object?> get props => [];
}

class CalculatorSaveStatusSaving extends CalculatorSaveStatus {
  const CalculatorSaveStatusSaving();
  @override List<Object?> get props => [];
}

class CalculatorSaveStatusError extends CalculatorSaveStatus {
  const CalculatorSaveStatusError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

class CalculatorSaveStatusSaved extends CalculatorSaveStatus {
  const CalculatorSaveStatusSaved(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
```

The `isSaving`/`isError`/`errorMessage`/`isSaved` getters exist purely so call sites (and tests) that used to read `state.isXSaveError` can be mechanically rewritten as `state.calculatorStatus('x').isError`, without forcing every read site into pattern matching.

**Keyed by `String` id, not one named field per calculator:** `PatientDetailsStateLoaded.calculatorStatuses` is a `Map<String, CalculatorSaveStatus>`, keyed by the same id strings already used as `CalculatorDefinition.id` in `patient_calculators_tab.dart`'s registry (ADR 0006). A calculator with no entry is implicitly idle (`calculatorStatus(id) => calculatorStatuses[id] ?? const CalculatorSaveStatusIdle()`).

To remove the stringly-typed-id duplication risk between the registry (`patient_calculators_tab.dart`) and the cubit (`patient_details_cubit.dart`), the 14 id string literals are centralized once as `static const` fields on a new `CalculatorIds` class (`lib/features/calculators/domain/entities/calculator_ids.dart`), imported by both files instead of each hand-typing `"bmi"`, `"ideal_weight"`, etc. twice.

**Success/error copy travels inside the status itself**, not through a second per-calculator lookup table: `CalculatorSaveStatusError.message` and `CalculatorSaveStatusSaved.message` carry the exact Portuguese strings previously hardcoded per `if/else` branch in `patient_details_page.dart`. This is what makes the page's listener fully generic (see below) — a new calculator that starts populating `calculatorStatuses` requires zero additional `patient_details_page.dart` changes to get its dialogs.

**Single generic state-transition helper on the cubit:**

```dart
Future<void> _saveCalculation({
  required String id,
  required Future<Result<void, String>> Function() action,
  required String errorFallbackMessage,
  required String successMessage,
  Future<void> Function(PatientDetailsStateLoaded current)? onSuccess,
}) async {
  _executeOnStateLoaded((current) async {
    emit(current.copyWithCalculatorStatus(id, const CalculatorSaveStatusSaving()));

    final res = await action();

    if (res.isError) {
      _executeOnStateLoaded((latest) {
        emit(latest.copyWithCalculatorStatus(id, CalculatorSaveStatusError(errorFallbackMessage)));
      });
      return;
    }

    if (onSuccess != null) {
      await onSuccess(state as PatientDetailsStateLoaded);
    }

    _executeOnStateLoaded((latest) {
      emit(latest.copyWithCalculatorStatus(id, CalculatorSaveStatusSaved(successMessage)));
    });

    await Future.delayed(const Duration(seconds: 2));

    _executeOnStateLoaded((latest) {
      emit(latest.copyWithCalculatorStatus(id, const CalculatorSaveStatusIdle()));
    });
  });
}
```

Each `saveXCalculation(...)` keeps: its own precondition guard (e.g. `if (current.weights.isEmpty) return;`), its own argument construction (which weight/height to read, unit conversions), and its own `onSuccess` side effect where one exists (BMI/Ideal Weight need to refetch weights and recompute `bmi`; most don't) — then delegates the emit-dance to `_saveCalculation`. This is the only part of the 14 methods that is genuinely calculator-specific and must stay separate.

**Single generic listener in `patient_details_page.dart`:** the `BlocConsumer` iterates `state.calculatorStatuses.entries` instead of 14 hand-written `||` branches:

```dart
listenWhen: (previous, current) {
  if (current is! PatientDetailsStateLoaded) return false;
  final prevStatuses = previous is PatientDetailsStateLoaded
      ? previous.calculatorStatuses
      : const <String, CalculatorSaveStatus>{};
  return current.calculatorStatuses.entries.any((e) {
    final prev = prevStatuses[e.key] ?? const CalculatorSaveStatusIdle();
    return (e.value.isError && !prev.isError) || (e.value.isSaved && !prev.isSaved);
  }) || /* ...unchanged top-level isSaveError/isSaved patient-form checks... */;
},
listener: (context, state) {
  if (state is! PatientDetailsStateLoaded) return;
  if (state.isSaveError) { /* unchanged patient-form error dialog */ return; }
  if (state.isSaved) { /* unchanged patient-form success dialog */ return; }
  for (final entry in state.calculatorStatuses.entries) {
    final status = entry.value;
    if (status.isError) {
      DsDialog.show(context, title: "Erro ao salvar", message: status.errorMessage!,
          showCloseButton: true,
          onClose: () => context.read<PatientDetailsCubit>().closedCalculatorErrorModal(entry.key));
      return;
    }
    if (status.isSaved) {
      DsDialog.show(context, title: "Sucesso", message: status.savedMessage!,
          showCloseButton: false, isDismissible: false, duration: const Duration(seconds: 2));
      return;
    }
  }
},
```

Registering a 15th–18th calculator (the 4 unblocked Weight sub-types) therefore needs: a `CalculatorIds` constant, a `saveXCalculation` method calling `_saveCalculation(...)`, and one entry in the DI constructor for its use case — **no `patient_details_page.dart` change at all**. This is the concrete "impossible to half-wire" property the roadmap slice asked for.

The pre-existing top-level `isSaving`/`isSaved`/`isSaveError`/`saveErrorMessage` quadruple for **patient-form edits** (`toggleEditing`/`updatePatientData`) is explicitly out of scope and untouched — it is not one of the 14 calculator quadruples and has different semantics (`isEditing` interacts with it).

## Consequences

- Adding a new calculator's save/error/success wiring becomes: 1 id constant + 1 cubit method (calling the shared helper) + 1 DI constructor param. No `PatientDetailsStateLoaded` field, no `copyWith`/`clearForm`/`props` edits, no `patient_details_page.dart` edit. This directly unblocks the 4 queued Weight sub-types without growing the quadruple count.
- `PatientDetailsStateLoaded`'s field count drops by 56 (14×4) in favor of one `Map<String, CalculatorSaveStatus> calculatorStatuses` field; `copyWith`/`clearForm`/`props` each drop ~50 lines of repetition.
- `flutter_bloc`'s `Equatable`-based state comparison still works: `Map` equality inside `props` via `Equatable`'s deep-equals (already used for `List<WeightEntity>` etc. in this state) — confirmed no new dependency needed since `equatable` already deep-compares supported collections.
- Widget/cubit tests that read `state.isSavingBmi`/`state.isBmiSaveError`/`state.bmiSaveErrorMessage`/`state.isBmiSaved` must be mechanically rewritten to `state.calculatorStatus('bmi').isSaving` / `.isError` / `.errorMessage` / `.isSaved` (14 find/replace passes, one per calculator id) — no behavioral test logic changes.
- Rules out ever giving one calculator's save status a shape other calculators don't have (e.g. progress percentage) without changing the shared `CalculatorSaveStatus` type for all — acceptable, none of the 18 calculators need that today.
- A calculator id typo (e.g. `"ideal_wieght"`) now fails softly (looks permanently idle / dialogs never show) rather than a compile error, since `Map<String, ...>` lookups aren't statically checked. Mitigated by centralizing all 14(+) id literals in `CalculatorIds` so there is exactly one place per calculator where the literal string is authored, and both the registry and the cubit reference the same constant — a typo would have to be made once and would then consistently fail the same way in both places, making it visible in manual QA of that calculator immediately (dialogs never appearing is very noticeable). `flutter analyze`/tests won't catch it structurally, so `qa` should specifically verify each newly-registered calculator's error AND success dialog fire at least once when retrofitting/adding a 15th+ calculator.

## Alternatives considered

- **One named field per calculator** (`bmiStatus`, `idealWeightStatus`, ...): more type-safe (no stringly-typed id, exhaustiveness-checkable), but doesn't solve the actual problem — it's the exact same 14-field repetition in `copyWith`/`clearForm`/`props`, just with one field instead of four. Rejected: doesn't reduce the boilerplate surface the tech-lead flagged, and still requires a `patient_details_page.dart` edit per new calculator (can't generically iterate named fields without reflection).
- **Bools-bag class** (`{isSaving, isError, errorMessage, isSaved}` as plain fields, no sealed hierarchy): simpler, but reintroduces the possibility of an invalid combination (`isSaving == true && isSaved == true`) that a sealed hierarchy makes structurally unrepresentable, and doesn't match this codebase's existing `Result<T,E>` convention for outcome-representing types. Rejected in favor of the sealed hierarchy for consistency (explicitly requested) and the stronger invariant.
- **Storing dialog copy in a separate `Map<String, ({String error, String success})>` config keyed by id, read by `patient_details_page.dart`:** considered so the cubit wouldn't need to pass `successMessage` through `_saveCalculation`. Rejected: it reintroduces a second per-calculator config surface that must stay in sync with the cubit's per-calculator error-fallback string, and doesn't remove any duplication — the cubit still needs its own error-fallback string for `Result.isError` cases where the repository didn't provide one. Carrying both strings inside `CalculatorSaveStatus` keeps exactly one per-calculator copy declaration (at the `saveXCalculation` call site) and needs nothing new in `patient_details_page.dart`.
