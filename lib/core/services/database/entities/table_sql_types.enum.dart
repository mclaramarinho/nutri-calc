enum TableSqlTypes {
  text,
  integer,
  real,
  blob,
  boolean; // SQLite has no native boolean type; stored as INTEGER (0/1), same convention `PatientModel`'s bool<->int JsonKey converters already assume.

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
    }
  }
}
