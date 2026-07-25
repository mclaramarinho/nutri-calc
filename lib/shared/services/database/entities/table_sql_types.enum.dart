enum TableSqlTypes {
  text,
  integer,
  real,
  blob;

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
    }
  }
}
