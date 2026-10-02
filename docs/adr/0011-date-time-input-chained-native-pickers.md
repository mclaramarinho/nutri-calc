# 0011. Date+time input uses chained native pickers behind a single DS field, prevention-first with transient error for the time-of-day gap

**Status:** Accepted
**Date:** 2026-10-01
**Feature:** docs/roadmap.md priority 5 / section 2.1.4 (Weights/Heights/Body Measurements Gap 3 — date/time picker)

## Context

Section 2.1.4 requires an optional date/time on Weights, Heights, and Body Measurements: "Optional. Defaults to now. Cannot be future datetime." No existing DS widget captures a combined date+time value. A date-only picker already exists, but it's not a reusable DS component — it's embedded inside `DsTextfield` as `type: .datetime` (`lib/shared/design_system/widgets/ds_textfield/ds_textfield.dart`'s `openDatePicker`), used only for Patient Birthdate (`lib/features/patients/new/presentation/pages/new_patient_page.dart`). It wraps native `showDatePicker(lastDate: DateTime.now())` with no inline error text — future days are simply unselectable in the calendar. There is no time component anywhere in the app and no existing `showTimePicker` usage.

Two things needed a decision:

1. **Whether to build a custom calendar/clock UI or reuse native pickers.** A full custom picker would be a large, unjustified scope increase and would break visual consistency with Birthdate's established native-picker affordance.
2. **How to enforce "cannot be future" when the picker has two steps (date, then time).** `showDatePicker`'s `lastDate` param can prevent a future *day* from ever being selected (same mechanism Birthdate already uses — no error state is reachable for that half of the rule). But `showTimePicker` has no min/max-time parameter, so when the selected date is *today*, a future time-of-day genuinely can be picked in the dial/input — a gap Birthdate never had to handle, since it only deals in day granularity.

## Decision

- New widget `DsDateTimePicker` at `lib/shared/design_system/widgets/ds_date_time_picker/ds_date_time_picker.dart`. Controlled-component API (`value`/`onChanged`, same shape as `DsCheckbox`), visually a `DsTextfield`-styled read-only field (reuses border/label/hint/error treatment), not a new input style and not wrapped in `DsDialog`/`DsBottomSheet`.
- Interaction chains two **native** pickers behind one tap target: `showDatePicker(firstDate: minDateTime ?? DateTime(1900), lastDate: maxDateTime ?? DateTime.now())`, and on a successful date pick, immediately `showTimePicker(initialTime: ...)`. Cancelling either leaves the value unchanged.
- **Prevention-first enforcement**: the day-level future-date rule is enforced identically to Birthdate, via `lastDate` truncation — no invalid state is ever reachable for that case, so no error UI is needed for it.
- **The one case the platform can't prevent outright** (same-day future time-of-day) is handled by explicit post-pick validation: if the picked date is today and the picked time-of-day is after `maxDateTime`'s time-of-day, the pick is **rejected** — `onChanged` is not called, the field keeps its previous value — and a transient `errorText` ("Não é possível selecionar um horário futuro.") is shown via `onValidityChanged(true)`, clearing on the next successful repick or clear (`onValidityChanged(false)`).
- `onChanged(null)` (the field's clear affordance) and an unset `value` both mean "use `DateTime.now()` at save time" — the widget itself never substitutes "now" into its own displayed value; callers own that resolution at save-click time.
- `onValidityChanged` is wired by the one real caller (`MeasurementInputField`'s Save button `disabled` condition, alongside the required-field checks) so Save is blocked for the ~1-2s a rejected pick's error is visible — consistent with the DS-wide "disabled while invalid" convention (ADR 0003).

## Consequences

- Weights, Heights, and Body Measurements get a real, optional, past-or-present date/time capture with no new custom calendar/clock implementation, and gain it uniformly since all three route through the shared `MeasurementInputField`.
- The "cannot be future" rule is enforced correctly without ever letting an invalid value reach persisted state (no invalid `createdAt` can be saved), at the cost of the widget needing one bit of bespoke post-pick comparison logic instead of being purely declarative like the `lastDate`-only day case.
- `onValidityChanged`'s only true value is transient (a few seconds, only reachable on same-day future-time rejection) — this is accepted as the correct, if narrow, use of the API rather than treated as dead weight, since Save-button gating during that window is an explicit UX requirement, not a hypothetical one.
- Sets the precedent for any future date+time (not date-only) input in the app: chain native pickers behind one DS field, prevent what the platform's own params can prevent, and fall back to post-pick reject+transient-error only for the residual gap native APIs don't cover.

## Alternatives considered

- **Build a custom unified date+time picker widget (single calendar+clock surface).** Rejected: no requirement or design spec asks for a custom visual; would be substantially more implementation and testing surface for no behavior the two chained native pickers can't already deliver, and would look inconsistent next to Birthdate's existing native date picker.
- **Show a persistent inline validation error for the whole future-date rule (both day and time-of-day) instead of preventing it.** Rejected: contradicts the established Birthdate precedent ("disable silently" via `lastDate`, no inline error ever shown for the day-level case), and is strictly worse UX for the day-level case where prevention is trivially available via `lastDate`. Reserved for only the one sub-case (same-day future time) where native APIs offer no prevention mechanism.
- **Silently clamp a rejected future time down to `maxDateTime`** instead of rejecting and keeping the previous value. Rejected: clamping silently changes the user's input to a different, un-requested value without telling them, which is worse than either preventing the pick outright or showing a transient error — rejection communicates the actual rule instead of presenting a surprising substituted value.
