# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                                    # install deps
dart run build_runner build --delete-conflicting-outputs           # regenerate *.g.dart, di.config.dart (one-off)
dart run build_runner watch --delete-conflicting-outputs           # same, in watch mode
./scripts/build.sh [watch]                                         # clean + pub get + build_runner (build.sh watch for watch mode)

flutter test                                                       # run all tests
flutter test test/patient_measurements_tab_test.dart               # run a single test file
flutter test --plain-name "ListView separators do not use Expanded" # run a single test by name

flutter run -d <deviceId>                                          # run the app (flutter devices lists ids)
flutter analyze                                                    # lint (flutter_lints via analysis_options.yaml)
```

Code generation (`build_runner`) is required after changing any `@JsonSerializable` model, `@Injectable`/`@Singleton` class, or the `AppDatabaseService`'s dependents — it regenerates `*.g.dart` files and `lib/di/di.config.dart`. These generated files are gitignored; a fresh checkout won't build/run until generation has been run once.

To drive/screenshot the running app programmatically (not just run its tests), use the `run-nutri-calc` skill (`.claude/skills/run-nutri-calc/`).

## Architecture

**Feature-based, layered.** Each feature under `lib/features/<feature>/` (and nested sub-features like `patients/new`, `patients/details`, `measurements/weight`) follows the same three-layer split:

- `domain/` — `entities/` (plain data classes), `repositories/` (abstract interface), `use_cases/` (abstract interface + `*Impl` calling the repository). Use cases are the only thing cubits call.
- `data/` — `models/` (JSON-serializable, usually extend/wrap the domain entity — `*_model.dart` + generated `*_model.g.dart`), `repositories/` (`*RepositoryImpl` implementing the domain interface, talking to `AppDatabaseService`).
- `presentation/` — `cubit/` (`flutter_bloc` `Cubit` + a sealed/union `*State`), `pages/`, `widgets/`.

Every interface (`Repository`, `UseCase`) is bound to its impl via `injectable` annotations (`@Injectable(as: X)` / `@Singleton(as: X)`), collected into `lib/di/di.config.dart` by build_runner, and resolved through the global `getIt` (`lib/di/di.dart`). Cubits are typically `@injectable` themselves and constructor-inject their use cases.

**Error handling:** almost everything returns `Result<T, E>` (`lib/core/utils/result/result.dart`) instead of throwing — `Ok`/`Error` with a `.when(ok:, error:)` or `.isError`/`.isOk` check. Repository and use-case methods wrap their body in try/catch and convert exceptions to `Error(err.toString())`. Follow this pattern for new repositories/use cases rather than throwing.

**Persistence:** a single `AppDatabaseService` (`lib/core/services/database/app_database_service.dart`, sqflite-backed, `@Singleton`) exposes generic `read`/`insert`/`update`/`delete` against `AppDatabaseTables` (`lib/core/services/database/app_database_tables.dart`), which is also where each table's SQL schema is declared (`TableSqlField`/`TableSqlType`/`TableSqlConstraint` entities in `entities/`). Repositories call this service with `AppDatabaseTables.<table>` rather than owning their own SQL. Adding a new persisted entity means adding a case to `AppDatabaseTables` plus a matching model with `toJson()`.

**Routing:** `go_router`, but routes are enumerated once as `AppRoutes` (`lib/routing/app_routes.dart`, an enum of `{page, path}` pairs), and all navigation goes through the injectable `AppRouter` interface (`lib/routing/app_router.dart`, `push`/`pop`/`replace`/`currentRoute`) rather than calling `GoRouter`/`context.go` directly. `AppRouter.context` gives BuildContext-less access to the current route from cubits.

**Domain calculators:** `lib/shared/services/calculator/` holds the actual nutrition/anthropometry math (BMI, energy expenditure — Harris-Benedict/Mifflin/Schofield/WHO/pocket formulas, protein needs, nitrogen balance, enteral/parenteral nutrition, water needs, weight adequacy/loss/ideal/adjusted/estimated, screening tools MUST/NRS-2002/STRONG-KIDS). These are plain synchronous `Result`-returning classes (not injected, not use cases in the DI sense) under `domain/use_cases/<topic>/`, with matching `domain/entities/<topic>/`. Classification thresholds are typically documented in a comment block above the class (see `calculate_bmi.usecase.dart`) — keep that convention for new calculators, since it's the only place the source formula/reference values live.

**Design system:** all UI widgets you'd otherwise reach for from `package:flutter/material.dart` should go through `lib/shared/design_system/widgets/ds_*/` (`DsScaffold`, `DsAppBar`, `DsBottomNav`, `DsFab`, `DsTextfield`, `DsButton`, `DsDialog`, `DsSelect`, `DsTabView`, `DsPlaceholder`) instead of raw Material widgets, using tokens from `lib/shared/design_system/tokens/` (`ds_colors`, `ds_spacing`, `ds_radius`, `ds_sizing`, `ds_typography`) and the `ds_screen_adapter`/`ext_num_screen_adapter` scaling extensions. `DsScaffold` composes app bar + FAB + bottom nav from data objects (`DsAppBarData`, `DsFabData`, `DsBottomNavData`) rather than slots.

**UI copy is in Portuguese** (validation messages, labels, screen text) — match that when adding user-facing strings.

**Shared cross-feature code** lives under `lib/shared/utils/` (enums like `Gender`, `Ethnicity`, `PatientState`, `TimeUnit`; `AgeEntity` + `ext_age.dart`; formatters/validators) vs. `lib/core/` which is app infra (database, DI, generic result/formatting/extension utilities) — `shared` is domain-ish reusable code, `core` is infrastructure.
