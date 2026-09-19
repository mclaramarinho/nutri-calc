# 0005. `TableSqlTypes` gains a self-documenting `.json` case (maps to SQL `TEXT`)

**Status:** Accepted
**Date:** 2026-09-19
**Feature:** docs/roadmap.md section 2.1.4 "Calculators", Slice 1 scope (BMI persistence); section 3.1 "Calculators" storage convention

## Context

The roadmap's calculator storage convention (product decision, 2026-09-07, section 3.1/2.1.4) requires every calculator table (`BMI`, and later `ENERGY_EXPENDITURES`, `ENTERAL_NUTRITIONS_*`, per-screening tables, etc.) to store an `inputParams` column: a JSON array of `{ key, label, value }` entries capturing the parameters used for that calculation, alongside fixed base columns (result value(s), `createdAt`, `patientId`, and any discriminant). SQLite has no native JSON/array column type — like `.boolean` before it (see [ADR 0004](0004-table-sql-types-boolean-case.md)), this is a storage-affinity concern: the column is physically `TEXT`, and JSON encode/decode happens at the model layer.

`TableSqlTypes` (`lib/core/services/database/entities/table_sql_types.enum.dart`) currently has `text`/`integer`/`real`/`blob`/`boolean`, none of which self-document "this TEXT column holds serialized JSON, not a plain string." This was already flagged as a known, deferred dependency in the roadmap (2026-09-07 note: "`AppDatabaseTables`/`TableSqlType` currently has no JSON/blob column type ... small enough to be done as part of the first calculator table's implementation"). BMI (Slice 1) is that first calculator table, so this ADR resolves it now, following the exact precedent ADR 0004 set.

## Decision

Add a `json` case to `TableSqlTypes` that maps to the same `"TEXT"` SQL type as `.text`:

```dart
enum TableSqlTypes {
  text,
  integer,
  real,
  blob,
  boolean,
  json; // No native JSON/array type in SQLite; stored as TEXT, JSON-encoded/decoded at the model layer (mirrors `.boolean`'s INTEGER-storage precedent, ADR 0004).

  String get sql {
    switch (this) {
      case .text: return "TEXT";
      case .integer: return "INTEGER";
      case .real: return "REAL";
      case .blob: return "BLOB";
      case .boolean: return "INTEGER";
      case .json: return "TEXT";
    }
  }
}
```

Use `TableSqlField(name: "inputParams", type: .json, constraints: [.notNull])` on `AppDatabaseTables.bmi.fields` (and on every future calculator table). At the model layer, the corresponding `BmiModel` field is a `List<InputParamEntry>` (or equivalent `List<Map<String, dynamic>>` shape carrying `key`/`label`/`value`), converted to/from the stored `TEXT` column via `@JsonKey(toJson:, fromJson:)`:

```dart
@JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
final List<InputParam> inputParams;

static String _paramsToJson(List<InputParam> value) =>
    jsonEncode(value.map((p) => p.toJson()).toList());

static List<InputParam> _paramsFromJson(dynamic value) =>
    (jsonDecode(value as String) as List)
        .map((e) => InputParam.fromJson(e as Map<String, dynamic>))
        .toList();
```

This mirrors `PatientModel`'s existing `_boolToInt`/`_intToBool` converter pattern for `.boolean` columns — the model layer is where the byte-shape conversion for a `TableSqlTypes` case's storage affinity always happens, not inside the DB service.

## Consequences

**Easier:** every future calculator table (Energy Expenditure, Enteral/Parenteral Nutrition, screening tools, etc.) declares its `inputParams` column the same self-documenting way, with the same converter pattern, rather than reusing `.text` and relying on the column name alone to say "this is JSON." Reviewers immediately see which `TEXT` columns are opaque strings vs. structured JSON blobs. No behavior or generated SQL change for existing `.text` columns — purely additive.

**Harder / ruled out:** SQLite has no `JSON` column type or validation — `.json.sql == .text.sql == "TEXT"`, so nothing at the database layer enforces that a `.json` column actually contains valid JSON; that responsibility stays entirely at the model layer's `toJson`/`fromJson`, same as `.boolean` doesn't enforce `0`/`1`. This ADR does not adopt SQLite's `JSON1`/`->`/`->>` operators for querying inside `inputParams` — Slice 1 has no requirement to query by parameter value, and `inputParams` is read back only as a whole blob per row (consistent with the roadmap's stated purpose: "reference the parameters used," not to filter/aggregate by them). Revisit if a future slice needs to query inside `inputParams`.

**Follow-up:** none required now; every calculator table introduced after BMI should use `.json` for its `inputParams` column (and any other per-table JSON-shaped column, e.g. `Screenings`' answers) rather than reusing `.text`, for the same self-documentation reason ADR 0004 gives for `.boolean` vs `.integer`.

## Alternatives considered

- **Reuse `.text` directly, rely on the column name for intent.** Rejected for the same reason ADR 0004 rejected reusing `.integer` for booleans: this codebase already treats the `TableSqlTypes` enum as the place storage-affinity intent lives (ADR 0001's `sinceVersion` self-description, ADR 0004's `.boolean`), and a second un-self-documented case would be inconsistent with that established precedent for one enum case's cost.
- **Add a `.blob` column instead, storing JSON as bytes.** Rejected: `inputParams` is always UTF-8 text (JSON), never binary; `.blob` exists for genuinely binary data and using it here would misrepresent the actual storage content and require unnecessary `Uint8List` encode/decode at the model layer instead of a plain `String`.
- **Model `inputParams` as real relational rows in a child table (`bmi_input_params(bmi_id, key, label, value)`) instead of JSON-in-a-column.** Rejected: this is exactly the "sparse/nullable columns per variant or one table per formula variant" problem the roadmap's 2026-09-07 storage-convention decision already rejected in favor of the base+`inputParams` JSON structure — reopening it per-column here would contradict that already-settled product decision rather than implement it.
