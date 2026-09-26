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

---

## `DsButton` disabled state (new, Roadmap priority 4)

Location: `lib/shared/design_system/widgets/ds_button/ds_button.dart`.

### Param name/shape: `disabled` (bool, default `false`)

Not `enabled`. `DsTextfield` already established the DS-internal convention of a `disabled` bool defaulting to `false` (see `lib/shared/design_system/widgets/ds_textfield/ds_textfield.dart`) — match it for cross-widget consistency rather than following bare Material's `enabled: true` convention (`DsSelect` still does that internally, but doesn't expose it as a public param, so it isn't a competing public-API precedent). One DS-wide rule: **disableable DS widgets expose `disabled` (default `false`), not `enabled`.** This is an API-shape call but stated here so it isn't re-litigated per widget.

```dart
const DsButton({
  required this.label,
  required this.isLoading,
  required this.onTap,
  this.disabled = false,
  super.key,
});
```

### `isLoading` implies disabled interaction, but is visually distinct

- A loading button (`isLoading: true`) is always non-tappable, regardless of `disabled`'s value — callers shouldn't have to also pass `disabled: true` while saving; `isLoading` already means "an operation is in flight, don't let the user double-submit." Internally: `onPressed: (disabled || isLoading) ? null : onTap`.
- Visual treatment differs between the two states — they communicate different things to the user:
  - **`isLoading: true`**: keep today's look (button stays in its normal/enabled visual style, `CircularProgressIndicator` replaces the label) — this already reads as "working on it," not "unavailable."
  - **`disabled: true` (and not loading)**: dimmed/flat treatment (spec below) — reads as "unavailable right now," e.g. required fields still empty.
- If both are somehow true at once, `isLoading`'s visual wins (spinner), since "in flight" is the more specific/urgent state and this combination shouldn't occur in practice given the use cases described (a button is either waiting on required fields, or saving — not both).

### Visual spec for `disabled: true` (not loading)

