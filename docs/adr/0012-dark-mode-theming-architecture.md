# 0012. Dark mode theming architecture

**Status:** Accepted
**Date:** 2026-10-01
**Feature:** docs/roadmap.md priority 10 (Dark Mode); PO scoping + senior-designer palette/entry-point decisions in `docs/design/design-conventions.md`'s "Priority 10 — Dark Mode" section

## Context

PO and senior-designer stages are complete (see `docs/design/design-conventions.md`, line ~555 onward): manual tri-state `ThemeMode` toggle (Light/Dark/Follow system, default `.system`, persisted across restarts), a dark palette for all 7 `DsColors` tokens, and an entry point (`DsAppBarData.onThemeToggle`, wired on Home only, opening a `DsBottomSheet` with 3 `DsListTile` rows). Three architecture questions were explicitly left open for this analysis pass:

1. How do `DsColors`' 7 static `Color` getters (`lib/shared/design_system/tokens/ds_colors.dart`) become theme-aware, and what does that cost at call sites?
2. How does the tri-state preference persist across restarts, given no `shared_preferences`-equivalent dependency exists today (confirmed: `pubspec.yaml` has no key-value persistence package, only `sqflite` via `AppDatabaseService`)?
3. How do existing widget tests that assert `DsColors` values or pump DS widgets without a themed ancestor keep passing once tokens are theme-dependent?

### Call-site audit (performed before deciding)

`grep -rln "DsColors\." lib/` and `grep -rn "DsTextStyles\."` were checked file-by-file for `BuildContext` availability at the call site. Result: **every single call site has `BuildContext` already in scope** — no exceptions found:

- ~16 calculator `*_sheet_body.dart` files: all read `DsColors.error` inside `Widget build(BuildContext context)` of a `State`/`StatefulWidget`.
- All DS widgets (`ds_button.dart`, `ds_checkbox.dart`, `ds_bottom_nav.dart`, `ds_dialog.dart`, `ds_bottom_sheet.dart`, `ds_dismissible_tile.dart`, `ds_fab.dart`, `ds_list_tile.dart`, `ds_loading_indicator.dart`, `ds_date_time_picker.dart`): all inside `build(BuildContext context)`.
- `DsDialog.show` / `DsBottomSheet.show`: static methods, but both already take `BuildContext context` as their first parameter.
- Feature pages (`list_patients_page.dart`, `new_patient_page.dart`, `patient_details_form.dart`, `measurements_list.dart`): all inside `build(BuildContext context)`.
- `DsTextStyles` (`ds_text_styles.dart`, 2 static `TextStyle` getters deriving from `DsColors.black`): its 4 call sites (`patient_calculators_tab.dart`, `nitrogen_balance_sheet_body.dart` x2, `calculator_list.dart`) are also all inside `build(BuildContext context)`.

**No call site exists in a non-widget class, static helper, or anywhere without `BuildContext` in scope.** The PO/senior-designer's flagged risk ("some may not have straightforward context access") does not materialize — the blast radius is real (~30 files) but entirely mechanical.

## Decision

### 1. `DsColors` mechanism: `ThemeExtension<DsColors>` read via `Theme.of(context)`, with a `DsColors.of(context)` static accessor

