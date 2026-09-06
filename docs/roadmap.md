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

| Priority | What | Description |
| -------- | ---- | ----------- |
| 1 | Create DB migration mechanism | `AppDatabaseService.init()` only runs `CREATE TABLE IF NOT EXISTS` per table (`lib/core/services/database/app_database_service.dart`) — there is no `onUpgrade`/versioning. Any column added to an already-created table (e.g. new `PATIENT` fields for [2.1.1](#211-create-patient), new `WEIGHTS` columns for [Calculators](#calculators)) will silently never materialize on devices that installed an earlier schema. This blocks all further schema changes and must land first. |
| 2 | Validate this roadmap | Look for inconsistencies, gaps, improvement opportunities, etc. |
| 3 | Validate what was implemented | Validate what was implemented, using this file as a source of truth. What was discovered should be registered on the specific topic of this file. For example: Create patient (feature) has XYZ implemented, but is missing ABC. This info should be registered on a table in the feature section. |
| 4 | Implement what is missing for existing features | Adjust what is not correct in the existing features and implement what is missing for each one of them. |
| 5 | Implement new features | Implement the remaining non-existing features. |
| 6 | Create Design System for the app | Work like a senior designer and: 1) identify and understand the target-user profile, their possible preferences and what is the best UX/UI for them; 2) determine color palette, spacings, etc. tokens for the app; 3) update widgets and screens to follow new Design System directives. |
| 7 | Refactor | Go through the database and find code gaps, such as code repetition, widgets that should be design system reusable components, etc. |
| 8 | Create Dark Mode | Create dark mode for app. |

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
- **Technical Debt:** none of the above is optional polish — it's core schema. Needs a DB migration story once `PATIENT` gets new columns — see [priority 1](#1-roadmap-prioritization), "Create DB migration mechanism".
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

##### Implementation Notes (validated against code, 2026-09-06)

- Implemented: list rendering, first/last name display, age display, tap-to-navigate to Patient Details (`lib/features/patients/list/presentation/pages/list_patients_page.dart`).
- **Gap — status downgraded from "Awaiting validation 🧪" to "Incomplete 🟣":** the empty state shows `"No patients to display"` (English, hardcoded) instead of the documented `"Você ainda não tem pacientes cadastrados"`; the error state shows `"Error loading patients"` (also English, no retry action). Both violate the CLAUDE.md rule that UI copy must be Portuguese, and neither matches the acceptance criteria above. The list/loading/error states also use raw `Text`/`CircularProgressIndicator`/`ListTile` instead of DS widgets.
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
- **Bug — save error does not keep edit mode:** `PatientDetailsCubit._handleSaveResult` (`lib/features/patients/details/presentation/cubit/patient_details_cubit.dart`) always sets `isEditing: false` regardless of `isSuccess`, contradicting "On save error: the form remains in edit mode". No error dialog is shown either — the spec's error dialog with retry is entirely missing.
- **Gap:** age-negative and birthdate-future validation (documented as following the "same rules as create patient form") are not enforced on edit — `updateAge`/`updateBirthdate` in the cubit accept any value.
- **Gap:** "Should update the calculators list for relevance" on save success cannot be validated — the Calculators tab is a placeholder (see 2.1.4).
- **Next:** wire BMI, fix the edit-mode-on-error bug, add the error dialog, add edit-time validation parity with Create Patient.

#### 2.1.4. Patient Details - Tabs

**Status:** Incomplete 🟣

**Description:**

##### Implementation Notes — per tab (validated against code, 2026-09-06)

| Tab | Status | Notes |
| --- | ------ | ----- |
| Calculators | Not started 🔵 | `DsPlaceholder()` only (`patient_details_page.dart`). No calculator relevance logic, no bottom sheet, no per-calculation tables exist yet (see DB schema gap below). |
| Weights | Implementing 🟡 | Save works (value + auto `DateTime.now()`), curve icon (asc/desc) and empty-state message implemented. Missing: date/time input field (spec requires an optional, defaults-to-now, non-future date/time picker — currently hardcoded to `now()`), "weight type" display, delete-on-swipe (`Dismissible` is commented out in `measurements_list.dart`), disabled-while-required-fields-empty rule not verified against `MeasurementInputField`. **Bug (architecture review, 2026-09-06):** `PatientDetailsCubit.saveWeight`/`saveHeight` call the create use case without awaiting/checking the `Result` and without re-fetching weights/heights or clearing the form afterwards — the spec's "on save success: fields cleared, list updated, BMI updated" cannot work as written until this is fixed. |
| Heights | Implementing 🟡 | Same gaps as Weights (shares `PatientMeasurementsTab`/`MeasurementsList`), including the `saveHeight` Result-handling bug above. |
| Body Measurements | Implementing 🟡 | Accordion grouping by type, collapsed-by-default, curve icons and empty-state implemented (`patient_body_measurements_tab.dart`). **Known bug, flagged in code:** `saveNewBodyMeasurement` has a `// TODO - nao ta salvando ainda (erro)` comment in `patient_details_cubit.dart` — save is not reliably working. Missing: date/time field, delete-on-swipe with confirmation dialog, curve recompute after deletion (all per spec). |
| History | Not started 🔵 | `DsPlaceholder()` only. **Hard dependency, not parallel work:** History only displays Calculators' output, so it has nothing to show until the Calculators tab exists — Calculators must ship first, not be scheduled alongside it. |

