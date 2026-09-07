# 0001. Database schema migrations via sqflite version + self-describing versioned fields

**Status:** Accepted
**Date:** 2026-09-06
**Feature:** docs/roadmap.md, Priority 1 "Create DB migration mechanism"

## Context

`AppDatabaseServiceImpl.init()` opens the sqflite database with no `version`/`onCreate`/`onUpgrade`, then runs every `AppDatabaseTables` case's `CREATE TABLE IF NOT EXISTS` SQL unconditionally. `IF NOT EXISTS` is a no-op once a table exists, so any column added to an existing table's field list after a device has already created that table never reaches that device — it silently gets the old schema forever, and the app will typically fail at the first `insert`/`update`/`read` that touches the missing column.

There is no shipped release yet (0.1.0+1, no CHANGELOG), so there's no real installed base to protect beyond the dev team's own devices — but the roadmap already lists ~10 new calculator tables plus pending columns on `PATIENT` and `WEIGHTS`, so this needs to be the durable pattern from here on, not a one-off fix.

Constraints from the requirement: additive-only (new columns, new tables) for now; must not lose data on upgrade; must work identically for fresh install and upgrade; must be testable with a real seed-old-schema-then-migrate test; migration failure must not be swallowed.

## Decision

Use sqflite's native `version` + `onCreate`/`onUpgrade` mechanism, driven by making `AppDatabaseTables` (and its `TableSqlField`s) self-describe **when** they were introduced, not just their final shape.

**1. A single app-wide schema version constant.**

New file `lib/core/services/database/app_database_version.dart`:

```dart
/// Current DB schema version. Bump by exactly 1 every time a migration
/// (new table or new column) is added anywhere in AppDatabaseTables.
const int kAppDatabaseVersion = 1;
```

**2. `TableSqlField` gains version + default metadata.**

`lib/core/services/database/entities/table_sql_field.entity.dart` gets two new fields:

```dart
class TableSqlField {
  final String name;
  final TableSqlTypes type;
  final List<TableSqlConstraints>? constraints;
  final int sinceVersion;      // schema version this column was introduced in; 1 for original columns
  final Object? defaultValue;  // required if constraints contains notNull and sinceVersion > 1

  const TableSqlField({
    required this.name,
    required this.type,
    this.constraints,
    this.sinceVersion = 1,
    this.defaultValue,
  });

  String get sql { ... }           // unchanged: full column def, used in CREATE TABLE

  /// Column definition usable in `ALTER TABLE ... ADD COLUMN`. SQLite's ADD COLUMN
  /// does not allow PRIMARY KEY/UNIQUE, and NOT NULL requires a DEFAULT.
  String get addColumnSql {
    assert(
      constraints == null || !constraints!.contains(.primaryKey),
      "Cannot add a PRIMARY KEY column via migration ($name)",
    );
    assert(
      constraints == null ||
          !constraints!.contains(.notNull) ||
          defaultValue != null,
      "NOT NULL column added via migration must have a defaultValue ($name)",
    );
    final defaultSql = defaultValue != null
        ? "DEFAULT ${_sqlLiteral(defaultValue)}"
        : "";
    final notNull = constraints?.contains(.notNull) == true ? "NOT NULL" : "";
    return "$name ${type.sql} $notNull $defaultSql";
  }
}
```

**3. `AppDatabaseTables` gains a table-level `sinceVersion` and exposes its raw field list (not just the joined SQL string).**

```dart
enum AppDatabaseTables {
  patient(name: "PATIENT", sinceVersion: 1),
  weights(name: "WEIGHTS", sinceVersion: 1),
  heights(name: "HEIGHTS", sinceVersion: 1),
  bodyMeasurements(name: "BODY_MEASUREMENTS", sinceVersion: 1);

  final String name;
  final int sinceVersion; // schema version this table was introduced in
  const AppDatabaseTables({required this.name, required this.sinceVersion});

  List<TableSqlField> get fields { switch (this) { ... } }   // the field lists that exist today, unchanged content, just extracted out of the string-building method

  String get sql => _getSqlForCreateTable(fields);            // unchanged behavior, now built from `fields`
}
```

This is a refactor, not a behavior change, for `sinceVersion: 1` tables/fields with `fields` unchanged from today.

**4. `AppDatabaseServiceImpl.init()` uses `version`/`onCreate`/`onUpgrade`.**

```dart
Future<void> init({String? dbPath, int? version}) async {
  final path = dbPath ?? "nutri_calc.db";
  final targetVersion = version ?? kAppDatabaseVersion;

  _db = await openDatabase(
    path,
    version: targetVersion,
    onCreate: (db, version) async {
      // Fresh install: create every table at its final (current) shape directly.
      for (final table in AppDatabaseTables.values) {
        await db.execute(table.sql);
      }
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      for (final table in AppDatabaseTables.values) {
        if (table.sinceVersion > oldVersion) {
          // Table didn't exist at oldVersion — create it whole at its current shape.
          await db.execute(table.sql);
          continue;
        }
        // Table already existed — apply only the columns introduced since oldVersion.
        for (final field in table.fields) {
          if (field.sinceVersion > oldVersion && field.sinceVersion <= newVersion) {
            await db.execute(
              "ALTER TABLE ${table.name} ADD COLUMN ${field.addColumnSql}",
            );
          }
        }
      }
    },
  );
}
```