`DsColors` changes from a class of static `Color` getters to a `ThemeExtension<DsColors>` holding the 5 independent tokens as instance fields (`white`, `blue`, `black`, `gray`, `error`), plus `textDisabled`/`textMuted` as instance getters still derived from `black` (preserving the existing alpha-derivation convention the senior-designer's palette table relies on — `black` resolves to its theme-correct value first, then the 0.38/0.54 formulas apply unchanged in both themes).

```dart
// lib/shared/design_system/tokens/ds_colors.dart
class DsColors extends ThemeExtension<DsColors> {
  final Color white;
  final Color blue;
  final Color black;
  final Color gray;
  final Color error;

  const DsColors({
    required this.white,
    required this.blue,
    required this.black,
    required this.gray,
    required this.error,
  });

  Color get textDisabled => black.withValues(alpha: 0.38);
  Color get textMuted => black.withValues(alpha: 0.54);

  static const light = DsColors(
    white: Colors.white,
    blue: Colors.blue,
    black: Colors.black,
    gray: Color(0xFFEEEEEE), // Colors.grey.shade200
    error: Colors.red,
  );

  static const dark = DsColors(
    white: Color(0xFF1E1E1E),
    blue: Color(0xFF64B5F6),
    black: Color(0xFFECECEC),
    gray: Color(0xFF424242),
    error: Color(0xFFCF6679),
  );

  static DsColors of(BuildContext context) =>
      Theme.of(context).extension<DsColors>() ?? light;

  @override
  DsColors copyWith({Color? white, Color? blue, Color? black, Color? gray, Color? error}) =>
      DsColors(
        white: white ?? this.white,
        blue: blue ?? this.blue,
        black: black ?? this.black,
        gray: gray ?? this.gray,
        error: error ?? this.error,
      );

  @override
  DsColors lerp(ThemeExtension<DsColors>? other, double t) {
    if (other is! DsColors) return this;
    return DsColors(
      white: Color.lerp(white, other.white, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      black: Color.lerp(black, other.black, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
```

**Call-site API becomes `DsColors.of(context).white` (not `DsColors.white`).** The static-looking call site cannot survive — a static getter structurally cannot resolve `Theme.of(context)` without a `context` parameter somewhere. Since the audit confirms every call site already has `context` in scope, this is a mechanical rename, not a redesign: `DsColors\.(\w+)` → `DsColors.of(context).$1` across the ~30 files listed above. `DsTextStyles`'s 2 getters become methods taking `context` (`DsTextStyles.sectionHeader(context)`), for the same reason — they're derived from `DsColors.black`.

`main.dart` wires both tokens sets as `ThemeData.extensions`:

```dart
theme: ThemeData(brightness: Brightness.light, extensions: const [DsColors.light]),
darkTheme: ThemeData(brightness: Brightness.dark, extensions: const [DsColors.dark]),
themeMode: <from ThemeCubit, see decision 2>,
```

### 2. Persistence: new `shared_preferences` dependency, wrapped in a dedicated `lib/features/theme/` feature (not `AppDatabaseService`/`AppDatabaseTables`)

Add `shared_preferences` to `pubspec.yaml`. Model the preference as a brand-new, full-layered feature `lib/features/theme/` (domain/data/presentation, per `CLAUDE.md`'s standard shape) rather than bolting it onto `core/` or `AppDatabaseService`.

### 3. Test harness: `pumpWidgetWithTheme` helper + update the one existing color-asserting test

Add a shared test helper and migrate `ds_loading_indicator_test.dart` to use it in both brightnesses (see Consequences / implementation plan for the exact helper and updated assertions).

### 4. `DsAppBarData`/`DsAppBar` changes (per senior-designer, included here for completeness since `main.dart`'s theming and this are delivered together)

`DsAppBarData` gains `final VoidCallback? onThemeToggle` (default `null`). `DsAppBar.build` gains the toggle icon (`Icons.brightness_6`, placed before the close icon) and a null-guard fix for the close icon, which today renders unconditionally even when `data.onClose` is null:

```dart
actions: [
  if (data.onThemeToggle != null)
    Icon(Icons.brightness_6).touchEvents(onTap: data.onThemeToggle),
  if (data.onClose != null)
    Icon(Icons.close).touchEvents(onTap: () => data.onClose?.call()),
],
```

## Consequences

- `DsColors`/`DsTextStyles` become genuinely theme-aware with zero raw/unthemed Material colors surviving — satisfies PO's acceptance criterion 4 (`design-conventions.md` line 572).
- ~30 `lib/` files need their `DsColors.`/`DsTextStyles.` call sites mechanically rewritten to `DsColors.of(context).`/`DsTextStyles.x(context)`. This is a real, sizeable retrofit but a pure find-and-replace with no per-file judgment calls, since context is confirmed available everywhere.
- `DsColors.of(context)` correctly participates in Flutter's `InheritedWidget` dependency tracking: any widget reading it in `build()` is automatically rebuilt when `Theme.of(context)` changes (e.g. the user flips the toggle), which is required by PO's "updates the live `MaterialApp` immediately (no restart required)" criterion — this falls out of the mechanism for free, no manual `ValueListenableBuilder`/`setState` wiring needed per call site.
- A new `shared_preferences` dependency enters `pubspec.yaml`; `lib/core/` stays free of a one-off settings table, and `AppDatabaseTables`/migrations (ADR 0001) stay scoped to actual clinical/domain data, matching the task brief's explicit scope boundary ("no persistence-of-domain-data touched").
- `lib/features/theme/` becomes a precedent for any future pure-UI-preference feature (e.g. a units-of-measure toggle): small `shared_preferences`-backed repository + cubit, no `AppDatabaseTables` entry, no use-case indirection beyond the two trivial ones added here for stylistic consistency with `CLAUDE.md`'s "cubits only call use cases" rule.
- `DsLoadingIndicator`'s test (the only one asserting a literal `DsColors` value) needs a themed ancestor and now asserts both brightnesses explicitly, rather than one brightness-agnostic assumption. The reusable `pumpWidgetWithTheme` helper lowers the cost of this for all future DS widget tests.
- Main-thread startup gains one `await` (`themeCubit.hydrate()`/equivalent) before `runApp`, mirroring the existing `await getIt.get<AppDatabaseService>().init()` pattern — no new initialization idiom introduced.

## Alternatives considered

- **Global reactive singleton (`ValueNotifier<ThemeMode>` + a `navigatorKey`-based "current context" lookup) so `DsColors.xxx` keeps its exact static-call syntax.** Rejected: live-update (no restart) still requires every `build()` that reads a token to *listen* to the notifier (e.g. via `ValueListenableBuilder` or `AnimatedBuilder`) to know when to rebuild — so the same ~30 call sites would need editing regardless, eliminating the only claimed benefit ("no call-site change"). On top of that, resolving the live theme via `navigatorKey.currentContext` is fragile (nullable before first frame, bypasses `InheritedWidget` dependency registration, doesn't compose with nested/overlay themes) and is exactly the kind of implicit global `CLAUDE.md`'s DI-first, explicit-dependency conventions steer away from. `ThemeExtension` + `Theme.of(context)` achieves the same call-site edit cost with none of these downsides and is Flutter's own idiomatic mechanism for exactly this problem.
- **Keep `DsColors` as static getters, add a parallel static `Brightness` field manually set by the theme controller.** Rejected: doesn't hook into Flutter's rebuild-on-theme-change mechanism at all (a static field mutation triggers no rebuilds anywhere), would require a full-app `setState`/rebuild broadcast mechanism to be built from scratch — strictly more work and more fragile than reusing `ThemeExtension`.
- **Persist via a new one-row `AppDatabaseTables` entry (`SETTINGS` table with a single `theme_mode` column).** Rejected: this is UI chrome preference, not clinical/patient domain data; forcing it through `AppDatabaseTables`/`TableSqlField`/a `*RepositoryImpl` talking to `AppDatabaseService` adds schema-migration ceremony (ADR 0001) for a single scalar value, and blurs the explicit scope boundary this task was given ("no persistence-of-domain-data touched"). `shared_preferences` is the standard, lightweight, Flutter-ecosystem-idiomatic tool for exactly a single key-value device preference, and nothing in `pubspec.yaml`'s existing dependency list signals an "no new dependencies" house rule — the other dependencies present (`go_router`, `flutter_bloc`, `injectable`, `equatable`) are themselves all well-known pub.dev packages adopted for exactly the problem they solve, the same bar `shared_preferences` clears here.
- **Skip the use-case layer for `lib/features/theme/` since it's trivial get/set, cubit calls repository directly.** Considered seriously (no real business logic exists beyond "read string, write string"), but rejected in favor of strict consistency with `CLAUDE.md`'s explicit "Use cases are the only thing cubits call" rule — special-casing "this feature is too simple for a use case" would itself be a judgment call future sessions would need to re-derive; keeping the layering uniform costs two trivial classes and removes the ambiguity.
