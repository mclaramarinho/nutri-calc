import 'package:nutri_calc/core/services/database/entities/table_sql_constraints.enum.dart';
import 'package:nutri_calc/core/services/database/entities/table_sql_types.enum.dart';

class TableSqlField {
  final String name;
  final TableSqlTypes type;
  final List<TableSqlConstraints>? constraints;
  final int sinceVersion;
  final Object? defaultValue;

  const TableSqlField({
    required this.name,
    required this.type,
    this.constraints,
    this.sinceVersion = 1,
    this.defaultValue,
  });

  String get sql {
    return '''
        $name ${type.sql} ${constraints != null && constraints!.isNotEmpty ? constraints!.map((ct) => "${ct.sql} ").join("") : ""}
    ''';
  }

  /// Column definition usable in `ALTER TABLE ... ADD COLUMN`. SQLite's ADD
  /// COLUMN does not allow PRIMARY KEY/UNIQUE, and NOT NULL requires a
  /// DEFAULT.
  String get addColumnSql {
    if (constraints != null &&
        (constraints!.contains(TableSqlConstraints.primaryKey) ||
            constraints!.contains(TableSqlConstraints.unique))) {
      throw ArgumentError(
        "Cannot add a PRIMARY KEY or UNIQUE column via migration ($name)",
      );
    }
    if (constraints != null &&
        constraints!.contains(TableSqlConstraints.notNull) &&
        defaultValue == null) {
      throw ArgumentError(
        "NOT NULL column added via migration must have a defaultValue ($name)",
      );
    }
    final defaultSql = defaultValue != null
        ? "DEFAULT ${_sqlLiteral(defaultValue!)}"
        : "";
    final notNull =
        constraints?.contains(TableSqlConstraints.notNull) == true
        ? "NOT NULL"
        : "";
    return "$name ${type.sql} $notNull $defaultSql";
  }

  String _sqlLiteral(Object value) {
    if (value is String) {
      return "'${value.replaceAll("'", "''")}'";
    }
    return "$value";
  }
}
