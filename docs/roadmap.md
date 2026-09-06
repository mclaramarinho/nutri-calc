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
| 1 | Validate this roadmap | Look for inconsistencies, gaps, improvement opportunities, etc. |
| 2 | Validate what was implemented | Validate what was implemented, using this file as a source of truth. What was discovered should be registered on the specific topic of this file. For example: Create patient (feature) has XYZ implemented, but is missing ABC. This info should be registered on a table in the feature section. |
| 3 | Implement what is missing for existing features | Adjust what is not correct in the existing features and implement what is missing for each one of them. |
| 4 | Implement new features | Implement the remaining non-existing features. |
| 5 | Create Design System for the app | Work like a senior designer and: 1) identify and understand the target-user profile, their possible preferences and what is the best UX/UI for them; 2) determine color palette, spacings, etc. tokens for the app; 3) update widgets and screens to follow new Design System directives. |
| 6 | Refactor | Go through the database and find code gaps, such as code repetition, widgets that should be design system reusable components, etc. |
| 7 | Create Dark Mode | Create dark mode for app. |

---

## 2. Features

Describes the features and their current implementation status.

### 2.1. Patient

#### 2.1.1. Create Patient

**Status:** Incomplete 🟣

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

#### 2.1.2. List Patients

**Status:** Awaiting validation 🧪

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

#### 2.1.4. Patient Details - Tabs

**Status:** Incomplete 🟣

**Description:**

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
