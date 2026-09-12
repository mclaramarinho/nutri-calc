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
| 1 | Create DB migration mechanism | Implemented ✅ | 2026-09-06 | `AppDatabaseService.init()` now opens the DB with sqflite native `version`/`onCreate`/`onUpgrade`, driven by `sinceVersion` metadata on `AppDatabaseTables` (table) and `TableSqlField` (column) plus a `kAppDatabaseVersion` constant — see [ADR 0001](adr/0001-database-schema-migrations.md). Additive-only (new columns/new tables); fresh install and upgrade both converge to the same schema from the same `fields`/`sql` source. Covered by 13 tests in `test/core/services/database/app_database_service_test.dart` (fresh-install schema/column correctness, full-row insert across all tables, reopen-at-higher-version data integrity, `onUpgrade` mechanics via a versioned fixture, `addColumnSql` guards for PRIMARY KEY/UNIQUE-via-migration and NOT-NULL-without-default). **Tech debt:** the `onCreate`/`onUpgrade` dispatch loop is inlined in `init()` rather than extracted into an independently-testable unit — revisit extraction when a second real migration ships; downgrade (opening an older-versioned request against a newer-schema DB file) is sqflite's silent no-op and is unspecified/untested — flag if it ever becomes a real scenario. **Unblocks (not yet built):** the 4 missing `PATIENT` columns ([2.1.1](#211-create-patient)), the `WEIGHTS` "consider for calculations"/"weight type" columns, and all new calculator tables ([2.1.4 Calculators](#calculators)) can now be added using this pattern. |
| 2 | Validate this roadmap | Implemented ✅ | 2026-09-07 | Ran the `po` → `senior-analyst` review pass: cross-checked every feature's documented status against code (results folded into each feature's "Implementation Notes" in section 2.1), resolved the screening-storage and calculator-input-storage conventions (base+`inputParams` JSON, see [2.1.4 Calculators](#calculators)), and surfaced the two new priorities below (3, 4) plus 11. Also substantially covers priority 5 below for the features that exist today (2.1.1–2.1.4) — see that row. |
| 3 | Build `DsBottomSheet` design-system component | Implemented ✅ | 2026-09-07 | Shipped: `lib/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart` — `DsBottomSheet.show<T>()` (optional title, required scrollable body, optional actions footer, `isDismissible`/`enableDrag`, content-driven sizing via `maxHeightFraction`, single-instance guard). Required `AppRouter.pop()` → `pop<T extends Object?>([T? result])` (`lib/routing/app_router.dart`) to support `Future<T?>` result-passing — see [ADR 0002](adr/0002-approuter-pop-generic-result.md). Covered by 11 widget tests (`test/shared/design_system/widgets/ds_bottom_sheet_test.dart`); `flutter test` 24/24 pass, `flutter analyze` clean. Reviewed by tech-lead (2 blocking issues found and fixed mid-review — a single-instance-guard cast crash and a fragile guard-clearing mechanism — plus 1 non-blocking spec deviation on body padding); second pass PASS/ship. Unblocks Calculators/History (2.1.4) to proceed — those tabs are still not implemented. **Minor, non-blocking:** tech-lead left two small hardening notes (not tracked as tech debt per tech-lead's own framing) plus a cosmetic `BorderRadius.only` vs `BorderRadius.vertical` equivalence note — optional future nice-to-haves, no action required. |
| 4 | Add `enabled`/`disabled` parameter to `DsButton` | Ready for Dev 🔵 | 2026-09-07 (added) | Added 2026-09-07, product decision. `DsButton` (`lib/shared/design_system/widgets/ds_button/ds_button.dart`) currently only supports `isLoading`/`onTap`. Needed for the "disable Save while required fields empty / while saving" rules already documented for Weights, Heights and Body Measurements (2.1.4), and will recur in every Calculators bottom-sheet form. |
| 5 | Validate what was implemented | Implementing 🟡 | 2026-09-07 | For existing features (2.1.1–2.1.4): **largely done as of 2026-09-07** via priority 2's pass — see each feature's "Implementation Notes" for the registered gaps. Remaining scope: re-validate 2.1.1–2.1.4 after priority 6 lands (confirm fixes actually closed the documented gaps), and validate the new features built under priority 7 (Calculators, History) once they exist, the same way — status + gaps registered in this file's feature-section tables. |
| 6 | Implement what is missing for existing features | Ready for Dev 🔵 | — | Adjust what is not correct in the existing features and implement what is missing for each one of them. |
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

**Status:** Implementing 🟡 (was: Incomplete 🟣 — corrected per product decision, see Implementation Notes)

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

#### 2.1.2. List Patients

**Status:** Incomplete 🟣 (was: Awaiting validation 🧪 — downgraded, see notes)

**Description:**

**Functional Requirements:**

##### Accessibility

- Easily accessible, on the bottom navigation bar (second button next to the home button).

##### Information shown

- This page contemplates a list of patients.
- Each patient displays the following information:
    - First and Last Names
    - Age (if age+age unit or birthdate were informed). If not informed, "Idade não informada".

##### Navigation

- On tap patient, should redirect to patient details page for that patient.

##### Empty state

- If list is empty, should display a message "Você ainda não tem pacientes cadastrados".

##### Implementation Notes (validated against code, 2026-09-06; re-verified unchanged 2026-09-07)

- Implemented: list rendering, first/last name display, age display, tap-to-navigate to Patient Details (`lib/features/patients/list/presentation/pages/list_patients_page.dart`).
- **Gap — status downgraded from "Awaiting validation 🧪" to "Incomplete 🟣":** the empty state shows `"No patients to display"` (English, hardcoded) instead of the documented `"Você ainda não tem pacientes cadastrados"`; the error state shows `"Error loading patients"` (also English, no retry action). Both violate the CLAUDE.md rule that UI copy must be Portuguese, and neither matches the acceptance criteria above. The list/loading/error states also use raw `Text`/`CircularProgressIndicator`/`ListTile` instead of DS widgets.
- **Gap not previously noted (2026-09-07):** the list also renders `patient.patientId` above the name (`list_patients_page.dart:45-47`) when present — undocumented in the "Information shown" requirement above (spec only lists First/Last Name and Age). Not flagged as a bug (harmless/likely useful), but the requirement is missing this acceptance criterion; add it explicitly if the behavior is intentional.
- **Next:** fix copy to match spec, add a retry affordance for the error state, migrate to DS widgets before re-marking as "Awaiting validation".

#### 2.1.3. Patient Details

**Status:** Incomplete 🟣

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
- **Gap — confirmed, cross-reference (2026-09-07):** the requirement above ("Patient Id, Enteral/Parenteral nutrition, Confined to bed, Hospitalized, First/Last name, Age, Age Unit and Birthdate are allowed to edit") lists 4 fields (Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed) that `EditPatientFormEntity` (`lib/features/patients/details/domain/entities/edit_patient_form_entity.dart`) does not have at all — same underlying gap as [2.1.1 Create Patient](#211-create-patient) (missing `PATIENT` columns/`NewPatientFormEntity` fields), not a separate bug. Once those 4 fields land on Create Patient's schema/entities, they still need to be added here too.
- **Bug — save error does not keep edit mode:** `PatientDetailsCubit._handleSaveResult` (`lib/features/patients/details/presentation/cubit/patient_details_cubit.dart`) always sets `isEditing: false` regardless of `isSuccess`, contradicting "On save error: the form remains in edit mode". No error dialog is shown either — the spec's error dialog with retry is entirely missing.
- **Gap:** age-negative and birthdate-future validation (documented as following the "same rules as create patient form") are not enforced on edit — `updateAge`/`updateBirthdate` in the cubit accept any value.
- **Gap:** "Should update the calculators list for relevance" on save success cannot be validated — the Calculators tab is a placeholder (see 2.1.4).
- **Next:** wire BMI, fix the edit-mode-on-error bug, add the error dialog, add edit-time validation parity with Create Patient.

#### 2.1.4. Patient Details - Tabs

**Status:** Implementing 🟡 (was: Incomplete 🟣 — corrected 2026-09-07, same rationale as [2.1.1](#211-create-patient): 2 of 5 sub-tabs (Calculators, History) are entirely unbuilt, not "works fine, has some things to add" per the status legend)

**Description:**

##### Implementation Notes — per tab (validated against code, 2026-09-07)

| Tab | Status | Notes |
| --- | ------ | ----- |
| Calculators | Ready for Dev 🔵 (was labeled "Not started 🔵", which is not a value in the [status legend](#32-implementation-statuses) — relabeled to the closest legend term, 2026-09-07) | `DsPlaceholder()` only (`patient_details_page.dart`). No calculator relevance logic, no bottom sheet, no per-calculation tables exist yet (see DB schema gap below). |
| Weights | Implementing 🟡 | Save works (value + auto `DateTime.now()`), curve icon (asc/desc) and empty-state message implemented. Missing: date/time input field (spec requires an optional, defaults-to-now, non-future date/time picker — currently hardcoded to `now()`), "weight type" display, delete-on-swipe with confirmation dialog and curve recompute (`Dismissible` is commented out in `measurements_list.dart` — **product decision, 2026-09-07: Weights/Heights must implement delete-on-swipe matching Body Measurements' pattern; this is now a stated requirement below, not an open question**), **confirmed missing (2026-09-07): no disabled-while-required-fields-empty and no disabled-while-saving behavior** — `DsButton` (`lib/shared/design_system/widgets/ds_button/ds_button.dart`) only takes `isLoading`/`onTap`, it has no `disabled`/`enabled` parameter at all (see [priority 4](#1-roadmap-prioritization)), and `MeasurementInputField` never gates `saveCallback`, so the Save button is tappable even with an empty/invalid value or mid-save. **Bug (architecture review, 2026-09-06):** `PatientDetailsCubit.saveWeight`/`saveHeight` call the create use case without awaiting/checking the `Result` and without re-fetching weights/heights or clearing the form afterwards — the spec's "on save success: fields cleared, list updated, BMI updated" cannot work as written until this is fixed. |
| Heights | Implementing 🟡 | Same gaps as Weights (shares `PatientMeasurementsTab`/`MeasurementsList`/`MeasurementInputField`), including the `saveHeight` Result-handling bug and the disabled-state gap above. |
| Body Measurements | Implementing 🟡 | Accordion grouping by type, collapsed-by-default, curve icons and empty-state implemented (`patient_body_measurements_tab.dart`). **Known bug, flagged in code:** `saveNewBodyMeasurement` has a `// TODO - nao ta salvando ainda (erro)` comment in `patient_details_cubit.dart` — save is not reliably working. **Confirmed missing (2026-09-07):** same `DsButton`/`MeasurementInputField` disabled-state gap as Weights/Heights above. Also missing: date/time field, delete-on-swipe with confirmation dialog, curve recompute after deletion (all per spec). |
| History | Ready for Dev 🔵 (relabeled, see Calculators row) | `DsPlaceholder()` only. **Hard dependency, not parallel work:** History only displays Calculators' output, so it has nothing to show until the Calculators tab exists — Calculators must ship first, not be scheduled alongside it. |

- **Empty-state copy mismatch vs. spec:** Weights/Heights show `"Não encontramos pesos/alturas para esse paciente."` (spec: `"Nenhum peso cadastrado"`); Body Measurements shows `"Nenhuma medida encontrada para esse paciente."` (spec: `"Sem medidas cadastradas para esse paciente ainda"`). Implementation deviated from the documented copy — not editing the requirement text since the deviation looks unintentional (dev tech debt), not a documented decision.
- **Design-system primitive resolved (2026-09-07):** `DsBottomSheet` shipped ([priority 3](#1-roadmap-prioritization), `lib/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart`). Both Calculators ("tap a calculator → bottom sheet to insert data") and History ("tap a result → bottom sheet with parameters and result") can now proceed — the primitive is no longer a blocker. Neither tab is implemented yet (both still `Ready for Dev 🔵`, still `DsPlaceholder()` only); only the shared component the two interactions depend on exists so far.
- **Resolved (product decision, 2026-09-07):** Weights and Heights must implement delete-on-swipe with confirmation dialog and curve recompute, matching Body Measurements' pattern ([2.1.4 Body Measurements](#body-measurements)). This was previously an open question (the functional requirements below only documented deletion for Body Measurements) — now stated explicitly in the Weights/Heights sections below.

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

**Hard prerequisite (2026-09-07):** the 4 missing `PATIENT` columns (Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed — see [2.1.1 Create Patient](#211-create-patient) gap) are not just a form-completeness gap; they are a hard prerequisite for Calculator Relevance filtering specifically (see [Calculator Relevance](#calculator-relevance)). The Calculators tab's relevance logic cannot ship correctly until those columns land end-to-end (DB + entity + Create/Edit Patient forms).

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
