# 0004. `TableSqlTypes` gains a self-documenting `.boolean` case (maps to SQL `INTEGER`)

**Status:** Accepted
**Date:** 2026-09-12
**Feature:** docs/roadmap.md section 2.1.1, "Confirmed requirement for the 4 missing fields" (Enteral Nutrition, Parenteral Nutrition, Hospitalized, Confined to bed)

## Context

The 4 new `PATIENT` columns (`enteralNutrition`, `parenteralNutrition`, `hospitalized`, `confinedToBed`) are `bool` at the Dart/model layer but must be stored as SQLite `INTEGER` (SQLite has no native boolean type — `0`/`1` by convention). `TableSqlTypes` (`lib/core/services/database/entities/table_sql_types.enum.dart`) today only has `text`/`integer`/`real`/`blob`, so the only way to declare these columns right now is `TableSqlField(type: .integer, ...)` — correct SQL, but the field declaration alone doesn't say *why* it's an integer (storage-only artifact of "no boolean in SQLite" vs. an actual numeric column like `age`). This is the first time the codebase has a `bool`-shaped column; the roadmap already implies more are coming (Calculator Relevance flags, screening tool yes/no inputs), so this is a recurring shape, not a one-off.

## Decision

Add a `boolean` case to `TableSqlTypes` that maps to the same `"INTEGER"` SQL type as `.integer`:

```dart
enum TableSqlTypes {
  text,
  integer,
  real,
  blob,
  boolean; // SQLite has no native boolean type; stored as INTEGER (0/1), same convention `PatientModel`'s bool<->int JsonKey converters already assume.

  String get sql {
    switch (this) {
      case .text: return "TEXT";
      case .integer: return "INTEGER";
      case .real: return "REAL";
      case .blob: return "BLOB";
      case .boolean: return "INTEGER";
    }
  }
}
```

Use `TableSqlField(name: "enteralNutrition", type: .boolean, constraints: [.notNull], sinceVersion: 2, defaultValue: 0)` (and the same shape for the other 3 fields) in `AppDatabaseTables.patient.fields`, rather than `type: .integer`.

## Consequences

**Easier:** the field declaration itself documents intent (`.boolean` column vs. `.integer` column reads differently at the call site, e.g. `age` stays `.integer` while `hospitalized` is `.boolean`), which matters because the model-layer `@JsonKey` int↔bool converter is mandatory for `.boolean` columns but would be wrong/unnecessary for a genuine `.integer` column — the type now signals which convention applies. No behavior or generated SQL changes (`.boolean.sql == .integer.sql == "INTEGER"`), so this is purely additive/non-breaking for `TableSqlTypes.sql` and `TableSqlField.addColumnSql`.

**Harder / ruled out:** this does not add any runtime validation that a `.boolean` column's stored values are actually `0`/`1` (SQLite itself doesn't enforce this, and adding a `CHECK` constraint is out of scope — not requested, and `TableSqlConstraints` doesn't currently support arbitrary `CHECK` clauses).

**Follow-up:** none required now; future `bool`-shaped columns should use `.boolean` rather than `.integer` for consistency, but this is a coding-convention note, not new work.

## Alternatives considered

- **Reuse `.integer` directly, rely on the column name + comment for intent.** Rejected: the codebase already treats self-description as a first-class design value for this exact DB layer (ADR 0001's whole premise is `sinceVersion` self-describing "when", not relying on comments/tribal knowledge) — extending that to "what kind of integer" costs one enum case and is consistent with that precedent rather than inventing a new one.
- **Keep storage as `INTEGER` but model it as a real SQL `BOOLEAN` type affordance (i.e., add `"BOOLEAN"` as the literal SQL text).** Rejected: SQLite only has type affinities, not enforced types — declaring a column `BOOLEAN` doesn't change storage or behavior (SQLite maps unrecognized type names to `NUMERIC` affinity, not a fixed-width boolean), and would be a cosmetic difference that could misleadingly suggest stronger guarantees than a plain `INTEGER` column already has. Mapping `.boolean` to `"INTEGER"` is the honest representation of what SQLite actually does.