- **Empty-state copy mismatch vs. spec:** Weights/Heights show `"Não encontramos pesos/alturas para esse paciente."` (spec: `"Nenhum peso cadastrado"`); Body Measurements shows `"Nenhuma medida encontrada para esse paciente."` (spec: `"Sem medidas cadastradas para esse paciente ainda"`). Implementation deviated from the documented copy — not editing the requirement text since the deviation looks unintentional (dev tech debt), not a documented decision.
- **Missing design-system primitive:** no `DsBottomSheet` widget exists under `lib/shared/design_system/widgets/` and no `showModalBottomSheet` usage exists anywhere in the codebase. Both Calculators ("tap a calculator → bottom sheet to insert data") and History ("tap a result → bottom sheet with parameters and result") depend on this component — needs to be designed/built before either tab's core interaction can be implemented.

##### Calculators

**Name:** Calculadoras

**Description:** Based on the patient's data, shows the most relevant calculators (see [Calculator Relevance](#calculator-relevance)). At the end of the list, should show a button "See All Calculators". The list should expand and show all available calculators.

**Functional Requirements:**

- When tapping the "See All Calculators" button, the list should show the calculators divided by type (see [All calculators](#all-calculators)).
- The "See all" button should become "See Relevant Only" after being tapped.
- When tapping a calculator, should open bottom sheet to insert data.
- When calculating weight, there should be a checkbox to indicate if the dietitian wants to use that weight for calculation.
    - For example, the patient could have a very recent real weight (measured by a scale), but the dietitian calculated the adjusted weight at the moment. If they don't want to use the adjusted weight, but the scale weight, they should be able to.
    - If a weight is not considered for calculation, the previous allowed weight will be considered.
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

**DB schema gap (checked against `lib/core/services/database/app_database_tables.dart`, 2026-09-06):** only `PATIENT`, `WEIGHTS`, `HEIGHTS` and `BODY_MEASUREMENTS` exist today. None of `BMI`, `ENERGY_EXPENDITURES`, `ENTERAL_NUTRITIONS_DRIPPING/SPEED/VOLUME`, `GLUCOSE_INFUSION_RATES`, `NITROGEN_BALANCES`, `PROTEIN_NEEDS`, the per-screening tables, `WATER_NEEDS` or `WEIGHT_LOSS_CLASSIFICATIONS` exist yet — expected, since the Calculators tab itself is unbuilt (see notes above). `WEIGHTS` also does not yet have the "consider for calculations" / "weight type" columns this section calls for — it currently only has `id, value, createdAt, patientId` (shared with `HEIGHTS` via `_baseMeasurementTableFields`). No DB migration mechanism exists in `AppDatabaseService` yet — see [priority 1](#1-roadmap-prioritization); this blocks the `WEIGHTS` column addition and every new table below.

**ADRs needed before implementation (architecture review, 2026-09-06):**
- **DB migration strategy** — how schema changes to already-created tables (sqflite `onUpgrade` + version counter, or an additive "add column if missing" helper) get applied on devices that installed an earlier schema. Blocks the `WEIGHTS` columns above and this entire table list. Same underlying gap as [priority 1](#1-roadmap-prioritization) and the Create Patient `PATIENT`-table gap in [2.1.1](#211-create-patient) — one tech-debt item, not two.
- **Screening storage granularity** — one table per screening tool (`SCREENING_MST`, `SCREENING_STRONG_KIDS`, `SCREENING_MUST`, `SCREENING_NRS_2002`, future `SCREENING_ASG`) as currently documented above, vs. a single `SCREENINGS` table with a `type` discriminant column + a JSON-in-TEXT `answers` blob. No existing precedent for either approach in this codebase (`TableSqlTypes` has no JSON/blob convention today) — needs a decision since it sets the pattern for all 5 screening tools.

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

##### Heights

- Same as weights, but for heights.

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

- **BMI:** Calculates patient BMI. Available for all ages (from 19+).

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
| BMI | Always Relevant |
| Energy Expenditure | Age, Confined to bed, Hospitalized |
| Enteral/Parenteral Nutrition | Patient uses parenteral/enteral nutrition |
| Nitrogen Balance | Hospitalized, Parenteral/Enteral nutrition, Confined to bed |
| Protein Needs | Always Relevant |
| Weight - Adequation/Adjusted/Ideal | Obesity/Underweight BMI |
| Weight - Adjusted (Dry weight) | Hospitalized, Confined to bed |
| Weight - Estimated | Hospitalized, Confined to bed |
| Weight Loss Classification | If the patient's 2 last weights form a desc curve (there was weight loss) |
| Screening | Age, Hospitalized, Confined to bed |

### 3.2. Implementation Statuses

| Status | Description |
| ------ | ----------- |
| Ready for Dev 🔵 | Still not implemented. On the line to be implemented. |
| Implementing 🟡 | On the way. |
| Incomplete 🟣 | Works fine, but still has some things to be implemented. |
| Reprioritized 🚫 | If next in line to be implemented, will be skipped until it is marked as Ready for Dev. |
| Implemented ✅ | Implemented and validated. |
| Awaiting validation 🧪 | Implemented, but still need to be tested and validated. |
