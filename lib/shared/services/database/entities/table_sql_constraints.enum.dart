enum TableSqlConstraints {
  unique,
  primaryKey,
  notNull;

  String get sql {
    switch (this) {
      case .unique:
        return "UNIQUE";
      case .primaryKey:
        return "PRIMARY KEY";
      case .notNull:
        return "NOT NULL";
    }
  }
}
