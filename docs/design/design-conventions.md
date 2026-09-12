# Design Conventions

Concrete UI/UX conventions not already captured by `lib/shared/design_system/tokens/`. Read this before designing any new feature; append short, concrete entries here (a rule + the reasoning) rather than re-deriving decisions each time. See `docs/design/README.md` for how this file relates to `user-personas.md` and per-feature notes.

---

## Feedback dialogs (existing pattern, documented for reference)

- Success: auto-closing `DsDialog` (`duration` param), no user action required, no redirect unless the feature explicitly needs one (e.g. Create Patient redirects Home after save; Edit Patient does not).
- Error: `DsDialog` with a close button and no `duration` — user dismisses explicitly and can retry (form data/state is preserved behind the dialog).
- Both go through `DsDialog.show`, which itself dismisses via `getIt.get<AppRouter>().pop()`, not raw `Navigator.pop`.

---

## `DsBottomSheet` (new, Roadmap priority 3)

Location: `lib/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart`.

### Purpose / invocation

Generic modal bottom sheet, invoked the same way as `DsDialog`:

```dart
Future<T?> result = await DsBottomSheet.show<T>(
  context,
  title: 'Optional title',
  body: someWidget,          // required
  actions: [DsButton(...)],  // optional
  isDismissible: true,       // default
  enableDrag: true,          // default
  maxHeightFraction: 0.9,    // default; content-driven below this
);
```

This component only ships the shell. It has no calculator/history-specific content — those flows (Calculators "insert data", History "result display") are separate roadmap items that will pass their own `body`/`actions`.

### Layout (top to bottom)

1. **Drag handle** — small pill, centered, `width 40 x height 4`, `DsColors.gray`, rounded (`DsRadius.full`), top padding `DsSpacing.sm`. Always shown when `enableDrag: true` (visual affordance matching the actual gesture); omitted when `enableDrag: false` so the sheet doesn't imply a gesture it doesn't support.
2. **Title** (optional) — only rendered if `title != null`. Same text style as `DsDialog`'s title (`fontWeight: w700`, `DsTypography.large`, `DsColors.black`). Padding `DsSpacing.md` horizontal, `DsSpacing.sm` vertical (top), no bottom padding — the body's own top padding provides the gap.
3. **Body** — the required scrollable content area. Wrapped in `SingleChildScrollView` inside a `ConstrainedBox(maxHeight: maxHeightFraction * screenHeight)`. Horizontal padding `DsSpacing.md`; vertical padding `DsSpacing.sm` (top) / `DsSpacing.md` (bottom, or 0 if `actions` follow — the divider provides the visual break instead).
4. **Divider** — a plain `Divider` (`DsColors.gray`, no token exists for divider color today — reuse `DsColors.gray` rather than introducing a new token for one hairline) — rendered **only when `actions != null`**, directly above the actions row. This is what distinguishes "scrolled content" from "fixed footer": the divider signals the boundary regardless of whether the body content actually overflowed.
5. **Actions** (optional) — `Row(children: actions)` with `DsSpacing.sm` gaps between buttons (mirrors `DsDialog.actions`' shape: a plain widget list, caller controls `Expanded`/sizing per button). Fixed at the bottom, outside the scrollable body, padded `DsSpacing.md` on all sides plus `MediaQuery.of(context).viewInsets.bottom` so the row is never covered by the keyboard.

### Sizing / drag behavior

- **Content-driven height, not full-screen** (resolves PO open question 1): `showModalBottomSheet(isScrollControlled: true, ...)` + the body's `ConstrainedBox(maxHeight: maxHeightFraction * MediaQuery.of(context).size.height)`. Short content wraps naturally (`mainAxisSize: MainAxisSize.min` on the outer `Column`); content taller than `maxHeightFraction` becomes internally scrollable rather than clipped or forcing full-screen.
- `maxHeightFraction` defaults to `0.9`, exposed as an optional param so a caller with unusually long content (e.g. a long calculator form) can raise/lower it — this is the "optional max-height-fraction override" the PO asked for, not a separate variant/widget.
- **Corner radius:** top corners only, `DsRadius.small` (16, matches `DsDialog`'s corner radius) via `RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: DsRadius.small))`. Background `DsColors.white` (matches `DsDialog`'s card background).
- **Scrim:** use the platform default modal barrier (`Colors.black54`) — no DS token exists for a scrim color today, and `DsDialog` doesn't override it either (via `showAdaptiveDialog`'s default barrier). Don't introduce a new color token for this; flag as a candidate for the priority-8 DS color audit if a non-default scrim is ever needed.
- **Keyboard safety:** `showModalBottomSheet` is already keyboard-aware when `isScrollControlled: true`; additionally wrap the whole sheet in `Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))` so the actions row and the tail of the body scroll above the keyboard when a `DsTextfield` inside `body` gains focus, rather than being obscured.

