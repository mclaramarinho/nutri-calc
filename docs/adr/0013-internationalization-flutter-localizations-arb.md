# 0013. Internationalization mechanism: `flutter_localizations` + ARB + generated `AppLocalizations`

**Status:** Accepted
**Date:** 2026-10-01
**Feature:** docs/roadmap.md priority 11 (Internationalization), scoped by `po` 2026-10-01

## Context

`po` scoped this slice to ship the i18n **mechanism** only, with `pt_BR` as the sole fully-translated locale, retrofitted into a representative sample of screens (see roadmap row for the file list) rather than the whole app. Two mechanism questions needed resolving before `mobile-dev` could start:

1. **Which i18n mechanism fits this codebase?** `pubspec.yaml` has no `intl`/`flutter_localizations`/`generate: true` today — this is a from-scratch decision, not a migration of an existing (possibly custom) mechanism.
2. **Where do translatable strings live when the string doesn't originate in a widget's `build(BuildContext)`?** `CLAUDE.md` documents cubits as `BuildContext`-free (`AppRouter.context` exists specifically to give cubits context-free access to routing). A call-site audit (mirroring ADR 0012's dark-mode audit) found this is not hypothetical: `PatientDetailsCubit._saveCalculation` (`lib/features/patients/details/presentation/cubit/patient_details_cubit.dart`) hardcodes Portuguese `successMessage`/`errorFallbackMessage` strings for all 14 calculator-save flows, which `patient_details_page.dart` (in the retrofit sample) later displays verbatim via `status.savedMessage!`/`status.errorMessage!` (`CalculatorSaveStatusSaved`/`Error.message`, `lib/features/calculators/domain/entities/calculator_save_status.dart`). Likewise, `PatientHistoryTab` displays `entry.label`, `entry.resultSummary`, `param.label` — all domain/entity-sourced strings, not widget literals.

### Call-site audit (performed before deciding, mirroring ADR 0012 §"Call-site audit")

Every hardcoded Portuguese string literal actually authored **inside** the 11 retrofit-sample files is inside a `Widget build(BuildContext context)` (or a private method called from one, with `context` in scope) — confirmed for `home_page.dart`, `list_patients_page.dart`, `new_patient_page.dart`, `patient_details_form.dart`, `patient_details_page.dart`, the 4 tab widgets, and the 3 representative calculator sheet bodies (`bmi`'s equivalent is actually inline in `patient_calculators_tab.dart`'s `_openBmiBottomSheet` — see Alternatives/flag below — `energy_expenditure_sheet_body.dart`, `nrs_2002_sheet_body.dart`). **No in-scope literal requires a `BuildContext`-free sourcing strategy.**

The two cases that *do* originate outside a widget (`CalculatorSaveStatus.message` from the cubit; `HistoryEntryEntity`/`InputParamEntity` labels from calculator save use cases) are **pre-existing, already-deferred tech debt** — the same category `po` already called out for `inputParams.label` (explicitly out of scope, item 3 of the roadmap row). This ADR extends that same deferral to `CalculatorSaveStatus.message`, since it's architecturally identical (a domain/cubit-owned string flowing untouched through a presentation display site) and resolving it would require either (a) threading `AppLocalizations` into cubits — breaking the `BuildContext`-free cubit convention `CLAUDE.md`/ADR 0012 rely on — or (b) moving message construction into the presentation layer for all 14 calculators, which is strictly larger than "retrofit a representative sample."

## Decision

### 1. Mechanism: `flutter_localizations` (SDK) + `intl` + ARB files + Flutter's built-in `gen-l10n` codegen, non-synthetic output

This is Flutter's own first-party, zero-extra-dependency-maintenance mechanism (ships with the SDK), the ecosystem standard, and composes cleanly with the existing stack:

- No conflict with `injectable`/`get_it`: `AppLocalizations.of(context)` is a `BuildContext` accessor, not a singleton/service — nothing to register in `di.config.dart`.
- No conflict with `go_router`: `MaterialApp.router`'s `localizationsDelegates`/`supportedLocales` params exist independently of `routerConfig`.
- No conflict with `DsScaffold`/design system: DS widgets take `String` labels today and keep doing so — call sites just source the `String` from `AppLocalizations.of(context)!.key` instead of a literal, identical shape to the ADR 0012 `DsColors.of(context)` retrofit pattern.
- Rejected a custom/home-grown solution (e.g. a hand-rolled `Map<String, Map<String,String>>` + `Localizations`-like lookup) — no feature of this app's requirements (ICU plurals for calculator result counts, RTL, pluralization rules for a future locale) needs anything ARB doesn't already give for free, and a custom mechanism is pure reinvention with no architectural benefit over the SDK's own.

### 2. ARB file location and config

```
lib/l10n/app_pt.arb      # template/default locale, pt_BR, source of truth for keys
```

`l10n.yaml` (repo root, alongside `pubspec.yaml`):

```yaml
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
synthetic-package: false
nullable-getter: false
```

`synthetic-package: false` + explicit `output-dir` is the deliberate, current (non-deprecated) Flutter mechanism — avoids depending on the old `package:flutter_gen` synthetic package path, which newer Flutter tooling has moved away from. Generated files land in `lib/l10n/generated/` (gitignored, like `di.config.dart` and `*.g.dart`, regenerated by `flutter gen-l10n` — folded into the existing `dart run build_runner build`/`./scripts/build.sh` one-off step documented in `CLAUDE.md`, since `flutter pub get` already triggers `gen-l10n` automatically when `generate: true` is set).

`pubspec.yaml` additions:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: <version compatible with the pinned flutter_localizations — resolve via `flutter pub add intl`, do not hand-pick a version>

flutter:
  generate: true
```

### 3. Key-naming convention: flat lowerCamelCase, feature/screen-prefixed

ARB keys cannot be nested, so a flat convention is mandatory. Adopted: `<screenOrFeature><Element>`, lowerCamelCase, no abbreviated screen prefixes beyond what's already unambiguous — e.g. `homeTabHome`, `patientListEmptyState`, `patientListLoadErrorMessage`, `newPatientTitle`, `newPatientFirstNameLabel`, `patientDetailsTitle`, `patientDetailsClinicalInfoSectionTitle`, `bmiScreeningTitle` (n/a here since BMI has no literal strings of its own — see flag below), `energyExpenditureConfigureTitle`, `nrs2002Title`. Every key gets an ARB `@key` metadata block with a `description` (required for translator context once a second locale is ever added) — e.g.:

```json
{
  "patientListEmptyState": "Você ainda não tem pacientes cadastrados",
  "@patientListEmptyState": {
    "description": "Shown in the patient list when there are no patients yet"
  }
}
```

### 4. ICU placeholders for interpolated strings

Several in-scope strings interpolate values and must use ICU placeholders, not raw `${}` Dart interpolation baked into the ARB value. Confirmed interpolated strings in the retrofit sample include (non-exhaustive, `mobile-dev` must re-grep each file before final key list):

- `list_patients_page.dart`: `"${patient.firstName} ${patient.lastName}"` (two placeholders), `"${patient.age} ${patient.ageUnit!.value.toLowerCase()}"`.
- `energy_expenditure_sheet_body.dart`: `"Peso: ${widget.weightKg} kg"`, `"Altura: ${widget.heightCm} cm"`, `"Idade: ${widget.age}"`, `"Gasto Energético: ${_rangeLabel(...)}"`, `"Fórmula: ${_formula!.label}"`, etc. — note `.label` values (enum display strings) are themselves out-of-scope deferred domain strings; only the Portuguese scaffolding text (`"Peso: "`, `"Altura: "`...) is in scope, so these become e.g. `energyExpenditureWeightLabel` with a `{weightKg}` placeholder, the enum `.label` value passed in as the placeholder argument untranslated.
- `nrs_2002_sheet_body.dart`: `"Idade: ${widget.age}"`, `"NRS-2002: ${_result!.score}"`.
- `patient_measurements_tab.dart`: `"Não encontramos ${isWeight ? 'pesos' : 'alturas'} para esse paciente."` — this is a ternary-selected noun, not a count; model as two separate full keys (`patientMeasurementsNoWeightsFound`, `patientMeasurementsNoHeightsFound`) rather than forcing an ICU `select` for a 2-way UI-only branch, consistent with keeping ARB usage mechanical/boring per `po`'s "mechanism only" framing.

No plural (ICU `plural`) cases were found in the retrofit sample — all counts shown (scores, ages) are single numeric placeholders (`{age}`, `{score}`), not count-driven noun pluralization, so `other`/`one` ICU plural forms are not needed for this slice. Document this as deliberately unexercised but supported (the mechanism itself supports plurals for whenever a future string needs them).

### 5. `MaterialApp.router` wiring (`lib/main.dart`)

```dart
return MaterialApp.router(
  routerConfig: getIt.get<AppRouter>().router,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales, // == [Locale('pt', 'BR')] for this slice
  theme: ...,
  darkTheme: ...,
  themeMode: themeMode,
);
```

`AppLocalizations.supportedLocales` is generated directly from the ARB files present in `lib/l10n/` — adding a second locale later means adding `app_<locale>.arb` with the same keys translated, **zero code changes** to `main.dart` or any call site, satisfying `po`'s "structured so a second locale can be added later" requirement.

### 6. Retrofit mechanics for the representative sample

Each hardcoded `"..."` literal in the 11 in-scope files becomes `AppLocalizations.of(context)!.someKey` (interpolated ones: `AppLocalizations.of(context)!.someKey(arg1, arg2)`, matching the generated method signature `gen-l10n` produces for ICU-placeholder keys). Since every in-scope call site already executes inside `build(BuildContext context)` or a method receiving `context`, this is a mechanical rewrite with no per-file judgment calls — same shape as ADR 0012's `DsColors.of(context)` retrofit.

**Flag for `po`: the "bmi" representative calculator sheet body named in the roadmap row doesn't exist as a separate file.** `grep`-confirmed: there is no `lib/features/calculators/bmi/presentation/widgets/bmi_sheet_body.dart` (BMI has no `presentation/` folder at all — its UI lives inline in `patient_calculators_tab.dart`'s `_openBmiBottomSheet` method, already a separate in-scope file). **Resolution applied (not blocking):** BMI's "sheet body" strings (`"IMC"` dialog title, `"Não há dados suficientes para calcular o IMC..."`, `"IMC: ${bmi.value...} (...)"` ) are retrofitted as part of `patient_calculators_tab.dart`'s existing in-scope coverage — no new file is added, and the 3-calculator "spanning different input shapes" intent is still met (BMI's numeric/derived-value shape is covered via this method; `energy_expenditure` and `nrs_2002` cover the formula-selection and questionnaire shapes). This does not change the file list `mobile-dev` touches, just clarifies that "the bmi sheet body" maps to a method inside an already-listed file rather than a dedicated file.

### 7. Deferred (NOT in scope, confirmed no touch)

- `inputParams.label` (calculator save use cases) — per `po`, item 3. No calculator `domain/`/`use_cases/`/persistence file is touched.
- `CalculatorSaveStatus.message` (all 14 `successMessage`/`errorFallbackMessage` literals in `patient_details_cubit.dart`) — newly identified in this pass, extending the same deferral category as `inputParams.label` for the reason in Context above (cubit `BuildContext`-free constraint). `patient_details_page.dart` itself still gets retrofitted for its **own** literals (dialog titles `"Erro ao salvar"`/`"Sucesso"`, `DsAppBarData.title`, tab labels, the static fallback message `"Não foi possível salvar as alterações. Tente novamente."`) — only the dynamic `status.errorMessage!`/`status.savedMessage!` values passed through verbatim from the cubit stay Portuguese.
- `HistoryEntryEntity.label`/`.resultSummary`, `InputParamEntity.label`, any `enum.label` getter (`CalculatorType.label`, `BodyMeasurementTypeEnum.label`, `ActivityFactor.label`, etc.) — all domain-entity/enum-sourced, same deferred category.
- Generic exception-derived messages (e.g. `NewPatientStateError.message`, which can carry a raw `Result.Error` string from a repository catch block) — these are not fixed translatable strings and are out of scope; flagged as existing tech debt (not newly created by this slice).
- Any file outside the 11 named in `po`'s roadmap row — tracked via the migrated/not-yet-migrated checklist `mobile-dev` must add to the roadmap per `po`'s instruction.

### 8. `CLAUDE.md` update (ship-time, `mobile-dev`'s job per `po` item 4)

Replace the current line:

> **UI copy is in Portuguese** (validation messages, labels, screen text) — match that when adding user-facing strings.

With something reflecting the new reality, e.g.:

> **UI copy is sourced from `AppLocalizations`** (`lib/l10n/*.arb`, generated via `flutter gen-l10n`/`flutter pub get`) in retrofitted screens — see `docs/roadmap.md` priority 11 for the migrated/not-yet-migrated checklist. `pt_BR` (`lib/l10n/app_pt.arb`) is the only shipped translation; not-yet-migrated screens still have hardcoded Portuguese literals matching `pt_BR`'s copy — match the existing convention (tone, formality) in either case. New translatable strings in a migrated screen go through a new ARB key (flat lowerCamelCase, `@key` description required); new strings in a not-yet-migrated screen may stay a hardcoded Portuguese literal consistent with the surrounding file until that file is migrated.

## Consequences

- Adds two new `pubspec.yaml` dependencies (`flutter_localizations` from the SDK — no version/maintenance burden; `intl`, version pinned to whatever `flutter pub add intl` resolves against the current `flutter_localizations` SDK constraint) and one new generated-code family (`lib/l10n/generated/`, gitignored, regenerated by the existing `build_runner`/`./scripts/build.sh` workflow — `flutter gen-l10n` runs automatically on `flutter pub get` once `generate: true` is set, and can also be invoked standalone).
- 11 files get a mechanical per-literal rewrite (`"..."` → `AppLocalizations.of(context)!.key`), each needing a `context` import of nothing new (already imported) — `BuildContext` already in scope everywhere per the audit above, so there are zero cases needing a sourcing workaround (no `AppRouter.context` reach-around needed for in-scope strings).
- Establishes a durable precedent: any future screen retrofit (the other ~90+ hardcoded-Portuguese files tracked as tech debt) follows the exact same `AppLocalizations.of(context)!.key` pattern — no new architecture decision needed for future slices, only the mechanical work.
- Two categories of pre-existing hardcoded-Portuguese-in-non-presentation-layer strings are now explicitly tracked as tech debt rather than silently resolved or silently ignored: `inputParams.label` (already known) and `CalculatorSaveStatus.message` (newly surfaced here) — both need their own follow-up decision (likely: route calculator-save message construction through `AppLocalizations` via `AppRouter.context`, or restructure `CalculatorSaveStatus` to carry a translatable key + args instead of a resolved `String`, deferred to whenever that follow-up slice is scoped).
- The "bmi representative sheet body" roadmap item is satisfied via `patient_calculators_tab.dart`'s inline method rather than a dedicated file — flagged to `po` so the roadmap's retrofit-sample description can be corrected for future readers (no action needed from `mobile-dev` beyond what's already in the file list).
- Several interpolated strings need their Dart `${}` interpolation rewritten as ICU placeholders in the ARB value + generated method call — slightly more rewrite surface per string than a literal swap, but mechanical once the key is defined.

## Alternatives considered

- **Custom lightweight i18n (hand-rolled lookup map + `InheritedWidget`), avoiding `flutter_localizations`/ARB/codegen entirely.** Rejected: `flutter_localizations` + ARB is the Flutter-ecosystem standard, ships in the SDK (no extra pub.dev dependency-maintenance risk beyond `intl`, which the SDK already requires for `flutter_localizations` to work), and already provides ICU plural/placeholder support a custom map would have to reinvent for zero benefit — there is no requirement here a custom mechanism solves better.
- **Use `easy_localization` or a similar third-party i18n package instead of the SDK mechanism.** Rejected: adds an extra pub.dev dependency and a different (JSON-based, non-ARB) convention for no capability this app needs beyond what `flutter_localizations` already provides; `CLAUDE.md`'s existing dependency list favors well-known, minimal, purpose-fit packages (ADR 0012's `shared_preferences` precedent) — the SDK's own first-party mechanism is the more minimal choice here, not a third-party one.
- **Retrofit `CalculatorSaveStatus.message` now, by threading `AppLocalizations` access into `PatientDetailsCubit` via `AppRouter.context`.** Considered, rejected for this slice: `AppRouter.context` exists for navigation, and reusing it to source translated strings from inside a cubit would blur the `BuildContext`-free cubit convention `CLAUDE.md` documents and ADR 0012's audit relied on — a precedent-setting architectural change that affects all 14 calculator-save flows, not a "representative sample" retrofit. Deferred as tech debt instead, consistent with `inputParams.label`'s existing deferral.
- **Widen the retrofit sample to include `patient_details_cubit.dart` so `CalculatorSaveStatus.message` could be covered.** Rejected: `po` explicitly bounded the retrofit sample to 11 named files; unilaterally expanding scope mid-analysis is exactly the kind of call `po` owns, not `senior-analyst` — flagged in this ADR and the handback report instead of silently expanding scope.
