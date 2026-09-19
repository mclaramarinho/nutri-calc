# Development Roadmap

## Table of Contents

| Index | Content |
| ----- | ------- |
| 1 | [Roadmap Prioritization](#1-roadmap-prioritization) |
| 2 | [Features](#2-features) |
| 2.1 | [Patient](#21-patient) |
| 2.1.1 | [Create Patient](#211-create-patient) |
| 2.1.2 | [List Patients](#212-list-patients) |
| 2.1.3 | [Patient Details](#213-patient-details) |
| 2.1.4 | [Patient Details - Tabs](#214-patient-details---tabs) |
| 3 | [Useful Information](#3-useful-information) |
| 3.1 | [Calculators](#31-calculators) |
| 3.2 | [Implementation Statuses](#32-implementation-statuses) |

---

## 1. Roadmap Prioritization

| Priority | What | Status | Last Action Date | Description |
| -------- | ---- | ------ | ----------------- | ----------- |
| 1 | Create DB migration mechanism | Implemented ✅ | 2026-09-06 | `AppDatabaseService.init()` now opens the DB with sqflite native `version`/`onCreate`/`onUpgrade`, driven by `sinceVersion` metadata on `AppDatabaseTables` (table) and `TableSqlField` (column) plus a `kAppDatabaseVersion` constant — see [ADR 0001](adr/0001-database-schema-migrations.md). Additive-only (new columns/new tables); fresh install and upgrade both converge to the same schema from the same `fields`/`sql` source. Covered by 13 tests in `test/core/services/database/app_database_service_test.dart` (fresh-install schema/column correctness, full-row insert across all tables, reopen-at-higher-version data integrity, `onUpgrade` mechanics via a versioned fixture, `addColumnSql` guards for PRIMARY KEY/UNIQUE-via-migration and NOT-NULL-without-default). **Tech debt:** the `onCreate`/`onUpgrade` dispatch loop is inlined in `init()` rather than extracted into an independently-testable unit — revisit extraction when a second real migration ships; downgrade (opening an older-versioned request against a newer-schema DB file) is sqflite's silent no-op and is unspecified/untested — flag if it ever becomes a real scenario. **Unblocks:** the 4 `PATIENT` columns ([2.1.1](#211-create-patient)) shipped 2026-09-12 using this pattern; the `WEIGHTS` "consider for calculations"/"weight type" columns and all new calculator tables ([2.1.4 Calculators](#calculators)) remain not yet built but can be added the same way. **Correctness fix (2026-09-12, found by QA while shipping the 4 `PATIENT` columns above):** `TableSqlField.sql` (the `CREATE TABLE`/fresh-install getter) was silently ignoring `defaultValue` — only `addColumnSql` (the `ALTER TABLE`/migration getter) applied it, a latent bug in this mechanism's `onCreate` path since this ADR shipped, only exposed once `NOT NULL`-with-`DEFAULT` columns were first created via `onCreate`. Fixed; both getters now apply `DEFAULT` consistently. |
| 2 | Validate this roadmap | Implemented ✅ | 2026-09-19 | Ran the `po` → `senior-analyst` review pass: cross-checked every feature's documented status against code (results folded into each feature's "Implementation Notes" in section 2.1), resolved the screening-storage and calculator-input-storage conventions (base+`inputParams` JSON, see [2.1.4 Calculators](#calculators)), and surfaced the two new priorities below (3, 4) plus 11. Also substantially covers priority 6 below for the features that exist today (2.1.1–2.1.4) — see that row. **Re-validated 2026-09-19** (doc had gone stale since 2026-09-07): [2.1.2 List Patients](#212-list-patients) was still marked "Incomplete 🟣" though commit `8a06bf7` had already fixed all 3 documented gaps (copy, retry, DS widgets) — corrected to "Implemented ✅". [2.1.3 Patient Details](#213-patient-details)'s BMI-wiring, save-error-edit-mode, and edit-time-validation gaps were closed by commit `cd74f42` — notes updated; one gap remains (calculator-relevance-on-save, blocked on 2.1.4). [2.1.4](#214-patient-details---tabs)'s Weights/Heights `getWeights`/`getHeights` patient-filtering bug (previously undocumented) was also fixed by `cd74f42`, but the `saveWeight`/`saveHeight` Result-handling bug documented since 2026-09-06 is still present — re-verified unfixed. `ab7de0c` (clinical flags) and `c7747ec` (DsButton `disabled`) were confirmed already accurately reflected in the doc, no changes needed. |
| 3 | Build `DsBottomSheet` design-system component | Implemented ✅ | 2026-09-07 | Shipped: `lib/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart` — `DsBottomSheet.show<T>()` (optional title, required scrollable body, optional actions footer, `isDismissible`/`enableDrag`, content-driven sizing via `maxHeightFraction`, single-instance guard). Required `AppRouter.pop()` → `pop<T extends Object?>([T? result])` (`lib/routing/app_router.dart`) to support `Future<T?>` result-passing — see [ADR 0002](adr/0002-approuter-pop-generic-result.md). Covered by 11 widget tests (`test/shared/design_system/widgets/ds_bottom_sheet_test.dart`); `flutter test` 24/24 pass, `flutter analyze` clean. Reviewed by tech-lead (2 blocking issues found and fixed mid-review — a single-instance-guard cast crash and a fragile guard-clearing mechanism — plus 1 non-blocking spec deviation on body padding); second pass PASS/ship. Unblocks Calculators/History (2.1.4) to proceed — those tabs are still not implemented. **Minor, non-blocking:** tech-lead left two small hardening notes (not tracked as tech debt per tech-lead's own framing) plus a cosmetic `BorderRadius.only` vs `BorderRadius.vertical` equivalence note — optional future nice-to-haves, no action required. |
| 4 | Add `enabled`/`disabled` parameter to `DsButton` | Implemented ✅ | 2026-09-12 | Shipped: `DsButton` (`lib/shared/design_system/widgets/ds_button/ds_button.dart`) gained `final bool disabled` (default `false`, non-breaking). `isInteractive = !isLoading && !disabled`; `onPressed: isInteractive ? onTap : null`; `ElevatedButton.styleFrom(disabledBackgroundColor: DsColors.gray, disabledForegroundColor: DsColors.black.withValues(alpha: 0.38))` applied unconditionally. **Deliberate behavior change (senior-designer decision, see [ADR 0003](adr/0003-ds-button-disabled-parameter.md)):** `isLoading` now also blocks taps (previously a latent double-submit bug), taking priority over `disabled` both visually and interactively; `disabled: true` and `isLoading: true` render identically (gray bg/black@38% fg) since Material only distinguishes `onPressed == null` vs not — accepted as-is, not a bug, since no distinct loading-visual spec exists and the label is hidden during loading anyway. **Deviation from this row's original acceptance criteria:** `onTap` was specified to become nullable/optional (criterion 2) so callers could omit it when disabled; shipped API instead kept `onTap` required and added `disabled` as a separate bool — not corrected here per this doc's own rule of not silently rewriting fulfilled requirements to match implementation; flagged for `senior-analyst`/`senior-designer` if the nullable-`onTap` convention is still wanted for consistency with Material's `onPressed: null` pattern. Covered by 4 widget tests (`test/shared/design_system/widgets/ds_button_test.dart`: interactive tap fires, disabled blocks tap, isLoading blocks tap + shows spinner, isLoading+disabled combined blocks tap + shows spinner); full suite 28/28 pass, `flutter analyze` clean. Existing call sites (`measurement_input_field.dart`, `new_patient_page.dart`, `ds_dialog.dart`) required no changes and continue to compile/pass. Reviewed by tech-lead: PASS, no blocking issues (3 minor non-blocking notes logged: missing dartdoc on the isLoading-priority interaction, a stale `// TODO - style this button` comment, no in-file ADR cross-reference — none actioned). **This unblocks but does NOT itself implement** the Weights/Heights/Body Measurements Save-button wiring documented in [2.1.4](#214-patient-details---tabs) — those tabs' `MeasurementInputField`/save callbacks still never pass `disabled:`/gate on it; that remains a separate, still-open gap. |
| 5 | Implement what is missing for existing features | Ready for Dev 🔵 | — | Adjust what is not correct in the existing features and implement what is missing for each one of them. |
| 6 | Validate what was implemented | Implementing 🟡 | 2026-09-07 | For existing features (2.1.1–2.1.4): **largely done as of 2026-09-07** via priority 2's pass — see each feature's "Implementation Notes" for the registered gaps. Remaining scope: re-validate 2.1.1–2.1.4 after priority 5 lands (confirm fixes actually closed the documented gaps), and validate the new features built under priority 7 (Calculators, History) once they exist, the same way — status + gaps registered in this file's feature-section tables. |
| 7 | Implement new features | Ready for Dev 🔵 | — | Implement the remaining non-existing features. |
| 8 | Design System audit & expansion | Ready for Dev 🔵 | — | A partial design system already exists (`lib/shared/design_system/` — `ds_*` widgets, `tokens/`, per `CLAUDE.md`), and priorities 3–4 already patch specific gaps in it (`DsBottomSheet`, `DsButton`) as blockers surface ad hoc. This priority is the broader systematic pass on top of that: 1) identify and understand the target-user profile, their possible preferences and what is the best UX/UI for them; 2) review/extend the color palette, spacing, etc. tokens for the app; 3) update widgets and screens for consistency with the resulting Design System directives. |
| 9 | Refactor | Ready for Dev 🔵 | — | Go through the codebase and find code gaps — code repetition, widgets that should be design-system reusable components, repeated database schema/query patterns, etc. |
| 10 | Create Dark Mode | Ready for Dev 🔵 | — | Create dark mode for app. |
| 11 | Internationalization | Ready for Dev 🔵 | 2026-09-07 (added) | Added 2026-09-07, product decision. Support multiple languages/locales for user-facing copy. Relevant precedent already exists: the calculator `inputParams` JSON structure ([2.1.4 Calculators](#calculators)) stores each parameter's `label` as an i18n-able reference rather than a hardcoded string specifically so this can land later without a data migration. All current UI copy is hardcoded Portuguese (per `CLAUDE.md`); scope includes introducing an i18n mechanism (e.g. `flutter_localizations`/ARB files) and migrating existing hardcoded strings. |

Statuses use the same legend as [3.2](#32-implementation-statuses). "Last Action Date" is the date of the most recent status-relevant change to that row (completion, re-validation, or the row's own addition) — not a general roadmap-edit timestamp.

---

## 2. Features

Describes the features and their current implementation status.

### 2.1. Patient

#### 2.1.1. Create Patient

**Status:** Implemented ✅ (was: Implementing 🟡 — the 4 previously-missing fields have shipped and were validated against code/tests, see Implementation Notes, 2026-09-12; only remaining note is the pre-existing cosmetic FAB icon item, which doesn't block this status per the legend)

**Description:**

**Functional Requirements:**

##### A patient can have the following information:

| Field | Description | Type | Required |
| ----- | ------------ | ---- | -------- |
| **ID** | The ID used to identify the user in the local database. It's in UUID v4 format. | String | Yes |
| **Patient ID** | The ID given by the dietitian (can be the one assigned at the hospital, or one they made up). | String | No |
| **First Name** | | String | Yes |
| **Last Name** | | String | Yes |
| **Age** | Only the number part of the age. Does not include the time unit (day, month, year...). If a birthdate is informed, this field is readonly and automatically calculated. Cannot be lesser than 0. | int | No |
| **Age Unit** | Only the time unit part of the age (day, month, year...). If a birthdate is informed, this field is readonly and automatically calculated. | String | No |
| **Birthdate** | User birthdate. If informed, age and age unit are automatically calculated and the fields become readonly. Cannot be a future date. | Datetime (saved as string on the local database) | No |
| **Enteral Nutrition** | Checkbox to indicate whether the patient uses enteral nutrition. | boolean | No |
| **Parenteral Nutrition** | Checkbox to indicate whether the patient uses parenteral nutrition. | boolean | No |
| **Hospitalized** | Checkbox to indicate whether the patient is hospitalized. | boolean | No |
| **Confined to bed** | Checkbox to indicate whether the patient is confined to bed and can't walk, or requires a lot of effort to walk. | boolean | No |

##### Saving

- Saves on the local database only.
- If successfully saved, show success dialog. Then redirect Home.
- If error saving, show error dialog. User can close the dialog and try again.

##### Accessibility

- Easily accessible from any screen, through a blue FAB (with a "plus and avatar" icon).

##### Implementation Notes (validated against code, 2026-09-06)

- Implemented: ID, Patient ID, First/Last Name, Age, Age Unit, Birthdate (with auto-calc + readonly toggle), future-date and negative-age validation, save success/error dialogs, redirect home on success. FAB present on Home (`lib/features/home/presentation/pages/home_page.dart`), though its icon is `Icons.person_add`, not the documented "plus and avatar" icon — cosmetic, flagged for `senior-designer`.
- **Gap (not partially done — entirely missing):** Enteral Nutrition, Parenteral Nutrition, Hospitalized and Confined to bed are not implemented anywhere — no UI fields, no `NewPatientFormEntity`/`PatientModel` fields, no `PATIENT` table columns (`lib/features/patients/new/domain/entities/new_patient_form_entity.dart`, `lib/features/patients/data/models/patient_model.dart`, `lib/core/services/database/app_database_tables.dart`). These 4 fields also feed the [Calculator Relevance](#calculator-relevance) table, so Energy Expenditure/Nitrogen Balance/Weight/Screening relevance cannot be computed until this lands.
- **Technical Debt:** none of the above is optional polish — it's core schema. The DB migration mechanism ([priority 1](#1-roadmap-prioritization), [ADR 0001](adr/0001-database-schema-migrations.md)) has shipped, so adding these 4 `PATIENT` columns is no longer blocked — it's just not done yet.
- **Resolved:** given 4/10 documented fields are fully unbuilt, status corrected from "Incomplete 🟣" to "Implementing 🟡" per the status legend's distinction ("works fine, has some things to add" vs. "on the way") — product decision, 2026-09-06.

##### Confirmed requirement for the 4 missing fields (PO + code review, 2026-09-12)

Scope: land Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed end-to-end — DB → `NewPatientFormEntity`/`PatientModel` → Create Patient form → `EditPatientFormEntity` → Patient Details view/edit form. Calculator Relevance consumption stays out of scope (separate, not-yet-built feature).

- **Fields** (all 4, identical shape): Dart type `bool` (non-nullable, default `false`) — not `bool?`. A checkbox has no meaningful tri-state ("not informed" reads the same as "no" for relevance purposes), and a non-nullable default fits [ADR 0001](adr/0001-database-schema-migrations.md)'s migration guard cleanly (`NOT NULL` columns added via migration require a `defaultValue`). Field names (camelCase, matching existing `PATIENT` columns like `firstName`/`ageUnit`): `enteralNutrition`, `parenteralNutrition`, `hospitalized`, `confinedToBed`.
- **DB:** 4 new `PATIENT` columns, `INTEGER NOT NULL DEFAULT 0` (SQLite's standard boolean convention — no native boolean type), `sinceVersion: 2`; bump `kAppDatabaseVersion` to `2`. Per ADR 0001's pattern, this is additive-only — no other schema changes needed.
- **Model-layer conversion (implementation detail, not ambiguous, flagging so it isn't missed):** `PatientModel`'s existing non-primitive fields (`birthdate`, `ageUnit`) already convert to sqlite-insertable primitives via `json_serializable`'s default codegen (`DateTime`→ISO string, enum→name string — see `patient_model.g.dart`). A plain `bool` field's generated `toJson` would instead emit a Dart `true`/`false`, which sqflite's insert/update channel does not accept for an `INTEGER` column. The 4 new `PatientModel` fields need `@JsonKey(toJson:, fromJson:)` int(0/1)↔bool converters, mirroring the existing pattern of converting non-primitive Dart types to sqlite-compatible primitives at the model boundary.
- **Mapping sites that must be updated (confirmed by reading code — all currently omit these 4 fields):** `CreatePatientUseCaseImpl` (`lib/features/patients/new/domain/use_cases/create_patient_use_case.dart`), `LoadPatientDetailsUseCaseImpl` (`lib/features/patients/details/domain/use_cases/load_patient_details_use_case.dart`), `UpdatePatientUseCaseImpl` (`lib/features/patients/details/domain/use_cases/update_patient_use_case.dart`), `NewPatientCubit`'s `PatientPropertiesToEdit`/`setValue` (`lib/features/patients/new/presentation/cubit/new_patient_cubit.dart`), `PatientDetailsCubit`'s `updateX` methods (`lib/features/patients/details/presentation/cubit/patient_details_cubit.dart`). **Critical:** `PatientDetailsRepositoryImpl.updatePatient` does a full-column overwrite (`patient.toJson()` minus `id`) on every save (`lib/features/patients/details/data/repositories/patient_details_repository_impl.dart`) — if `UpdatePatientUseCaseImpl` doesn't pass all 4 new fields through, every edit-form save silently resets them to `false`.
- **UI:** add 4 checkboxes — Create Patient form (`lib/features/patients/new/presentation/pages/new_patient_page.dart`) after Birthdate, before the Save button; Patient Details form (`lib/features/patients/details/presentation/widgets/patient_details_form.dart`), reusing the same `disabled: !state.isEditing` pattern already applied to every other field there (no separate read-only display widget needed — a disabled checkbox is the read view, same convention as the disabled `DsTextfield`s). Proposed Portuguese labels (not final): "Nutrição Enteral", "Nutrição Parenteral", "Hospitalizado", "Restrito ao leito".
- **Open questions (flagged, not decided here):**
    1. No `DsCheckbox` exists under `lib/shared/design_system/widgets/` — needs to be designed/built before this can ship per `CLAUDE.md`'s DS-widget-only rule. Needs a `disabled` prop (parity with `DsTextfield`) — `senior-designer` to spec, `mobile-dev`/`senior-analyst` to build.
    2. `TableSqlTypes` (`lib/core/services/database/entities/table_sql_types.enum.dart`) has no boolean case (`text`/`integer`/`real`/`blob` only) — reuse `.integer` directly for these 4 columns, or add a self-documenting `.boolean` case that maps to SQL `INTEGER`? Core DB infra decision — `senior-analyst`/`mobile-dev` call.
    3. Field-order inconsistency between this section's field table (booleans listed last, after Birthdate) and [2.1.3](#213-patient-details)'s prose ("Patient Id, Enteral/Parenteral nutrition, Confined to bed, Hospitalized, First/Last name, Age, Age Unit and Birthdate" — booleans right after Patient Id). Not necessarily a positional spec either way, but `senior-designer` should confirm final placement/order for both forms (and whether Create Patient and Patient Details should match each other).
    4. "Confined to bed"'s roadmap description carries a clarifying sentence ("indicate whether the patient is confined to bed and can't walk, or requires a lot of effort to walk") — should this render as helper/caption text under the "Restrito ao leito" checkbox, or is it purely internal documentation of the field's meaning? `senior-designer` call.
    5. Layout/grouping: the current Create Patient form is a flat `Column` with no section headers/dividers between field groups — no existing "section" pattern to match. Single column vs. 2x2 grid for the 4 checkboxes, and whether they get a section label (e.g. "Informações Clínicas"), is a `senior-designer` call.

##### Resolved — 4 missing fields shipped end-to-end (validated against code/tests, 2026-09-12)

- **Implemented, matching the "Confirmed requirement" subsection above:** DB — 4 new `PATIENT` columns (`enteralNutrition`, `parenteralNutrition`, `hospitalized`, `confinedToBed`; `INTEGER NOT NULL DEFAULT 0`, `sinceVersion: 2`), `kAppDatabaseVersion` bumped to `2` (`lib/core/services/database/app_database_version.dart`). New `TableSqlTypes.boolean` case added per [ADR 0004](adr/0004-table-sql-types-boolean-case.md). `PatientModel` got the 4 fields with `@JsonKey(toJson:, fromJson:)` int↔bool converters. `NewPatientFormEntity`/`EditPatientFormEntity` threaded the 4 fields through, and all the mapping call-sites flagged above (`CreatePatientUseCaseImpl`, `LoadPatientDetailsUseCaseImpl`, `UpdatePatientUseCaseImpl`, `NewPatientCubit`, `PatientDetailsCubit`) were updated — verified `UpdatePatientUseCaseImpl` passes all 4 fields through on every save, avoiding the full-column-overwrite-resets-to-false risk flagged above. New `DsCheckbox` widget shipped (`lib/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart` — `disabled` prop mirroring `DsButton`/ADR 0003, optional `helperText`). Both Create Patient (`new_patient_page.dart`) and Patient Details (`patient_details_form.dart`) forms got an "Informações Clínicas" section with the 4 checkboxes ("Nutrição Enteral", "Nutrição Parenteral", "Hospitalizado", "Restrito ao leito" — the last with helper text), placed after Birthdate, same order in both forms, resolving open question 3 (order is now consistent between both forms, not matching 2.1.3's prose order — that prose is stale, see 2.1.3's note). Patient Details reuses the existing `disabled: !state.isEditing` convention.
- **Bonus fix (found by QA during this pass, not originally scoped):** `TableSqlField.sql` (the `CREATE TABLE`/fresh-install getter, `lib/core/services/database/entities/table_sql_field.entity.dart`) was silently ignoring `defaultValue` — only `addColumnSql` (the `ALTER TABLE`/migration getter) applied it. This was a latent pre-existing bug in the DB migration infra from [ADR 0001](adr/0001-database-schema-migrations.md)/priority 1, exposed because these are the first `NOT NULL`-with-`DEFAULT` columns ever created via the `onCreate` (fresh install) path. Fixed to apply `DEFAULT` consistently on both paths.
- **Test coverage:** `DsCheckbox` widget tests, `PatientModel` conversion unit tests, an integration test suite covering the edit-overwrite regression risk (`test/features/patients/patient_clinical_flags_integration_test.dart`), `NewPatientCubit` tests, and DB migration tests for the 4 new columns (fresh-install + v1→v2 upgrade, `test/core/services/database/app_database_service_test.dart`). Full suite 56/56 passing, `flutter analyze` clean (8 pre-existing unrelated info lints only). Reviewed by tech-lead: PASS, no blocking issues.
- **Out of scope, as originally scoped:** Calculator Relevance's consumption of these 4 fields is not built — that remains a separate, not-yet-built feature (see [2.1.4 Calculators](#calculators)'s "Hard prerequisite" note, now updated to reflect this DB prerequisite is satisfied).
- **Still open, not part of this pass:** open question 1's `DsCheckbox` design spec and open questions 3–5 (ordering/helper-text/layout) were resolved by `senior-designer` as implemented above. The pre-existing cosmetic FAB icon note (2026-09-06 Implementation Notes above) remains the only other open item for this feature and does not block this status.

#### 2.1.2. List Patients

**Status:** Implemented ✅ (was: Incomplete 🟣 — re-validated 2026-09-19, all previously-documented gaps confirmed fixed against code, see Implementation Notes)

**Description:**

**Functional Requirements:**

##### Accessibility

- Easily accessible, on the bottom navigation bar (second button next to the home button).

##### Information shown

- This page contemplates a list of patients.
- Each patient displays the following information:
    - Patient Id (`patientId`), shown as an overline above the name, when informed (documented 2026-09-19 to match implemented behavior — see Implementation Notes).
    - First and Last Names
    - Age (if age+age unit or birthdate were informed). If not informed, "Idade não informada".

##### Navigation

- On tap patient, should redirect to patient details page for that patient.

##### Empty state

- If list is empty, should display a message "Você ainda não tem pacientes cadastrados".

##### Error state

- If loading the list fails, should display the message "Não foi possível carregar seus pacientes" plus a retry control below it.
- Retry control: a button labeled "Tentar novamente".
- Tapping it re-runs the same list-load operation triggered on page entry (i.e. re-invokes the use case backing `ListPatientsCubit.init()`), replacing the error state with loading, then with the empty/populated/error state per the result — same states/copy as the initial load, no new state is introduced.

##### Implementation Notes (re-validated against code, 2026-09-19)

- Implemented: list rendering, first/last name display, age display, tap-to-navigate to Patient Details, empty-state and error-state copy exactly matching spec, working "Tentar novamente" retry button wired to `context.read<ListPatientsCubit>().init()`, and `DsListTile`/`DsLoadingIndicator`/`DsPlaceholder`/`DsButton` DS widgets used throughout instead of raw Material widgets (`lib/features/patients/list/presentation/pages/list_patients_page.dart`). All three gaps previously logged here (English hardcoded copy, missing retry control, raw Material widgets) are confirmed closed — landed in commit `8a06bf7`, but this doc's status/notes were never updated at the time; corrected now.
- **Resolved — documented, not a gap:** the list also renders `patient.patientId` above the name via `DsListTile`'s `overline` — this was flagged 2026-09-07 as an undocumented-but-intentional behavior; now folded into the "Information shown" requirement above rather than left as an open note.
- Test coverage exists: `test/features/patients/list/presentation/pages/list_patients_page_test.dart`, `test/features/patients/list/presentation/cubit/list_patients_cubit_test.dart`.
- **Next:** none — feature complete per spec. Future work is scoped elsewhere (internationalization, priority 11; broader DS audit, priority 8).

#### 2.1.3. Patient Details

**Status:** Incomplete 🟣 (re-validated 2026-09-19 — most gaps closed by commit `cd74f42`, one gap remains blocked on 2.1.4 Calculators; see Implementation Notes)

**Description:**

**Functional Requirements:**

##### Should show the patient data in the edit form

- The patient data is displayed as a form. All the fields are disabled by default. Only for the user to see the data.
- Should show patient's latest BMI:
    - BMI will be calculated by the latest weight and the latest height.
    - If insufficient data, show a - (dash) on the value place.
    - Non-editable field.

##### Should allow editing data

- The form with the patient data shows a button with a pencil icon. When tapping this button, enables all the fields for editing.
- Patient Id, Enteral/Parenteral nutrition, Confined to bed, Hospitalized, First/Last name, Age, Age Unit and Birthdate are allowed to edit.
- The age/age unit/birthdate follow the same rules as the create patient form.
- The fields that were optional/required in the create patient form will remain optional/required.
- On tap save (disquette icon), the data should be updated on the database.
- On save success:
    - Show dialog informing that the operation was successful. The dialog auto-closes and does not redirect to a different page.
    - The save button shows a check icon indicating success and then changes back to a pencil icon.
    - Should update the calculators list for relevance.
- On save error:
    - Show dialog informing that the operation encountered an error. There should be a button to close the dialog and try again.
    - The form remains in edit mode (fields enabled and button to save).

##### Should show other patient data in a tabview

- If a tab is still not available, show the placeholder.
- Tabs: calculators, weights, heights, body measurements and history.
- Calculators (Calculadoras): based on the patient's data, shows the most relevant calculators ([see: Calculator Relevance](#calculator-relevance)). At the end of the list, should show a button "See All Calculators". The list should expand and show all available calculators.

> For more information on each tab: [2.1.4. Patient Details - Tabs](#214-patient-details---tabs)

##### Implementation Notes (validated against code, 2026-09-06)

- Implemented: read-only form for Patient Id, First/Last name, Age, Age Unit, Birthdate; pencil→save→check/close icon cycle; tabview with the 5 documented tabs (`lib/features/patients/details/presentation/widgets/patient_details_form.dart`, `lib/features/patients/details/presentation/pages/patient_details_page.dart`).
- **Gap — BMI not implemented at all:** no BMI field exists in the form, and no wiring to the standalone `CalculateBmi` use case (`lib/shared/services/calculator/domain/use_cases/bmi/calculate_bmi.usecase.dart`) using the latest weight/height from the Weights/Heights tabs (which are themselves implemented, so the dependency is unblocked — this is just not wired up yet).
- **Gap — confirmed, cross-reference (2026-09-07):** the requirement above ("Patient Id, Enteral/Parenteral nutrition, Confined to bed, Hospitalized, First/Last name, Age, Age Unit and Birthdate are allowed to edit") lists 4 fields (Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed) that `EditPatientFormEntity` (`lib/features/patients/details/domain/entities/edit_patient_form_entity.dart`) does not have at all — same underlying gap as [2.1.1 Create Patient](#211-create-patient) (missing `PATIENT` columns/`NewPatientFormEntity` fields), not a separate bug. Once those 4 fields land on Create Patient's schema/entities, they still need to be added here too. **Confirmed requirement for this pass (2026-09-12):** see [2.1.1's "Confirmed requirement" subsection](#211-create-patient) — it covers both forms in one pass (read-only display in Patient Details = same disabled-checkbox convention already used for every other field here).
- **Resolved (validated against code, 2026-09-12):** the 4 fields now exist on `EditPatientFormEntity` and are editable in `patient_details_form.dart` (disabled/enabled following the existing `!state.isEditing` convention) — see [2.1.1's resolution note](#211-create-patient) for full detail. **Stale prose note:** this section's field-order prose ("Patient Id, Enteral/Parenteral nutrition, Confined to bed, Hospitalized, First/Last name, Age, Age Unit and Birthdate") does not match what shipped — the 4 checkboxes were placed after Birthdate (last), not right after Patient Id — not corrected here per this doc's own rule against silently rewriting unfulfilled-as-specified requirements; flag for `senior-designer` if the prose order should be updated to match or if a future reorder is wanted.
- **Resolved (validated against code, 2026-09-19, commit `cd74f42`):** BMI is now wired end-to-end — `PatientDetailsCubit._computeBmi` calls `CalculateBmi` with the latest weight/height (`weights.first`/`heights.first`, newest-first sort) and patient age, storing the result on `PatientDetailsStateLoaded.bmi`; `patient_details_form.dart` displays it in a disabled "IMC" field, showing `"-"` when `bmi == null` (insufficient data) — matches spec exactly.
- **Resolved (validated against code, 2026-09-19, commit `cd74f42`):** `PatientDetailsCubit._handleSaveResult` now sets `isEditing: true` (not `false`) on error, keeping the form in edit mode as spec'd. `patient_details_page.dart` now shows a `DsDialog` on `isSaveError` with a close button wired to `closedErrorModal` — the previously-missing error dialog with retry is implemented.
- **Resolved (validated against code, 2026-09-19, commit `cd74f42`):** `updatePatientData` now validates `form.age! < 0` ("Idade inválida.") and `form.birthdate!.isAfter(DateTime.now())` ("A data de nascimento precisa ser menor que a de agora.") before saving, surfacing each as a save-error-dialog message — edit-time validation parity with Create Patient is in place.
- **Gap, unchanged — blocked on 2.1.4:** "Should update the calculators list for relevance" on save success still cannot be validated — the Calculators tab remains a `DsPlaceholder()` (see 2.1.4). Not actionable until Calculators ships.
- **Gap, newly found (2026-09-19, not previously documented):** the spec's "On save success: Show dialog informing that the operation was successful. The dialog auto-closes" is not implemented — only the icon-cycle half of that requirement (pencil→check→pencil, via `isSaved`) is wired. `patient_details_page.dart`'s `BlocConsumer` only listens for `isSaveError` to show a `DsDialog`; there is no equivalent listener for `isSaved` to show a success dialog. Distinct from the icon requirement, which is fully implemented.
- **Next:** add the missing save-success dialog (auto-closing, per spec); re-validate "update the calculators list for relevance" once 2.1.4's Calculators tab exists.
- **Resolved (validated against code, 2026-09-19, priority 5 pass):** the save-success dialog gap above is fixed — `patient_details_page.dart`'s `BlocConsumer` now has a second listener branch, mirroring the existing `isSaveError` branch, firing on the `isSaved` true-transition and showing an auto-closing `DsDialog` ("Sucesso" / "Dados do paciente atualizados com sucesso.", 2s duration, no `onClose`/no navigation) — matches the same pattern already used by Create Patient's save-success dialog. Remaining gap unchanged: "update the calculators list for relevance" is still blocked on 2.1.4 Calculators (unbuilt).

#### 2.1.4. Patient Details - Tabs

**Status:** Implementing 🟡 (was: Incomplete 🟣 — corrected 2026-09-07, same rationale as [2.1.1](#211-create-patient): 2 of 5 sub-tabs (Calculators, History) are entirely unbuilt, not "works fine, has some things to add" per the status legend)

**Description:**

##### Implementation Notes — per tab (validated against code, 2026-09-07)

| Tab | Status | Notes |
| --- | ------ | ----- |
| Calculators | Ready for Dev 🔵 (was labeled "Not started 🔵", which is not a value in the [status legend](#32-implementation-statuses) — relabeled to the closest legend term, 2026-09-07) | `DsPlaceholder()` only (`patient_details_page.dart`). No calculator relevance logic, no bottom sheet, no per-calculation tables exist yet (see DB schema gap below). |
| Weights | Implementing 🟡 | Save works (value + auto `DateTime.now()`), curve icon (asc/desc) and empty-state message implemented. Missing: date/time input field (spec requires an optional, defaults-to-now, non-future date/time picker — currently hardcoded to `now()`), "weight type" display, delete-on-swipe with confirmation dialog and curve recompute (`Dismissible` is commented out in `measurements_list.dart` — **product decision, 2026-09-07: Weights/Heights must implement delete-on-swipe matching Body Measurements' pattern; this is now a stated requirement below, not an open question**). **`DsButton` component-level blocker resolved (2026-09-12, [priority 4](#1-roadmap-prioritization), [ADR 0003](adr/0003-ds-button-disabled-parameter.md)):** `DsButton` now supports a `disabled` param and blocks taps while `isLoading`. **Still open — wiring gap unchanged (re-verified 2026-09-19):** `MeasurementInputField`/this tab's Save button still never passes `disabled:`/gates `saveCallback` on required-fields-empty or mid-save state, so the disabled-while-invalid and disabled-while-saving behavior is still not implemented here — only the component capability exists now. **Bug — re-verified still present, 2026-09-19 (commit `cd74f42` did not touch this):** `PatientDetailsCubit.saveWeight`/`saveHeight` still call the create use case without awaiting/checking the `Result` and without re-fetching weights/heights or clearing the form afterwards — the spec's "on save success: fields cleared, list updated, BMI updated" cannot work as written until this is fixed. **Resolved (validated against code, 2026-09-19, priority 5 pass):** `saveWeight` now awaits the create use case's `Result` via `.when(ok:, error:)` — on error, sets `isSaveError`/`saveErrorMessage` ("Não foi possível salvar o peso. Tente novamente.") and leaves the input form untouched for retry; on success, refetches weights, recomputes `bmi` via the existing `_computeBmi` helper, clears the weight input form, and (fixed during tech-lead review, see general note below) resets `isSaveError` back to `false` so a prior failure doesn't stick. Covered by new cubit tests in `patient_details_cubit_test.dart`, including an error-then-retry-success regression test. **Resolved (validated 2026-09-19, commit `cd74f42`):** `WeightRepositoryImpl.getWeights`/`HeightRepositoryImpl.getHeights` now query `where: 'patientId = ?'` — previously undocumented in this doc but a real correctness bug (measurements were not filtered by patient before this fix); confirmed fixed in both `weight_repository_impl.dart` and `height_repository_impl.dart`. |
| Heights | Implementing 🟡 | Same gaps as Weights (shares `PatientMeasurementsTab`/`MeasurementsList`/`MeasurementInputField`); the disabled-state wiring gap above is still open (component blocker resolved 2026-09-12 per ADR 0003; wiring itself still not done). Patient-filtering bug also resolved, see Weights row. **Resolved (validated against code, 2026-09-19, priority 5 pass):** the `saveHeight` Result-handling bug is fixed, mirroring `saveWeight` above — awaits the create use case's `Result`, sets `isSaveError`/`saveErrorMessage` ("Não foi possível salvar a altura. Tente novamente.") and preserves the form on error, refetches heights + recomputes `bmi` + clears the form + resets `isSaveError` to `false` on success. Covered by new cubit tests, including an error-then-retry-success regression test. |
| Body Measurements | Implementing 🟡 | Accordion grouping by type, collapsed-by-default, curve icons and empty-state implemented (`patient_body_measurements_tab.dart`). **Known bug, flagged in code:** `saveNewBodyMeasurement` has a `// TODO - nao ta salvando ainda (erro)` comment in `patient_details_cubit.dart` — save is not reliably working. **`DsButton` component-level blocker resolved (2026-09-12, [ADR 0003](adr/0003-ds-button-disabled-parameter.md)); wiring itself still not done:** same `MeasurementInputField` disabled-state gap as Weights/Heights above — `disabled:` is not yet passed/gated here either. Also missing: date/time field, delete-on-swipe with confirmation dialog, curve recompute after deletion (all per spec). **Resolved (validated against code, 2026-09-19, priority 5 pass):** the `saveNewBodyMeasurement` bug above is fixed — the `// TODO - nao ta salvando ainda (erro)` comment is removed; the method now awaits the create use case's `Result`, sets `isSaveError`/`saveErrorMessage` ("Não foi possível salvar a medida. Tente novamente.") and preserves the form on error, and on success refetches body measurements (applying `.reversed.toList()` to match `init()`'s existing newest-first ordering, since the use case itself does not sort), clears the form, and resets `isSaveError` to `false`. Covered by new cubit tests, including an error-then-retry-success regression test. |
| History | Ready for Dev 🔵 (relabeled, see Calculators row) | `DsPlaceholder()` only. **Hard dependency, not parallel work:** History only displays Calculators' output, so it has nothing to show until the Calculators tab exists — Calculators must ship first, not be scheduled alongside it. |

- **Empty-state copy mismatch vs. spec:** Weights/Heights show `"Não encontramos pesos/alturas para esse paciente."` (spec: `"Nenhum peso cadastrado"`); Body Measurements shows `"Nenhuma medida encontrada para esse paciente."` (spec: `"Sem medidas cadastradas para esse paciente ainda"`). Implementation deviated from the documented copy — not editing the requirement text since the deviation looks unintentional (dev tech debt), not a documented decision.
- **Design-system primitive resolved (2026-09-07):** `DsBottomSheet` shipped ([priority 3](#1-roadmap-prioritization), `lib/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart`). Both Calculators ("tap a calculator → bottom sheet to insert data") and History ("tap a result → bottom sheet with parameters and result") can now proceed — the primitive is no longer a blocker. Neither tab is implemented yet (both still `Ready for Dev 🔵`, still `DsPlaceholder()` only); only the shared component the two interactions depend on exists so far.
- **Resolved (product decision, 2026-09-07):** Weights and Heights must implement delete-on-swipe with confirmation dialog and curve recompute, matching Body Measurements' pattern ([2.1.4 Body Measurements](#body-measurements)). This was previously an open question (the functional requirements below only documented deletion for Body Measurements) — now stated explicitly in the Weights/Heights sections below.
- **Bug found and fixed during priority 5 tech-lead review (2026-09-19):** the initial fix for the three Result-handling bugs above (`saveWeight`/`saveHeight`/`saveNewBodyMeasurement`) set `isSaveError: true` on failure but never set it back to `false` on a subsequent success — since `PatientDetailsStateLoaded.copyWith` uses the `x ?? this.x` pattern, once any of these three flows failed once, `isSaveError` stayed stuck `true` forever afterward (the save/edit button icon would keep showing the error state even after later successful saves). Fixed by adding `isSaveError: false` to each success-branch emit, mirroring the existing `_handleSaveResult`/`updatePatientData` precedent. Regression-tested: one test per flow (weight/height/body measurement) asserting error → then retry-success → `isSaveError == false`.
- **Known tech debt, logged not fixed (2026-09-19):** `PatientDetailsStateLoaded.copyWith`'s `bmi: bmi ?? this.bmi` pattern cannot express "recompute to null" — if `_computeBmi` ever legitimately returned `null` after a save (e.g. weights/heights list becoming empty), the previous non-null `bmi` value would incorrectly persist instead of showing `"-"`. Confirmed currently unreachable: delete-on-swipe for Weights/Heights is not built yet (see gaps above), so these lists never go from non-empty to empty within the save flows that trigger recompute. Revisit if/when delete-on-swipe ships for Weights/Heights.

##### Calculators

**Name:** Calculadoras

**Description:** Based on the patient's data, shows the most relevant calculators (see [Calculator Relevance](#calculator-relevance)). At the end of the list, should show a button "See All Calculators". The list should expand and show all available calculators.

**Architecture (product decision, 2026-09-07):** each calculator (BMI persistence, Energy Expenditure, the 3 Enteral Nutrition sub-types, Glucose Infusion Rate, Nitrogen Balance, Protein Needs, each Screening tool, Water Needs, Weight Loss Classification) is its own sub-feature under a new `lib/features/calculators/` directory, following the standard domain/data/presentation layering. `lib/features/calculators/` itself also holds the logic shared across all calculators: the "See All"/"See Relevant Only" toggle, relevance-filtering logic, and the tap-to-bottom-sheet interaction shell.

**Functional Requirements:**

- When tapping the "See All Calculators" button, the list should show the calculators divided by type (see [All calculators](#all-calculators)).
- The "See all" button should become "See Relevant Only" after being tapped.
- When tapping a calculator, should open bottom sheet to insert data.
- When calculating weight, there should be a checkbox to indicate if the dietitian wants to use that weight for calculation.
    - For example, the patient could have a very recent real weight (measured by a scale), but the dietitian calculated the adjusted weight at the moment. If they don't want to use the adjusted weight, but the scale weight, they should be able to.
    - If a weight is not considered for calculation, the previous allowed weight will be considered — meaning the preceding weight (by date) that was itself marked "consider for calculations" = true, not simply the immediately-prior weight row regardless of that flag (product decision, 2026-09-07, resolving prior ambiguity).
    - The calculated weight should be saved in the existing Weights table. Other columns will have to be added, such as: consider for calculations; weight type (adjusted, measured by scale, ideal...).
- All the data (except for weight) must be saved in separate tables.
- Every data saved should reference the parameters used - weight, height, gender, injury factor...
- Every data saved should be linked to the patient (by local database ID):

    | Calculation | Table |
    | ----------- | ----- |
    | BMI | BMI |
    | Energy Expenditure | ENERGY_EXPENDITURES |
    | Enteral Nutrition - Dripping | ENTERAL_NUTRITIONS_DRIPPING |
    | Enteral Nutrition - Speed | ENTERAL_NUTRITIONS_SPEED |
    | Enteral Nutrition - Volume | ENTERAL_NUTRITIONS_VOLUME |
    | Glucose Infusion Rate | GLUCOSE_INFUSION_RATES |
    | Nitrogen Balance | NITROGEN_BALANCES |
    | Protein Needs | PROTEIN_NEEDS |
    | Screenings | One table per screening tool (i.e.: SCREENING_MST, SCREENING_STRONG_KIDS...) - should include the answers |
    | Water needs | WATER_NEEDS |
    | Weight | WEIGHTS (existing - just include the new needed columns) |
    | Weight Loss Classification | WEIGHT_LOSS_CLASSIFICATIONS |

**DB schema gap (checked against `lib/core/services/database/app_database_tables.dart`, 2026-09-06):** only `PATIENT`, `WEIGHTS`, `HEIGHTS` and `BODY_MEASUREMENTS` exist today. None of `BMI`, `ENERGY_EXPENDITURES`, `ENTERAL_NUTRITIONS_DRIPPING/SPEED/VOLUME`, `GLUCOSE_INFUSION_RATES`, `NITROGEN_BALANCES`, `PROTEIN_NEEDS`, the per-screening tables, `WATER_NEEDS` or `WEIGHT_LOSS_CLASSIFICATIONS` exist yet — expected, since the Calculators tab itself is unbuilt (see notes above). `WEIGHTS` also does not yet have the "consider for calculations" / "weight type" columns this section calls for — it currently only has `id, value, createdAt, patientId` (shared with `HEIGHTS` via `_baseMeasurementTableFields`). The DB migration mechanism ([priority 1](#1-roadmap-prioritization), [ADR 0001](adr/0001-database-schema-migrations.md)) has shipped, so the `WEIGHTS` column addition and every new table below are no longer blocked — none of them are built yet, though.

**Storage convention (product decision reversed 2026-09-07, supersedes the same-day "fixed typed columns per table" decision):** each calculation table uses a base+`inputParams` JSON structure, not one fixed column per input parameter. Fixed base columns are specific to that calculation (result value(s), `createdAt`, `patientId`, and a discriminant where relevant — e.g. `formula` enum for Energy Expenditure's 5 formulas, `type` for Enteral Nutrition's 3 sub-types), plus a single `inputParams` column storing a JSON array of `{ key, label, value }` entries: `key` is a stable, language-independent identifier (e.g. `"weight_kg"`, `"injury_factor"`) that does not change with app locale; `label` is a user-facing display label (may be an i18n key rather than a hardcoded string); `value` is the actual value used for that parameter at calculation time. This applies uniformly to every calculator table listed above, including the per-screening-tool tables — one convention everywhere, rather than deciding case-by-case, because formulas within a calculator type often need different params (Energy Expenditure's 5 formulas, Enteral Nutrition's 3 sub-types) and a fixed-column-per-param design would otherwise require sparse/nullable columns per variant or one table per formula variant.

**Hard prerequisite (2026-09-07; satisfied 2026-09-12):** the 4 missing `PATIENT` columns (Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed — see [2.1.1 Create Patient](#211-create-patient) gap) are not just a form-completeness gap; they were a hard prerequisite for Calculator Relevance filtering specifically (see [Calculator Relevance](#calculator-relevance)). Those 4 fields have now landed end-to-end (DB + `PatientModel` + Create/Edit Patient forms, see [2.1.1's resolution note](#211-create-patient)) — **this specific prerequisite is cleared.** This does not mean Calculators/Calculator Relevance itself is built: the relevance-filtering logic that consumes these fields, the Calculators tab UI, and every calculator table/sub-feature below remain entirely unbuilt (still `Ready for Dev 🔵`, see the per-tab table above).

**ADRs needed before implementation (architecture review, 2026-09-06):**
- ~~**DB migration strategy**~~ — resolved: [ADR 0001](adr/0001-database-schema-migrations.md) (sqflite `version`/`onCreate`/`onUpgrade` driven by `sinceVersion` metadata). Unblocks the `WEIGHTS` columns above and this entire table list — still not implemented.
- ~~**Screening storage granularity**~~ — resolved (product decision, 2026-09-07; JSON-storage part reversed same day, see storage convention above): one table per screening tool (`SCREENING_MST`, `SCREENING_STRONG_KIDS`, `SCREENING_MUST`, `SCREENING_NRS_2002`, future `SCREENING_ASG`) still stands — a single `SCREENINGS` table with a `type` discriminant was rejected in favor of per-tool tables. However, each per-tool table now uses the base+`inputParams` JSON structure like every other calculator table (questions/answers stored as `{ key, label, value }` entries in `inputParams`, not as fixed typed columns per question) — the original "no JSON/blob column" part of this decision is reversed. `mobile-dev`/`senior-analyst` should still write a short ADR under `docs/adr/` documenting this decision and rationale before/during implementation — not written here.
- **New technical dependency surfaced (2026-09-07):** `AppDatabaseTables`/`TableSqlType` (`lib/core/services/database/app_database_tables.dart`) currently has no JSON/blob column type — storing `inputParams` requires adding a new `TableSqlType` case (likely a TEXT column with JSON serialization at the model layer, per sqflite convention) before any calculator table can be created. Small enough to be done as part of the first calculator table's implementation (likely BMI or Energy Expenditure), not a separate priority-table entry — flagged here so it isn't rediscovered as a surprise.

##### Weights

- Should have a form to save measured-by-scale weight (fields: weight in kg, date and time).
- Date and time:
    - Optional.
    - Defaults to now.
    - Cannot be future datetime.
- Weight in kg is required.
- While required fields are not filled, the Save button is disabled.
- While saving, Save button should be disabled.
- On save success:
    - The fields must be cleared.
    - The weight list is updated to show the new weight.
    - The BMI is updated.
- On save error:
    - Show dialog informing the error.
    - The form keeps the data there for the user to try again.
- If no weights to display, show a message: "Nenhum peso cadastrado".
- If there's at least one weight for the user:
    - Order by the most recent first.
    - Show the curve (asc, desc) or nothing if there was no change from the last weight to the new.
    - Show the weight, the date and time, and the type of the weight.
- A weight can be deleted when the tile is dragged to the left (product decision, 2026-09-07, matching Body Measurements' pattern):
    - On deletion attempt, a confirmation dialog will appear.
    - On confirm, the weight should be removed from the local database.
    - On deletion error, an error dialog should be shown.
    - On deletion success, a success dialog (auto-closeable) should appear. The curves for the weights that came after the one that was deleted should be updated.

##### Heights

- Same as weights, but for heights (including delete-on-swipe with confirmation dialog and curve recompute).

##### Body Measurements

- Form to include measurement should have:
    - Measurement type (Tipo da medida) - required.
    - Value (Medida) - required.
    - Date and Time of measurement - optional - defaults to now.
- The Save button:
    - Will be disabled if the fields are not filled.
    - Will be disabled while saving.
- On save success:
    - Clear the fields.
    - Update the lists to show the new measurement.
- On save error:
    - Show a dialog informing the error, with a close button.
    - Keep the fields filled for the user to retry.
- The measurements list should be grouped by measurement type. The measurement type will be an accordion and list all the measurements of that type, ordered by the latest measurement first.
- All accordions appear collapsed at first. More than one can be expanded at once.
- The measurements should show a curve (asc, desc) or no curve if there were no changes between the last and new measurement.
- If a measurement type does not contain any measurements yet, the group should not be displayed on the list.
- If there are still no measurements for the patient, show a message "Sem medidas cadastradas para esse paciente ainda".
- A measurement can be deleted when the tile is dragged to the left:
    - On deletion attempt, a confirmation dialog will appear.
    - On confirm, the measurement should be removed from the local database.
    - On deletion error, an error dialog should be shown.
    - On deletion success, a success dialog (auto-closeable) should appear. The curves for the measurements that came after the one that was deleted should be updated.

##### History

- This tab will show all the calculators results.
- The results:
    - Should be grouped by calculator type.
    - Should be ordered (latest first).
    - Should be deletable (on tile drag).
- When a result is tapped, should open a bottom sheet with the calculation parameters and result.
- If a group (calculation type) does not contain any results, it should not be listed.
- If there are no results at all (meaning the calculators were never used), a message should be displayed "Sem histórico de cálculos para esse paciente".

---

## 3. Useful Information

### 3.1. Calculators

#### All calculators

- **BMI:** Calculates patient BMI. The raw BMI value is shown on the patient profile for all ages. BMI *classification* (this calculator) is available only for patients 19+ — the calculator only classifies adult/elder BMI, there is no pediatric classification. This age restriction is intentional and permanent, not a gap to fill later (product decision, 2026-09-07).

- **Energy Expenditure:** Calculates the patient's energy expenditure. There are several different formulas:
    - Harris Benedict
    - Mifflin
    - Pocket formula
    - Schofield: ideal for kids age < 10yo
    - WHO: ideal for kids age < 19yo

- **Enteral Nutrition:** Calculates the enteral nutrition values.
    - EN Dripping
    - EN Speed
    - EN Volume

- **Nitrogen Balance:** Calculates patient's nitrogen balance.

- **Parenteral Nutrition:** Calculates parenteral nutrition values.
    - PN Glucose Infusion Rate

- **Protein Needs:** Calculates protein needs for the patient.

- **Screening:** Nutritional Screening tools to detect patient's nutritional status.
    - ASG (still needs to be created)
    - MST (still needs to be created)
    - MUST (ideal for adults and elders)
    - NRS 2002 (ideal for hospitalized adults and elders)
    - STRONG Kids (ideal for kids)

- **Water Needs:** Calculates water needs for patient.

- **Weight:** Calculates different types of weights for the patient.
    - Adequation
    - Adjusted - Dry weight
    - Adjusted - Obesity
    - Estimated
    - Ideal

- **Weight loss classification**

#### References

The calculators rules and results still need to be validated by a dietitian.

For now, keep it as a source of truth and easy to modify later.

#### Calculator Relevance

The calculator relevance is based on the type of calculator and the patient data.

The table below displays the calculator type and the patient params that make the calculator more relevant.

| Calculator Type | Patient Params |
| --------------- | --------------- |
| BMI | Always Relevant (19+); for patients under 19, only the raw BMI value is shown on the profile — not classified (product decision, 2026-09-07) |
| Energy Expenditure | Age, Confined to bed, Hospitalized |
| Enteral/Parenteral Nutrition | Patient uses parenteral/enteral nutrition |
| Nitrogen Balance | Hospitalized, Parenteral/Enteral nutrition, Confined to bed |
| Protein Needs | Always Relevant |
| Weight - Adequation/Adjusted/Ideal | Obesity/Underweight BMI |
| Weight - Adjusted (Dry weight) | Hospitalized, Confined to bed |
| Weight - Estimated | Hospitalized, Confined to bed |
| Weight Loss Classification | If the patient's 2 last weights form a desc curve (there was weight loss) |
| Screening | Age, Hospitalized, Confined to bed |

**Resolved (product decision, 2026-09-07):** the prior conflict between "BMI: Always Relevant" and "Available for all ages (from 19+)" is resolved above — BMI classification is relevant/available only for patients 19+; this matches the implemented `CalculateBmi` (`lib/shared/services/calculator/domain/use_cases/bmi/calculate_bmi.usecase.dart`, adult/elder branches only, no pediatric branch) and is intentional, not a gap.

### 3.2. Implementation Statuses

| Status | Description |
| ------ | ----------- |
| Ready for Dev 🔵 | Still not implemented. On the line to be implemented. |
| Implementing 🟡 | On the way. |
| Incomplete 🟣 | Works fine, but still has some things to be implemented. |
| Reprioritized 🚫 | If next in line to be implemented, will be skipped until it is marked as Ready for Dev. |
| Implemented ✅ | Implemented and validated. |
| Awaiting validation 🧪 | Implemented, but still need to be tested and validated. |
