import 'package:nutri_calc/core/services/database/entities/table_sql_constraints.enum.dart';
import 'package:nutri_calc/core/services/database/entities/table_sql_types.enum.dart';

class TableSqlField {
  final String name;
  final TableSqlTypes type;
  final List<TableSqlConstraints>? constraints;

  const TableSqlField({
    required this.name,
    required this.type,
    this.constraints
  });

  String get sql {
    return '''
        $name ${type.sql} ${constraints != null && constraints!.isNotEmpty ? constraints!.map((ct) => "${ct.sql} ").join("") : ""}
    ''';
  }
}
