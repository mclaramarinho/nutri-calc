import 'package:nutri_calc/core/services/database/entities/table_sql_field.entity.dart';

enum AppDatabaseTables {
  patient(name: "PATIENT"),
  weights(name: "WEIGHTS"),
  heights(name: "HEIGHTS"),
  bodyMeasurements(name: "BODY_MEASUREMENTS");

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
          TableSqlField(name: "ageUnit", type: .text),
        ]);
      case .weights:
        return _getSqlForCreateTable(_baseMeasurementTableFields);
      case .heights:
        return _getSqlForCreateTable(_baseMeasurementTableFields);

      case .bodyMeasurements:
        return _getSqlForCreateTable([
          ..._baseMeasurementTableFields,
          TableSqlField(
            name: "measurementType",
            type: .text,
            constraints: [.notNull],
          ),
        ]);
    }
  }

  List<TableSqlField> get _baseMeasurementTableFields => [
    TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
    TableSqlField(name: "value", type: .real, constraints: [.notNull]),
    TableSqlField(name: "createdAt", type: .text),
    TableSqlField(name: "patientId", type: .text),
  ];

  String _getSqlForCreateTable(List<TableSqlField> fields) {
    return '''
      CREATE TABLE IF NOT EXISTS $name (
        ${fields.map((fd) => fd.sql).join(", ")}
      )
    ''';
  }
}
