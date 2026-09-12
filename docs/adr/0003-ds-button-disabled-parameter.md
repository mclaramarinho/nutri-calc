# 0003. `DsButton` gains a `disabled` parameter; `isLoading` now also blocks taps

**Status:** Accepted
**Date:** 2026-09-12
**Feature:** docs/roadmap.md section 2.1.4 (Weights/Heights/Body Measurements Save-button rules) — this ADR covers the `DsButton` component change only; wiring the actual Save buttons is a separate, still-open roadmap item.

## Context

`DsButton` (`lib/shared/design_system/widgets/ds_button/ds_button.dart`) only supports `isLoading`/`onTap` today. Section 2.1.4 requires disabling Save while required fields are empty or while a save is in flight, and per the original request this `disabled` API will be reused by every future Calculators bottom-sheet form — so its shape is a cross-cutting DS convention, not a one-off.

Two things needed a decision beyond "just add a bool":

1. **Interaction priority between `isLoading` and the new `disabled`.** senior-designer decided `isLoading` takes priority over `disabled`, "both visually and interactively." Read literally, "interactively" means a loading button must not be tappable regardless of `disabled`'s value. The current implementation always wires `onTap` straight to `ElevatedButton.onPressed`, so today a button *with `isLoading: true` is still tappable* — a latent bug relative to the designer's stated intent, even though nothing in the original bug reports called this out explicitly.
2. **How disabled-state color is expressed.** Material's `ElevatedButton` only applies `disabledBackgroundColor`/`disabledForegroundColor` when `onPressed == null` — it doesn't distinguish *why* the button is non-interactive. Since the fix for (1) sets `onPressed: null` during `isLoading` too, the loading state now visually renders with the same gray/`black38` disabled styling as the `disabled` state (the spinner itself is unaffected, since it doesn't consume `disabledForegroundColor`). No separate "loading background" spec exists from senior-designer, so this coupling is accepted by default rather than re-litigated.

## Decision

- Add `final bool disabled` to `DsButton`, defaulting to `false` (non-breaking for the 3 existing call sites, none of which pass it today).
- Compute `final isInteractive = !isLoading && !disabled;` and pass `onPressed: isInteractive ? onTap : null` — this is a deliberate behavior change: **`isLoading` now also blocks taps**, closing the latent bug described above, in every existing call site (`measurement_input_field.dart`, `new_patient_page.dart`, `ds_dialog.dart`).
- Apply `ElevatedButton.styleFrom(disabledBackgroundColor: DsColors.gray, disabledForegroundColor: DsColors.black.withValues(alpha: 0.38))` unconditionally in `DsButton`'s style — since Material keys this off `onPressed == null`, both `disabled: true` and `isLoading: true` render with these colors. This is accepted, not treated as a bug: no distinct "loading" visual spec exists, and the label isn't shown while loading anyway (the spinner replaces it), so the foreground color has no visible effect in that case.

## Consequences

- Every current and future `DsButton` caller gets consistent, deliberate disabled styling instead of unstyled default from the current `ElevatedButton` (previously flagged `// TODO - style this button`), and gets it for free without re-deriving the interaction rule per screen.
- Future Calculators bottom-sheet forms can implement "disable Save while required fields empty / while saving" purely by passing `disabled: <validation bool>` and `isLoading: <saving bool>` — no per-screen `AbsorbPointer`/manual `onPressed: null` workarounds needed.
- Closes the pre-existing "loading button is still tappable" bug as a side effect of this change; called out here so it isn't mistaken for scope creep during review — it is required to satisfy senior-designer's "isLoading takes priority ... interactively" decision.
- Loading and disabled currently look identical (gray background) since both resolve through Material's single `disabled` `WidgetState`. If a future design pass wants a visually distinct loading background, that requires a custom `ButtonStyleButton` state resolver (a bigger change) rather than `styleFrom`'s single disabled-color pair — not needed now, tracked here for awareness only, no roadmap entry added since no requirement currently asks for it.

## Alternatives considered

- **Leave `isLoading` non-blocking (only add `disabled`, don't touch `onPressed` during loading).** Rejected: contradicts senior-designer's explicit "isLoading takes priority ... interactively" decision, and would leave a real double-submit bug (tapping Save again while a save request is in flight) unfixed in a feature (2.1.4) explicitly about preventing exactly that.
- **Give loading and disabled distinct visual treatments via a custom `ButtonStyle` resolved from `WidgetState.disabled` + a manual loading flag.** Rejected as unnecessary complexity: no requirement or design spec asks for visually distinguishing them, and `ElevatedButton.styleFrom`'s built-in disabled-color pair already satisfies the one visual spec that exists (`disabledBackgroundColor`/`disabledForegroundColor`).
