import 'package:nutri_calc/core/services/database/entities/table_sql_field.entity.dart';

enum AppDatabaseTables {
  patient(name: "PATIENT", sinceVersion: 1),
  weights(name: "WEIGHTS", sinceVersion: 1),
  heights(name: "HEIGHTS", sinceVersion: 1),
  bodyMeasurements(name: "BODY_MEASUREMENTS", sinceVersion: 1);

  final String name;
  final int sinceVersion;
  const AppDatabaseTables({required this.name, required this.sinceVersion});

  List<TableSqlField> get fields {
    switch (this) {
      case .patient:
        return [
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
        ];
      case .weights:
        return _baseMeasurementTableFields;
      case .heights:
        return _baseMeasurementTableFields;

      case .bodyMeasurements:
        return [
          ..._baseMeasurementTableFields,
          TableSqlField(
            name: "measurementType",
            type: .text,
            constraints: [.notNull],
          ),
        ];
    }
  }

  String get sql => _getSqlForCreateTable(fields);

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
