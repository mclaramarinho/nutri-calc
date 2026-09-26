# 0010. Generic cross-table delete dispatch + one shared swipe-to-delete DS widget, closing the pre-existing `MeasurementsList` gap

**Status:** Accepted
**Date:** 2026-09-26
**Feature:** [docs/roadmap.md §2.1.4 Patient Details - Tabs, History, Slice 11](../roadmap.md#214-patient-details---tabs) (coordinator-approved scope expansion to also close `MeasurementsList`'s TODO'd `Dismissible`)

## Context

Slice 11 needs delete-on-swipe in two places: the new History tab (14 heterogeneous sources, one of which — Weight — has a hard cross-tab data-integrity constraint) and `MeasurementsList` (Weights/Heights/Body Measurements tabs), whose `Dismissible` has been commented out since it shipped, with a literal `// TODO - use when delete weight record is available`. **No delete-on-drag exists anywhere in this codebase today** — `WeightRepository`, `HeightRepository`, `BodyMeasurementRepository`, and all 12 non-Weight calculator repositories expose only `createX`/`getX`, never `deleteX`, even though `AppDatabaseService.delete(...)` has existed generically since the DB service was written. The roadmap's History requirement (AC5/AC6) explicitly requires History's Weight-type delete to go through "the exact same delete+recompute path the Weights tab's own delete flow uses" — but that path doesn't exist yet either, so this ADR has to define it, not just reuse it.

Two things needed a single, explicit decision before `mobile-dev` could build either tab's delete interaction without re-deriving architecture: (1) how one generic delete interaction (confirm → delete → success/error dialog) is written once and reused by both a `MeasurementsListItem` row and a `HistoryEntryEntity` row, given `CLAUDE.md`'s DS-widgets-only convention; (2) how a Weight-type History deletion and a Weights-tab deletion are guaranteed to go through the same code path, not two independently-written call sites that could drift.

## Decision

**(a) One new DS widget, `DsDismissibleTile`** (`lib/shared/design_system/widgets/ds_dismissible_tile/ds_dismissible_tile.dart`), wrapping `Dismissible` + `DsDialog` confirm/success/error orchestration, content-agnostic:

```dart
class DsDismissibleTile extends StatelessWidget {
  const DsDismissibleTile({
    required this.itemKey,
    required this.child,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.onDelete, // the actual delete call
    this.successMessage = "Excluído com sucesso.",
    this.errorMessage = "Não foi possível excluir. Tente novamente.",
    super.key,
  });

  final Key itemKey;
  final Widget child;
  final String confirmTitle;
  final String confirmMessage;
  final Future<Result<void, String>> Function() onDelete;
  final String successMessage;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _showConfirmDialog(context); // DsDialog, 2 actions
        if (confirmed != true) return false;

        final res = await onDelete();
        if (res.isError) {
          await DsDialog.show(context, title: "Erro", message: errorMessage, showCloseButton: true);
          return false; // item stays — matches roadmap's "on error, list untouched"
        }

        await DsDialog.show(context, title: "Sucesso", message: successMessage,
            showCloseButton: false, isDismissible: false, duration: const Duration(seconds: 2));
        return true; // let Dismissible remove it locally; the owning Bloc
                     // state is expected to have already been refreshed by
                     // onDelete's caller (see part b) so the rebuilt list
                     // agrees with Dismissible's local removal.
      },
      background: /* red delete-icon background, DsColors */,
      child: child,
    );
  }
}
```

`onDelete` returns `Result<void, String>` (this codebase's standard error-handling idiom) and is expected to *already* trigger any necessary state refresh (e.g. the cubit's `deleteWeight` re-running `GetWeightsUseCase`) before resolving — `DsDismissibleTile` itself has no knowledge of cubits/state, only of the confirm/delete/dialog choreography. This is the "design it once" primitive both `MeasurementsList` and `PatientHistoryTab` wrap their own row content in.

`MeasurementsList` is edited to replace its commented-out `Dismissible` with `DsDismissibleTile`, taking a new required `Future<Result<void,String>> Function(String id) onDelete` callback (analogous to how it already takes `dataList`), closing the pre-existing TODO for all three tabs (Weights/Heights/Body Measurements) in one pass, per the coordinator-approved scope expansion.

**(b) One canonical delete-and-refresh path per data owner, on `PatientDetailsCubit`** — not two independently-written call sites. `PatientDetailsCubit` gains:

```dart
Future<Result<void, String>> deleteWeight(String id) async {
  final res = await _deleteWeightUseCase(id);
  if (res.isOk) await _refreshWeightsAndHistory(); // re-fetches weights AND historyEntries
  return res;
}
Future<Result<void, String>> deleteHeight(String id) async { /* same shape, heights only */ }
Future<Result<void, String>> deleteBodyMeasurement(String id) async { /* same shape, bodyMeasurements only */ }

Future<Result<void, String>> deleteHistoryEntry(HistoryEntryEntity entry) async {
  final res = await _deleteCalculatorHistoryEntryUseCase(entry);
  if (res.isOk) {
    if (entry.sourceType == HistorySourceType.weight) {
      await _refreshWeightsAndHistory();
    } else {
      await _refreshHistoryOnly();
    }
  }
  return res;
}
```

Both `MeasurementsList`'s Weights tab instance and `PatientHistoryTab` call `context.read<PatientDetailsCubit>().deleteWeight(id)` for a Weight-type row — **the identical method**, not two call sites that both happen to delete from `WEIGHTS`. This structurally satisfies the roadmap's AC6 ("exact same delete+recompute path"), rather than relying on convention/code review to keep two independent implementations in sync.

**No persisted "curve" to recompute.** Investigated `patient_measurements_tab.dart::castToListItem` (the only place `MeasurementsListCurve` is computed): the asc/desc trend icon is a **pure, derived-at-render-time function of the current in-memory list** (`prev = listData[i+1].value`), not a stored column. There is no separate "recompute" algorithm to build — deleting the row and re-running the existing `GetWeightsUseCase` (already the after-create pattern used by `saveWeight`) is sufficient; `castToListItem` naturally produces correct curves for the remaining, now-adjacent entries on the next build. `mobile-dev` should not build a new curve-recomputation routine; this ADR records that none is needed, since a plausible misreading of the roadmap's "recompute curves" wording could lead to over-building here.

**(c) Delete dispatch for History is centralized in one orchestrator, `DeleteCalculatorHistoryEntryUseCase`** (mirrors ADR 0009's `GetPatientCalculatorHistoryUseCase` shape):

```dart
abstract class DeleteCalculatorHistoryEntryUseCase {
  Future<Result<void, String>> call(HistoryEntryEntity entry);
}
@Injectable(as: DeleteCalculatorHistoryEntryUseCase)
class DeleteCalculatorHistoryEntryUseCaseImpl implements DeleteCalculatorHistoryEntryUseCase {
  const DeleteCalculatorHistoryEntryUseCaseImpl({required this._deleteBmi, /* ...14 leaf deletes... */});
  @override
  Future<Result<void, String>> call(HistoryEntryEntity entry) {
    return switch (entry.sourceType) {
      HistorySourceType.bmi => _deleteBmi(entry.id),
      // ... 12 more ...
      HistorySourceType.weight => _deleteWeight(entry.id),
    };
  }
}
```

Same rationale as ADR 0009's orchestrator: `PatientDetailsCubit` injects one use case (`DeleteCalculatorHistoryEntryUseCase`), not 14; each of the 14 leaf `DeleteXUseCase`s is a 3-line wrapper over its repository's new `deleteX(id)` method (backed by `AppDatabaseService.delete(.x, where: 'id = ?', whereArgs: [id])`, the exact pattern every `createX` already follows for `insert`). `DeleteWeightUseCase` is the one leaf reused directly by `PatientDetailsCubit.deleteWeight` too (not duplicated) — it is injected into both `DeleteCalculatorHistoryEntryUseCaseImpl` and `PatientDetailsCubit`.

Deleting a non-Weight entry only ever touches its own table (no cross-tab concept exists for BMI/Energy Expenditure/etc.), consistent with the roadmap's explicit scoping of the recompute requirement to Weight only.

## Consequences

- Closes a real, previously-shipped-with-a-TODO gap in `MeasurementsList` as a side effect of building History's delete requirement properly, per the coordinator's explicit scope-expansion approval — not scope creep introduced by this ADR.
- `PatientDetailsCubit`'s constructor grows by exactly 4 across this ADR + ADR 0009 combined (`GetPatientCalculatorHistoryUseCase`, `DeleteCalculatorHistoryEntryUseCase`, `DeleteHeightUseCase`, `DeleteBodyMeasurementUseCase`) plus reuse of the new `DeleteWeightUseCase` — not 14+ leaf use cases directly, keeping the existing 18-calculator-save-use-case constructor from roughly doubling.
- Every future calculator table automatically gets delete-on-drag support in History "for free" once its `GetXHistoryUseCase`/`DeleteXUseCase` pair is added (ADR 0009's pattern) and one line is added to this ADR's orchestrator — no `DsDismissibleTile`/`MeasurementsList` change needed ever again.
- Rules out an optimistic-UI delete (item disappears from the list before the DB confirms) — `DsDismissibleTile` only returns `true` (letting `Dismissible` complete its removal animation) after `onDelete` has resolved `Ok`, matching the existing roadmap requirement's confirm→delete→dialog sequencing for Weights/Heights/Body Measurements.
- A `DsDismissibleTile` instance whose `onDelete` never resolves (a hung `Future`) blocks that row's swipe gesture indefinitely with no visible spinner — no different from every other `Future`-returning action in this codebase (e.g. `saveWeight`), so not treated as a new risk requiring extra handling here.

## Alternatives considered

- **Two independent `Dismissible` implementations** (one hand-rolled in `PatientHistoryTab`, one fixing `MeasurementsList`'s existing TODO separately). Rejected: directly risks the exact drift AC6 is designed to prevent, and duplicates confirm/success/error dialog boilerplate the roadmap's Weights/Heights/Body Measurements spec already describes identically for both.
- **`MeasurementsList` and `PatientHistoryTab` each call their own repository/use case directly for delete**, bypassing `PatientDetailsCubit`. Rejected: the History tab and Weights tab would then have two independent post-delete refresh mechanisms for the same `WEIGHTS` table, reopening exactly the "two call sites could disagree" risk the roadmap's AC6 flags as a regression to guard against with a cross-tab test.
- **A persisted `curve` column on `WEIGHTS`, recomputed on every delete.** Rejected: curves are cheap to derive at render time from an already-in-memory, already-sorted list; persisting and recomputing them would add a genuinely new stored-derived-value invalidation problem for no behavioral benefit, and no other measurement table has ever needed one.
