enum TableSqlTypes {
  text,
  integer,
  real,
  blob,
  boolean, // SQLite has no native boolean type; stored as INTEGER (0/1), same convention `PatientModel`'s bool<->int JsonKey converters already assume.
  json; // No native JSON/array type in SQLite; stored as TEXT, JSON-encoded/decoded at the model layer (mirrors `.boolean`'s INTEGER-storage precedent, ADR 0004). See ADR 0005.

  String get sql {
    switch (this) {
      case .text:
        return "TEXT";
      case .integer:
        return "INTEGER";
      case .real:
        return "REAL";
      case .blob:
        return "BLOB";
      case .boolean:
        return "INTEGER";
      case .json:
        return "TEXT";
    }
  }
}