`dbPath`/`version` are optional named parameters defaulting to production values, added purely so tests can point at an isolated DB file/in-memory path and an arbitrary starting version without touching DI. `AppDatabaseServiceImpl` stays a zero-arg-constructed `@Singleton` from DI's point of view — **no `di.config.dart` regeneration is required** for this change, since injectable still calls `AppDatabaseServiceImpl()` and `init()` continues to have a legal zero-arg call (`init()`).

Exceptions inside `onCreate`/`onUpgrade` propagate as a rejected `Future` from `openDatabase` (sqflite's documented behavior), which propagates out of `init()` uncaught, which is exactly today's behavior for any `init()` failure: `main.dart` does `await getIt.get<AppDatabaseService>().init();` with no try/catch before `runApp`, so a throw here already prevents `runApp` from ever being called and surfaces as an unhandled exception in the zone (visible in console / crash reporting once configured). **No new error handling is introduced or needed** — migration failure is not swallowed today and won't be after this change. This decision does not wrap `init()` in `Result` — it stays consistent with its current `Future<void>` signature; `Result` is reserved for repository/use-case-level operations per `CLAUDE.md`, not app bootstrap.

**Developer-facing pattern for future schema changes** (this is the part PO asked to be documented and repeatable):

- *Adding a column to an existing table:* bump `kAppDatabaseVersion` by 1, add a new `TableSqlField(..., sinceVersion: <newVersion>, defaultValue: ... if notNull)` to that table's `fields` getter. Nothing else changes — `onCreate` picks it up automatically (fresh installs always get the full final field list), `onUpgrade` picks it up automatically for anyone upgrading through that version.
- *Adding a new table:* bump `kAppDatabaseVersion` by 1, add a new `AppDatabaseTables` case with `sinceVersion: <newVersion>` and its full field list (all fields at `sinceVersion: <newVersion>` unless the table itself later grows columns). No separate "create table" migration entry is needed — `onUpgrade`'s `table.sinceVersion > oldVersion` branch creates the whole table.
- *Never* edit an existing `TableSqlField`'s `sinceVersion` or a table's `sinceVersion` retroactively — that value is a historical fact about what schema version introduced it. Getting it wrong means devices that upgraded through that version skip the `ALTER TABLE`/`CREATE TABLE`.
- Each PR that changes schema must bump `kAppDatabaseVersion` by exactly 1 (not skip versions) — sqflite calls `onUpgrade(oldVersion, newVersion)` once per open, and this design applies every field/table whose `sinceVersion` falls in `(oldVersion, newVersion]` in a single pass, so multi-version jumps are already handled correctly by a device that was offline for several releases; the "by exactly 1" rule is only to keep one canonical current version, not a correctness requirement for `onUpgrade` itself.

## Consequences

**Easier:** adding a column/table going forward is a small, mechanical, reviewable diff (one `sinceVersion` bump + one field/case) instead of a bespoke migration script; fresh installs and upgrades are guaranteed to converge to the same final schema because both derive from the same `fields`/`sql` source of truth; no duplicate "migration SQL" to keep in sync with "current schema SQL" by hand.

**Harder / ruled out for now:** column drop and rename are not supported by this design as-is — SQLite's `ALTER TABLE` historically doesn't support `DROP COLUMN`/`RENAME COLUMN` uniformly across versions, and modeling "removal" via `sinceVersion` (an introduction timestamp) doesn't naturally express "this field existed between version X and Y." If/when drop/rename is needed, extend `TableSqlField` with a `removedInVersion`/`renamedFrom` and add a rebuild-via-temp-table step to `onUpgrade` (SQLite's documented pattern: create new table, copy data, drop old, rename) — this ADR intentionally leaves that as a follow-up rather than building it now, per the additive-only scope. Note as a roadmap tech-debt item when drop/rename is actually needed.

**Follow-up work created:** the ~10 new calculator tables and the pending PATIENT/WEIGHTS columns (already on the roadmap) should each be implemented using this pattern (bump `kAppDatabaseVersion`, add fields/cases with the correct `sinceVersion`) — not implemented as part of this ADR.

**Testing implication:** `sqflite_common_ffi` needs to be added as a `dev_dependency` (not present in `pubspec.yaml` today) because plain `flutter test` doesn't have a platform channel for sqflite; ffi swaps in a pure-Dart/SQLite implementation of `databaseFactory` suitable for `flutter test`. See implementation plan for the exact test setup.

## Alternatives considered

- **Idempotent "ensure column exists" helper run unconditionally on every `init()`** (introspect `PRAGMA table_info`, add any field present in the enum's field list but absent from the live table): rejected as the primary mechanism because it re-runs a full schema diff on every single app launch (wasted work forever), and it still needs the "which fields are new" info from somewhere — using sqflite's built-in `onUpgrade`, which runs at most once per version bump and only when the device's version actually lags, gets the same guarantee with less runtime cost. It also doesn't get us fresh-install/upgrade to definitely converge the same way `onCreate`/`onUpgrade` sharing `table.sql`/`table.fields` does.
- **Numbered migration files/classes (Rails/Flyway style, one file per version with explicit up SQL)**: rejected as more ceremony than the additive-only scope warrants right now — it would require a registry of migration objects in addition to the existing `AppDatabaseTables` enum, duplicating the "current schema" description that already lives there. Revisit if drop/rename support is added later and the diff-from-metadata approach stops being expressive enough.