### Dismiss / interaction rules

- Tap-outside dismisses iff `isDismissible: true` (maps 1:1 to `showModalBottomSheet`'s `isDismissible`).
- Drag-down dismisses iff `enableDrag: true` (maps 1:1 to `enableDrag`).
- System back button/gesture: same as `isDismissible` — Flutter's modal route already ties back-navigation to `isDismissible` by default; no special-case needed.
- Any explicit close affordance inside `actions` (e.g. a "Cancelar" `DsButton`) must dismiss via `getIt.get<AppRouter>().pop()` (see result-passing note below), not raw `Navigator.pop`, matching `DsDialog`'s convention.
- **Single-instance v1** (resolves PO open question 2): `DsBottomSheet.show` guards against a second concurrent sheet with a static open/closed flag — a second `show()` call while one is already open is a no-op (returns the in-flight `Future` rather than stacking a second sheet). Stacking is out of scope until a real use case needs it.
- **Accessibility/RTL** (PO open question 3): not addressed here — same gap exists in `DsDialog`/`DsSelect` today. Tracked under the broader roadmap priority 8 (Design System audit), not blocking this component.

### Result-passing (`Future<T?>`) — requires one `AppRouter` extension

`DsBottomSheet.show<T>` returns `Future<T?>`, resolved from whatever value the sheet is popped with — the same mechanism `showModalBottomSheet` already provides via `Navigator.of(context).pop(result)`.

**Gap found while speccing this:** `AppRouter.pop()` (`lib/routing/app_router.dart`) is currently `void pop()` with no result parameter, so nothing inside a `DsBottomSheet` can call `getIt.get<AppRouter>().pop(result)` today. This needs a small, backward-compatible signature change before result-passing can work end-to-end:

```dart
void pop<T extends Object?>([T? result]); // instead of void pop();
```

`AppRouterImpl.pop` forwards to `router.pop(result)` (GoRouter's own `pop` already accepts an optional result and forwards to the underlying `Navigator`, which is what a bottom-sheet route sits on). This is a one-line, additive change — existing `getIt.get<AppRouter>().pop()` call sites (dialogs, etc.) keep working unchanged since `result` defaults to `null`. Flagging here rather than in code because it's an interface change outside this component's own file, for `mobile-dev` to make as part of implementing `DsBottomSheet`.

### Composition with other DS widgets

- `body` accepts arbitrary widgets, most commonly a `Column` of `DsTextfield`s (form entry) or a read-only summary (`Text`/`DsTextfield(disabled: true)` pairs for history detail) — no bottom-sheet-specific wrapper needed beyond the scroll/padding shell above.
- `actions` accepts `DsButton`s exactly like `DsDialog.actions` — same `Row` shape, so a caller migrating a save/cancel action pair from a dialog to a bottom sheet doesn't need to change the buttons themselves.
- No new variant is introduced (no separate "compact" vs. "scrollable" widget) — `maxHeightFraction` plus the content-driven default cover both cases the roadmap currently anticipates (a calculator input form, a history detail view). Don't add more configurability than that until a concrete need surfaces.