Token gap found: `lib/shared/design_system/tokens/ds_colors.dart` only has `white`/`blue`/`black`/`gray` (`gray` = `Colors.grey.shade200`, already used as the `DsBottomSheet` divider/drag-handle color) — there's no dedicated "disabled" or "on-disabled-text" color, and no opacity-scale token anywhere in `tokens/`. Rather than inventing a new token file entry for a one-off, and given `DsButton` itself is still an unstyled `ElevatedButton` (`// TODO - style this button`), use `ElevatedButton.styleFrom`'s dedicated disabled slots so the treatment is deliberate and reads consistently once the button gets its full restyle:
  - `disabledBackgroundColor: DsColors.gray` (reuses the existing light-gray token — same "inert/inactive" association it already carries as a divider/handle color, no new token needed).
  - `disabledForegroundColor: DsColors.black.withValues(alpha: 0.38)` — approximates Material's own disabled-content-opacity convention (38%) using an existing token (`DsColors.black`) rather than adding a new gray shade. Flag as a candidate for a proper `DsColors.textDisabled` token in the priority-8 DS color/token audit if this alpha-on-token pattern recurs elsewhere.
  - No elevation/shadow while disabled (`elevation: 0` in the disabled branch, or rely on Material's default of dropping elevation for a null `onPressed` — either is acceptable, just confirm it doesn't float above content once the button gets real elevation styling).
  - Cursor/tap feedback: comes for free once `onPressed` is `null` — Material already suppresses ripple/hover/cursor changes for a disabled `ElevatedButton`; no extra code needed beyond wiring `onPressed` as described above.
  - This state must look visually distinct from both enabled (currently default `ElevatedButton` color, e.g. Material's default primary) and loading (same look as enabled + spinner) — the gray fill + reduced-opacity label achieves that without a new token family.

### Copy / scope confirmation

- Copy-agnostic: no label/text changes are needed for the disabled state itself (the label stays e.g. "Salvar"; only enablement and paint change). Roadmap 2.1.4's rules ("disabled while required fields empty," "disabled while saving") are pure state-gating, not new copy.
- No other DS token gap blocks this beyond the `DsColors`/opacity note above, which has a workaround (alpha on an existing token) and doesn't need to block implementation.
- Out of scope here (per task boundaries): wiring `disabled:` into the actual Weights/Heights/Body Measurements Save buttons — that's the separate, still-open roadmap item that will consume this new param.

---

## `DsCheckbox` (new, Roadmap priority 5 — 4 missing Patient boolean fields)

No checkbox/switch widget existed anywhere in the app before this. Resolves the 5 open questions logged in `docs/roadmap.md` 2.1.1 "Confirmed requirement for the 4 missing fields".

Location (to be created by `mobile-dev`): `lib/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart`.

### API

Stateless, controlled component (value comes from the cubit's state, not an internal controller) — unlike `DsTextfield`'s internal-`TextEditingController` pattern, a `bool` has no equivalent reason to own its own state, and `BlocBuilder` already rebuilds on every state change:

```dart
const DsCheckbox({
  required this.label,
  required this.value,
  this.onChanged,
  this.disabled = false,
  this.helperText,
  super.key,
});
```

- `label` (`String`, required) — rendered beside the box, tappable (see below).
- `value` (`bool`, required) — current checked state, driven by the caller's state (same pattern as `DsTextfield(customController: ...)` being fed from cubit state).
- `onChanged` (`void Function(bool value)?`) — fires on toggle. Nullable (not `required`) for future read-only/display-only use beyond this feature's `disabled` case.
- `disabled` (`bool`, default `false`) — follows the DS-wide rule already established for `DsTextfield`/`DsButton`: disableable DS widgets expose `disabled` defaulting to `false`, never `enabled`. Don't re-litigate this per widget.
- `helperText` (`String?`, optional) — single line of caption copy rendered under the label, left-aligned with the label (not the box). Omit when not needed; see "Confined to bed" decision below for the one field that uses it.

### Visual spec

- Layout: `Row` — `Checkbox` (Material `Checkbox`, not a custom paint — no DS precedent for a custom checkbox paint, and Material's own gives correct platform tap/ripple/accessibility semantics for free) + `SizedBox(width: DsSpacing.sm)` + `Expanded` containing label (+ optional helper line below it in a `Column`).
- Whole row wrapped in a tap target (`InkWell`/`GestureDetector`) that toggles `value` when tapped anywhere on the row (box or label) — matches the general mobile-forms convention of a large tap target for boolean toggles, and avoids a precuse requiring users to hit the small box itself.
- Label text: `DsTypography.small` (16), `DsColors.black`, regular weight — same text size `DsTextfield` uses for its field text, for visual parity between the two input types on the same form.
- Helper text (when present): `DsTypography.xxs` (12), `DsColors.black.withValues(alpha: 0.54)` — smaller and dimmer than the label, same "secondary copy" intent as `DsTextfield`'s `hintText`, no existing token for this muted color so reuse alpha-on-black per the precedent already accepted for `DsButton`'s disabled spec (see above) rather than inventing a new token.
- Checked state: box fill `DsColors.blue`, check glyph white — `DsColors.blue` is the app's only brand/primary color today (used by `DsButton`'s default `ElevatedButton` color), so reuse it rather than adding a new "primary" token.
- Unchecked state: box outline only (no fill), outline color `DsColors.black` at Material's default unselected-checkbox opacity (no fill token needed — this is Material's default `Checkbox` unselected visual, don't override it).
- Disabled (checked or unchecked), mirrors `DsTextfield`'s/`DsButton`'s disabled treatment exactly, for visual consistency across all three disableable DS widgets:
  - Box: fill/outline `DsColors.gray` (reuses the same "inert" token `DsButton.disabledBackgroundColor` already uses).
  - Label + helper text: `DsColors.black.withValues(alpha: 0.38)` (same 38% convention as `DsButton`'s `disabledForegroundColor`).
  - Row's `InkWell` has no tap handler when `disabled: true` (`onChanged` not called; no ripple) — same "comes for free once the tap callback is null" approach `DsButton` already relies on.

### Open item for `mobile-dev`/`senior-analyst`, not blocking

A proper `DsColors.textDisabled`/`textMuted` token (replacing the repeated `DsColors.black.withValues(alpha: ...)` pattern now used by `DsButton`, and here by `DsCheckbox`'s disabled label and helper text) is a good candidate for the priority-8 DS color/token audit — flagging again since it's now recurring, not introducing it ad hoc for a single widget. (Now recurring a third time — see `DsListTile`'s trailing-icon color below.)

### Feature-specific decisions for the 4 Patient boolean fields

- **Labels (final):** "Nutrição Enteral", "Nutrição Parenteral", "Hospitalizado", "Restrito ao leito" — the proposed labels in the roadmap are confirmed as-is, no wording changes.
- **Helper text:** only "Restrito ao leito" gets one — `helperText: "Paciente não consegue andar ou tem dificuldade significativa para caminhar."` The other 3 fields are unambiguous clinical shorthand a dietitian already uses verbatim ("nutrição enteral/parenteral", "hospitalizado"); "confinado ao leito" is the one term where the roadmap's own clarifying sentence ("can't walk, or requires a lot of effort to walk") adds real disambiguation value (e.g. distinguishing from "restrito à casa"/homebound), so it's worth surfacing to the user, not just keeping as internal doc.
- **Order (within the group of 4, both forms):** Enteral Nutrition → Parenteral Nutrition → Hospitalized → Confined to bed — matches the roadmap field table's canonical order; no reason to reorder.
- **Placement (both Create Patient and Patient Details forms):** after Birthdate, as the last field group before the Save button (Create Patient) / before the form ends (Patient Details). Deliberately **not** matching 2.1.3's prose order (booleans right after Patient Id) — that prose ordering was never confirmed as an intentional spec (roadmap's own open question 3 says so), whereas the field table order is explicit, and Patient Details is a read/edit mirror of the Create form today (same fields, same `DsTextfield`s, same top-to-bottom order) — keeping the two forms' field order identical avoids a dietitian having to re-learn a different layout when editing vs. creating.
- **Layout/grouping:** single column (one `DsCheckbox` per row, full width), not a 2x2 grid. The 4 labels vary in length and one (`Restrito ao leito`) carries a helper line that needs full row width to read as one clause without wrapping awkwardly in a half-width column; single column also keeps a consistent vertical scan pattern with the rest of the form's fields. `DsSpacing.sm` vertical gap between the 4 checkboxes (tight, since they're one related group).
- **Section label (new pattern — first use of a section header in a DS form):** yes, add a plain section label **"Informações Clínicas"** directly above the 4 checkboxes, in both forms. Style: `DsTypography.medium` (18), `fontWeight: FontWeight.w600`, `DsColors.black`, `DsSpacing.md` top margin / `DsSpacing.sm` bottom margin. This is a new structural pattern (the forms were flat `Column`s with no headers before) — introduced here because the 4 booleans are visually/semantically a distinct group (clinical status flags) from the identity/demographic fields above them (ID, name, age, birthdate), and a plain `Text` label is the minimal way to signal that without inventing a new DS widget (e.g. a "section divider" component) for a single use case. If a second feature needs grouped sections, consider promoting this to a small `DsSectionLabel` widget instead of repeating the raw `Text` styling — noting this here so it isn't missed when that need arises, but not building it preemptively for one call site. **Flag for `senior-analyst`:** this is a new-enough structural precedent (not just a token reuse) that a short ADR recording "flat forms may introduce a plain text section label for grouped fields, promote to a widget on the second use case" could be warranted — judgment call, not mandatory.

---

## `DsLoadingIndicator` (new, Roadmap priority 5 — List Patients Gap 3)

Location (to be created by `mobile-dev`): `lib/shared/design_system/widgets/ds_loading_indicator/ds_loading_indicator.dart`. Full spec: `.claude/outputs/senior-designer/list_patients_ds_components.md`.

Wraps `CircularProgressIndicator` with two variants selected by a required-with-default enum param (`variant`, default `DsLoadingIndicatorVariant.page`), not two separate widgets — same "one component, param-driven variants" shape as `DsBottomSheet`'s `maxHeightFraction` rather than a `DsFullPageLoadingIndicator`/`DsInlineLoadingIndicator` pair.

- `page` (default): `48×48` (new token `DsSizing.loadingIndicatorPage`), `strokeWidth: 4`, self-centers via `Center` (safe because callers are always a bounded `Scaffold`/tab body), color defaults to `DsColors.blue`. First consumer: List Patients' `ListPatientsStateLoading` case.
- `inline`: `20×20` (new token `DsSizing.loadingIndicatorInline`), `strokeWidth: 2.5`, no `Center` (caller positions it, e.g. inside a `Row`/button), color defaults to `DsColors.white` (assumes it sits on a filled primary-colored surface unless overridden via the optional `color` param). Not consumed by any feature yet — specced now so `DsButton`'s own still-unstyled `isLoading` spinner (`lib/shared/design_system/widgets/ds_button/ds_button.dart`, bare `CircularProgressIndicator` today) has a ready-made target for a future retrofit, without a breaking API change then. That retrofit is explicitly **not** done as part of this pass.

New tokens (`lib/shared/design_system/tokens/ds_sizing.dart`, which previously only had `iconAppBar`/`iconButton` — neither fit a spinner): `loadingIndicatorPage => 48.w`, `loadingIndicatorInline => 20.w`.

---

## `DsListTile` (new, Roadmap priority 5 — List Patients Gap 3)

Location (to be created by `mobile-dev`): `lib/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart`. Full spec: `.claude/outputs/senior-designer/list_patients_ds_components.md`.

Generic row component (`overline?`, `title`, `subtitle?`, `leading?`, `trailing?`, `onTap?`) — introduced now, not after a second call site, because one already exists in embryonic form: `lib/features/patients/details/presentation/widgets/measurements_list.dart` uses a raw `ListTile` with the same title+subtitle+optional-trailing-icon shape. `DsListTile` is not wired into `MeasurementsList` in this pass (separate call site/ticket) but the API was shaped so it can be later without redesign.

- `title`/`subtitle`/`overline` are typed `String` (not `Widget`), matching the DS-wide convention of plain-text params for text content (`DsButton.label`, `DsCheckbox.label`).
- `overline` is DS-new (no Material `ListTile` equivalent) — a small muted line above `title`, added specifically so List Patients' optional `patient.patientId` line doesn't force every consumer into building its own two-line title `Column`. Omitted entirely (no reserved space) when `null`.
- **No auto-injected trailing chevron** when `onTap != null` — callers pass their own `trailing` explicitly (a chevron for List Patients, a trend icon with no `onTap` for `MeasurementsList`). Matches `DsBottomSheet`'s already-documented explicit-slots-over-auto-content philosophy (see above).
- Visual: `overline`/`subtitle` both use `DsTypography.xxs` (12) + `DsColors.black.withValues(alpha: 0.54)` — the same muted-secondary-copy treatment already established for `DsCheckbox.helperText`, reused rather than inventing a second muted style. `title` uses `DsTypography.small` (16) + `FontWeight.w600` (bolder than `DsCheckbox`'s label — a list row's title is the primary at-a-glance anchor, unlike a form label beside its own input). `DsSpacing.xxs` gap between the three text lines (one semantic block, not independent paragraphs). Outer padding `DsSpacing.md` horizontal / `DsSpacing.sm` vertical.
- Tap handling: `onTap == null` ⇒ plain `Row`, no ripple/semantics; `onTap != null` ⇒ whole row wrapped in `InkWell`. Same "null callback ⇒ no interaction, comes free" pattern as `DsButton`/`DsCheckbox`.

**List-separator convention (DS-wide, not `DsListTile`-internal):** a row component doesn't own its own divider — separators are the caller's `ListView.separated` responsibility. `MeasurementsList` already established this hairline style; reuse it verbatim rather than inventing a second one:

```dart
separatorBuilder: (context, index) => SizedBox(
  height: 1,
  width: MediaQuery.sizeOf(context).width,
  child: Container(color: DsColors.gray),
),
```

**Recurring token gap (3rd occurrence):** List Patients' trailing chevron uses `DsColors.black.withValues(alpha: 0.38)` for a subtle (not disabled) affordance icon — the same alpha-on-`DsColors.black` value `DsButton`/`DsCheckbox` already use for their *disabled* states, reused here for a different semantic (de-emphasis, not disability) purely because no dedicated muted/tertiary color token exists. Still flagging for the priority-8 `DsColors.textMuted`/`textDisabled` token audit, not blocking.

---

## Calculators tab — Slice 5 (Enteral Nutrition x3, Glucose Infusion Rate)

Two open UX items PO flagged for this slice, both resolved here so they aren't re-derived per-calculator going forward.

### No visual "exceeds clinical threshold" flag on calculator results (yet)

Glucose Infusion Rate (TIG) has a known clinical safety ceiling (~4–5 mg/kg/min, see the source comment in `calculate_glucose_infusion_rate.usecase.dart`), but its result ships as **plain result text**, identical in treatment to all 5 existing calculators (default `Text` color, i.e. no `DsColors.error` or any color override — just `FontWeight.w700`, same as Nitrogen Balance's/Protein Needs' result lines; note `DsColors` has no dedicated "primary text" token today, only `white`/`blue`/`black`/`gray`/`error`). No new "danger" visual state is introduced in this slice.

Reasoning: every shipped calculator result today renders the same way regardless of clinical interpretation (e.g. BMI already carries classification bands — low/eutrophy/overweight/obesity I-III — and still renders as plain bold text, no color-coding by band). Introducing a red/warning treatment for exactly one calculator, one threshold, would be a new precedent invented for a single call site rather than a deliberate cross-calculator pattern — and BMI is the obvious next candidate that would immediately want the same treatment once it exists, which argues for designing it once, on purpose, covering both. **This belongs in a future dedicated slice (or a short ADR) once there's a second calculator that needs it**, so the pattern (threshold config shape, color/icon spec, whether it's a hard color swap or an inline badge) is designed for reuse rather than retrofitted. Flagging as a candidate here rather than deferring silently.

### Tile name for Glucose Infusion Rate: **"TIG"**, not "Taxa de Infusão de Glicose"

Existing tile `name`s (`patient_calculators_tab.dart:_buildDefinitions`) are consistently short clinical shorthand a dietitian already uses verbatim, not spelled-out clinical terms — "IMC" (not "Índice de Massa Corporal (IMC)" — that longer parenthetical style doesn't actually exist anywhere in the app today, confirmed by inspection), "Gasto Energético", "Balanço Nitrogenado", "Necessidade Proteica", "Necessidade Hídrica". There is no existing "full name (abbreviation)" tile pattern to follow. "TIG" fits this house style directly — it's the term dietitians use in practice — and is also the same rationale already used for the Patient boolean field labels ("nutrição enteral/parenteral" confirmed as "unambiguous clinical shorthand a dietitian already uses verbatim", no expansion needed).

Practically: `CalculatorType.parenteralNutrition.label` is "Nutrição Parenteral" (the group header in the See All grouped view, single-member group for this slice); the tile `name` "TIG" is distinct from that header, avoiding the duplicate-header risk PO flagged. The full term isn't lost — it's spelled out once in the result line itself ("Taxa de Infusão de Glicose (TIG): X mg/kg/min"), so a first-time reader gets the expansion at the point of use, same as the result already does.

### Enteral Nutrition group — 3 tiles under one header

`CalculatorType.enteralNutrition.label` ("Nutrição Enteral") already exists and is reused unchanged as the shared group header for all 3 new tiles. Tile names confirmed as PO proposed: "Gotejamento", "Velocidade de Infusão", "Volume Total" — all distinct, short, verb/noun-shorthand consistent with the rest of the tile-name set, no changes needed.

### Copy sanity pass (final, for `senior-analyst`/`mobile-dev`)

Field/result labels confirmed as PO wrote them — they match existing conventions (parenthetical unit in the label, e.g. `"Peso Total (mL)"`; result line as `"<Nome>: <value> <unit>"`, bold, no extra punctuation):

- Dripping: `"Volume Total (mL)"`, `"Tempo Total (h)"` → `"Gotejamento: X gotas/min"`
- Speed: `"Volume Diário Total (mL)"` → `"Velocidade de Infusão: X mL/h"`
- Volume: `"Energia Diária Total (kcal)"`, `"Densidade Calórica da Dieta (kcal/mL)"` → `"Volume Total: X mL/dia"`
- Glucose Infusion Rate: `"Peso: X kg"` (derived, matches BMI/Protein Needs' exact `"Peso: ${value} kg"` phrasing — not `"Peso (kg)"`, since derived/read-only fields are rendered as plain `Text`, not `DsTextfield` labels, per the Protein Needs precedent), `"Glicose Total (g)"` → `"Taxa de Infusão de Glicose (TIG): X mg/kg/min"`

Decimal precision: no existing calculator applies a blanket rule — Nitrogen Balance and BMI use `toStringAsFixed(2)`, Protein Needs uses `toStringAsFixed(1)` for its min–max range. For this slice, follow the same case-by-case judgment based on the unit's natural precision, not a new blanket rule:
- Dripping (gotas/min), Speed (mL/h), Volume (mL/dia): `toStringAsFixed(1)` — these are practical dosing/rate numbers a dietitian will round when communicating to nursing staff; one decimal is enough precision without implying false accuracy.
- Glucose Infusion Rate (mg/kg/min): `toStringAsFixed(2)` — mirrors BMI/Nitrogen Balance's 2-decimal convention for a small-magnitude clinical ratio where the second decimal is meaningful relative to the 4–5 threshold.

No wording changes needed beyond precision above — the field/result copy PO drafted already reads naturally in Portuguese and matches tone (title-case field labels, unit in parentheses, result line as `"<Label>: <value> <unit>"`).

---

## Calculators tab — Slice 8 (Ideal Weight — first of 5 Weight sub-types)

First calculator that persists to `WEIGHTS` itself (not a side table) and the first to need the "consider for calculations" checkbox the roadmap calls for generically (2.1.4, "When calculating weight, there should be a checkbox..."). `WeightEntity.considerForCalculations` (bool) and `WeightEntity.weightType` (`WeightTypeEnum`, already has an `.ideal` case with label `"Ideal"`) already exist in code — this slice is the first caller to actually populate them from a calculator flow, not a schema gap.

### Inputs, confirmed against `CalculateIdealWeight` (`lib/shared/services/calculator/domain/use_cases/weight/ideal/calculate_ideal_weight.usecase.dart`)

- `height` (required) — derived read-only from the patient's latest `HeightEntity`, same as every other height-consuming calculator (BMI, Energy Expenditure).
- `gender` (required) — **not derivable**: `PatientEntity` has no gender field anywhere in the codebase (confirmed by grep; Energy Expenditure already hit this same gap and resolved it with a manual `DsSelect<Gender>` field, label `"Sexo"`, options `"Masculino"`/`"Feminino"`). Ideal Weight follows the identical precedent — manual `DsSelect<Gender>` inside the sheet body, not a pre-gate condition (a missing gender is never "insufficient patient data," it's just an un-filled control, exactly like Energy Expenditure treats it).
- `weight` (required by the use case signature) and `amputation` (optional) — **out of scope this slice.** `weight` only feeds the optional amputation adjustment; no amputation UI/selection exists anywhere yet and the roadmap doesn't call for it in this slice. Pass `amputation: null` and any placeholder `weight` the use case needs to not error (confirm exact no-amputation call shape with `mobile-dev`) — flagging as a real gap for whichever future slice (likely Adjusted-Obesity, which is amputation-adjacent) actually needs amputation input, rather than half-building an unused selector here.

### Structure: single-step `DsBottomSheet`, structurally closer to Glucose Infusion Rate than to Weight Loss Classification

Not a fully passive recap (Weight Loss Classification's pattern doesn't fit — there's a manual field to fill in first), and not a two-step formula-picker (Energy Expenditure's pattern doesn't fit — there's only one formula, no branch to pick). Mirrors `GlucoseInfusionRateSheetBody`'s shape exactly:
1. Read-only derived line: `"Altura: {height} cm"`.
2. Manual `DsSelect<Gender>` ("Sexo").
3. A `"Calcular"` `DsButton`, `disabled` (ADR 0003) until gender is selected — same inline-validation-gates-disabled-button pattern as Glucose Infusion Rate.
4. On calculate: result line + the new checkbox appear (see below).
5. `Cancelar`/`Confirmar` action row appears only once a result exists (matches Glucose Infusion Rate's "actions render conditionally on `_resultValue != null`" — no dead Confirmar button before there's anything to confirm).
6. `Confirmar` pops `AppRouter.pop<bool>(true)`-equivalent gathered-inputs record (per ADR 0002's typed-record pattern, e.g. `GatheredIdealWeightInputs = ({Gender gender, bool considerForCalculations})`), same as every other calculator; `Cancelar` pops `null`.

### Insufficient-data pre-gate

Only height gates (gender never does, per above — it's a fillable control, not a missing-data state). Copy, matching the exact house template (`"Não há dados suficientes para calcular o <Nome>. Cadastre ao menos <requisito> para esse paciente."`):

> "Não há dados suficientes para calcular o Peso Ideal. Cadastre ao menos uma altura para esse paciente."

Title: `"Peso Ideal"` (same string used as the tile name — see below).

### Copy

- Tile name (under the existing `CalculatorType.weight` group, label `"Peso"`): **"Peso Ideal"** — matches house style (short clinical term, no parenthetical abbreviation; there's no shorter shorthand dietitians use for this one, unlike "TIG").
- Result line: `"Peso Ideal: {value.toStringAsFixed(1)} kg"` — one decimal, matching body-weight display convention (a kg value dietitians would communicate at one-decimal precision, same reasoning as Slice 5's rate/dosing numbers, not BMI/Nitrogen Balance's 2-decimal ratio convention since this is a plain mass, not a small-magnitude clinical index).
- Checkbox label: **"Considerar este peso para cálculos futuros"**
- Checkbox helper text (new, warranted here unlike most `DsCheckbox` uses): **"Substitui o peso atual como referência até que um novo peso seja marcado dessa forma."** — the override-chain semantics (2.1.4: "the preceding weight that was itself marked consider-for-calculations = true" is used, not simply the immediately-prior row) are non-obvious enough from the label alone that a dietitian could misread "considerar" as purely additive/informational; one line disambiguates without restating the full business rule.

### Checkbox component: reuse `DsCheckbox` as-is, no new widget

`DsCheckbox` (`lib/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart`) already exists (built for the Patient boolean fields) and its API (`label`, `value`, `onChanged`, `disabled`, `helperText`) covers this case exactly — a single boolean with an optional clarifying line. No DS gap, no new component.

### Default state: **checked**

The calculator's own relevance rule means it typically only surfaces because the current weight source is already compromised (BMI indicating obesity/underweight per the existing relevance-filtering pattern) — i.e. a dietitian reaching for Ideal Weight is usually doing so *because* they want a better reference than the scale weight, not to log an incidental number. Defaulting checked matches the common case and keeps the flow low-friction (confirm-without-touching for the typical path); the roadmap's own explicit exception ("if they don't want to use the adjusted weight... they should be able to") is naturally served by leaving the box interactive and unchecking it, not by the default itself.

### Persistence

`Confirmar` calls a new `cubit.saveIdealWeightCalculation(gender: ..., considerForCalculations: ...)`, which computes the value, then persists a `WEIGHTS` row via the existing weight-creation path with `weightType: WeightTypeEnum.ideal` and `considerForCalculations` set from the checkbox — plus `inputParams` referencing `height` and `gender` (per the roadmap's "every data saved should reference the parameters used" rule, same `{key, label, value}` shape every other calculator table already uses). Action-pattern (`Cancelar`/`Confirmar` via `AppRouter.pop<bool>`, ADR 0002) is unchanged from every prior calculator — no new interaction pattern introduced here beyond the checkbox itself.

---

## Swipe-to-delete + confirmation-dialog pattern (first codified spec — Roadmap Slice 11, History tab)

**Important context found while speccing this:** the roadmap already *describes* swipe-to-delete for Weights/Heights/Body Measurements (2.1.4), but no code implements it yet — `lib/features/patients/details/presentation/widgets/measurements_list.dart` has the `Dismissible` commented out as a `// TODO - use when delete weight record is available`, and no confirmation-dialog copy exists anywhere in the codebase for a delete flow. This entry is therefore the **canonical spec**, not a description of existing code — `mobile-dev` should wire it into `MeasurementsList` (Weights/Heights/Body Measurements) and the new History tab identically, so the two never diverge in copy or gesture.

### Gesture

`Dismissible`, `direction: DismissDirection.endToStart` (swipe/drag right-to-left — matches the roadmap's existing "tile dragged to the left" wording). Background revealed behind the tile: full-bleed `DsColors.error` fill, a white trash icon (`Icons.delete_outline`) end-aligned with `DsSpacing.md` padding — no new token needed, `DsColors.error` (`Colors.red`) is unused elsewhere today and is the obvious "destructive" association.

### Flow (identical for every deletable list: Weights, Heights, Body Measurements, History)

1. Drag triggers `confirmDismiss` (not `onDismissed` — deletion must be confirmed *before* Flutter animates the tile away, so a cancel doesn't need to un-delete anything).
2. `confirmDismiss` awaits a `DsDialog.show` confirmation (title + message below), actions `Cancelar` (returns `false`) / `Excluir` (proceeds to delete).
3. On `Excluir`: call the delete use case. On success, `confirmDismiss` resolves `true` (tile animates out, list also naturally reflects the new state via `BlocBuilder`) and an auto-closing success `DsDialog` is shown (existing "Feedback dialogs" convention above — `duration` set, no user action). On failure, `confirmDismiss` resolves `false` (tile snaps back) and an error `DsDialog` is shown (close button, no `duration`, per the existing convention).

### Copy (final, template + per-context fill-ins)

Generic template: title **"Excluir {item}"**, message **"Tem certeza que deseja excluir {esse/essa} {item}? Essa ação não pode ser desfeita.{extra}"**, buttons **"Cancelar"** / **"Excluir"**.

| Context | `{item}` | `{extra}` sentence | Success dialog message | Error dialog message |
|---|---|---|---|---|
| Weights tab, and any Weight-type row in History | "peso" | " Os pesos registrados após este serão recalculados." | "Peso excluído com sucesso." | "Não foi possível excluir o peso. Tente novamente." |
| Heights tab | "altura" | " As alturas registradas após esta serão recalculadas." | "Altura excluída com sucesso." | "Não foi possível excluir a altura. Tente novamente." |
| Body Measurements tab | "medida" | " As medidas registradas após esta serão recalculadas." | "Medida excluída com sucesso." | "Não foi possível excluir a medida. Tente novamente." |
| History — any non-Weight calculator result | "cálculo" | (omitted — no curve/recompute concept) | "Cálculo excluído com sucesso." | "Não foi possível excluir o cálculo. Tente novamente." |

The `{extra}` sentence exists specifically so a dietitian isn't surprised by the curve-recompute side effect (same reasoning as the roadmap's own "curves...should be updated" line) — it's the plain-language explanation of that side effect, not new business logic.

**Weight-type row deleted from History is the exact `WEIGHTS` row the Weights tab reads** (Slice 11 acceptance criterion): its confirmation dialog uses the "peso" row above verbatim (not a generic "cálculo" row) — same title, same message, same recompute sentence a dietitian would see deleting that row from the Weights tab directly — precisely so the two entry points never read as two different actions.

### Non-weight/height/measurement calculator deletes only touch their own table

Deleting a BMI/Energy Expenditure/Screening/etc. row from History has no curve/recompute concept (only Weights/Heights/Body Measurements do) — plain single-row delete, generic "cálculo" copy above.

---

## History tab (`PatientHistoryTab`) — Roadmap Slice 11

Location: `lib/features/patients/details/presentation/widgets/tabs/patient_history_tab.dart` (new, replaces `DsPlaceholder()`), structurally a sibling of `patient_calculators_tab.dart` and `patient_measurements_tab.dart` — reuses the same `BlocBuilder<PatientDetailsCubit, PatientDetailsState>` shell.

### Grouping and ordering

- Iterate `CalculatorType.values` (same enum, same order `CalculatorList._buildAllView` already uses for the Calculators tab's "See All" view — do not reinvent a second ordering) as section headers, `type.label` styled identically to that view's group header (`fontWeight: FontWeight.bold`, `DsSpacing.sm` gap to its list).
- Within a group, entries ordered latest-first by `createdAt` (same direction already used everywhere else — Weights/Heights/Body Measurements all show latest-first).
- A `CalculatorType` with zero persisted results for the patient is skipped entirely (no header, no empty-list placeholder) — same precedent as the Calculators tab's See All view and Body Measurements' accordion group suppression.
- All 5 Weight sub-type rows are merged into one flat, `createdAt`-sorted list under the single `CalculatorType.weight` group — not 5 separate sub-groups, not a nested accordion (an accordion-per-subtype would be a new pattern for a group that Body Measurements' accordion-per-type doesn't need, since Weight's "sub-type" distinction is small enough to carry on the tile itself, see below).

### Tile layout (`DsListTile`, no new DS widget needed)

- **Single-member groups** (BMI, Energy Expenditure, Nitrogen Balance, Protein Needs, Water Needs, Weight Loss Classification, and Glucose Infusion Rate under Parenteral Nutrition while it's still the group's only member): no `overline` (the section header already names the calculator) — `title` = that entry's one-line result summary (see below), `subtitle` = `createdAt.formattedDateTime()` (reuse `ext_datetime.dart`'s existing formatter, same one `MeasurementsList` uses).
- **Multi-member groups** (Enteral Nutrition's 3, Screening's 3, Weight's 5): `overline` = the specific sub-calculator's existing display name — the same string already defined as that tile's `name` in `patient_calculators_tab.dart`'s `_buildDefinitions` (e.g. "Gotejamento", "MUST") for Enteral Nutrition/Screening, and `WeightTypeEnum.label` for Weight (e.g. "Peso Ideal", "Adequação") — per Slice 11's explicit requirement. `title`/`subtitle` same as above.
- No `trailing` (no chevron, no curve icon) — tap and swipe are the only two interactions and neither needs a persistent visual cue beyond the default `InkWell` ripple `DsListTile` already provides on tap; a curve icon (as the Weights tab shows) is deliberately **not** replicated here since History isn't a trend view and the 5 Weight sub-types don't share one comparable curve.
- Separator: reuse `MeasurementsList`'s existing hairline `Container(color: DsColors.gray)` `ListView.separated` convention verbatim (documented DS-wide under `DsListTile`'s entry above) — don't invent a second separator style for one more list.

### Per-type result-summary line (tile `title`, and the bold line in the detail sheet)

No shared formatter exists today — reuse the exact result-line string each calculator's own sheet body already computes (single source of truth per calculator, not re-derived here):

- BMI: `"IMC: ${value.toStringAsFixed(2)} (${classificationLabel})"` (`patient_calculators_tab.dart`'s own `_classificationLabel`).
- Energy Expenditure: `"Gasto Energético: "` + the existing min/max formatter in `energy_expenditure_sheet_body.dart` (`"${min}–${max} kcal/dia"`, or just `"${min} kcal/dia"` if `min == max`).
- Enteral Nutrition (Dripping/Speed/Volume), Glucose Infusion Rate, Protein Needs, MUST: reuse each one's own already-shipped result `Text` string verbatim (`"Gotejamento: X gotas/min"`, `"Velocidade de Infusão: X mL/h"`, `"Volume Total: X mL/dia"`, `"Taxa de Infusão de Glicose (TIG): X mg/kg/min"`, `"Necessidade Proteica: X – Y g/dia"`, `"MUST: {score} ({classificationLabel})"` — all confirmed present in their respective `*_sheet_body.dart` files).
- NRS-2002, STRONG-Kids, Nitrogen Balance, Water Needs, Weight Loss Classification: same rule — pull the exact result string already coded in that calculator's own `*_sheet_body.dart` (or, for Weight Loss Classification, `patient_calculators_tab.dart`'s own result `Text`) rather than re-deriving new copy here; `mobile-dev`/`senior-analyst` should grep each file at implementation time rather than trust a re-typed copy in this doc going stale.
- Weight (all 5 sub-types): reuse `patient_measurements_tab.dart`'s existing `_formatWeightValue` logic verbatim (handles Adequation's `%` + classification and Adjusted Dry Weight's min–max range specially, plain `"{value} kg"` otherwise) — prefixed with the sub-type's `WeightTypeEnum.label` on the `overline` (not repeated in the value string itself, to avoid "Peso Ideal — Peso Ideal: 70 kg" redundancy).

### Detail bottom sheet (tap-to-view, read-only)

`DsBottomSheet.show<void>`:
- `title`: the same name used as the tile's primary identifier — group `type.label` for single-member groups, the sub-calculator name (or `WeightTypeEnum.label`) for multi-member groups. Matches the existing convention where every calculator's bottom sheet title is that calculator's own name.
- `body`: a plain `Column` (`crossAxisAlignment: start`, `spacing: DsSpacing.sm`, same shape every calculator confirm-sheet already uses) of:
  1. One `Text("${p.label}: ${p.value}")` per persisted `InputParamEntity` in `inputParams`, in stored order — this is generic/reusable across all 18 types precisely because `inputParams` already normalizes to `{key, label, value}` (ADR 0005), so no per-type branching is needed here (unlike the result line, which does need per-type branching since the "what is the result" shape differs).
  2. `SizedBox(height: DsSpacing.sm)` then the bold result-summary line (same string as the tile `title`, `fontWeight: FontWeight.w700` — matches every existing calculator sheet's result-line styling, e.g. BMI's/Weight Loss Classification's).
- `actions`: a single `Expanded(DsButton(label: "Fechar", onTap: () => getIt.get<AppRouter>().pop()))` — matches the existing "insufficient data" single-button convention already used throughout `patient_calculators_tab.dart`. No `Cancelar`/`Confirmar` pair (nothing to confirm — this view is read-only, no edit action, per Slice 11's explicit scope).

### Empty states

- **Per-group suppression**: covered above (no header/list rendered for a `CalculatorType` with 0 results).
- **All-empty** (every group empty): render `NoDataFoundForPatient(message: "Sem histórico de cálculos para esse paciente")` — reuses the exact widget (and therefore exact visual treatment: `Expanded(DsPlaceholder(...))`) already used by the Weights/Heights/Body Measurements tabs for their own empty states, rather than introducing a new empty-state look for the 4th tab that needs one. Exact copy is PO-confirmed, verbatim, no changes.

### Open item for `senior-analyst` (data availability, not a UX decision)

`PatientDetailsStateLoaded` (`patient_details_state.dart`) today only exposes `weights`/`heights`/`measurements` lists plus a single latest `bmi` value — there is no existing state slice that reads *all* persisted rows across the other 17 calculator tables (BMI history, Energy Expenditure history, etc.) for a patient. Populating History will need new repository/use-case reads per calculator table (or one aggregating use case) wired into `PatientDetailsCubit`/state — flagging since it's a real gap the architecture plan needs to size, not something this design pass can resolve.
