import 'package:nutri_calc/shared/services/database/entities/table_sql_field.entity.dart';

enum AppDatabaseTables {
  patient(name: "PATIENT");

  final String name;
  const AppDatabaseTables({required this.name});

  String get sql {
    switch (this) {
      case .patient:
        return _getSqlForCreateTable([
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text),
          TableSqlField(
            name: "firstName",
            type: .text,
            constraints: [.notNull],
          ),
          TableSqlField(name: "lastName", type: .text, constraints: [.notNull]),
          TableSqlField(name: "birthdate", type: .text),
          TableSqlField(name: "age", type: .integer),
        ]);
    }
  }

  String _getSqlForCreateTable(List<TableSqlField> fields) {
    return '''
      CREATE TABLE IF NOT EXISTS $name (
        ${fields.map((fd) => fd.sql).join(", ")}
      )
    ''';
  }
}
