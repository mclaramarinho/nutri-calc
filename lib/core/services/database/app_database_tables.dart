import 'package:nutri_calc/core/services/database/entities/table_sql_field.entity.dart';

enum AppDatabaseTables {
  patient(name: "PATIENT", sinceVersion: 1),
  weights(name: "WEIGHTS", sinceVersion: 1),
  heights(name: "HEIGHTS", sinceVersion: 1),
  bodyMeasurements(name: "BODY_MEASUREMENTS", sinceVersion: 1),
  bmi(name: "BMI", sinceVersion: 3),
  energyExpenditures(name: "ENERGY_EXPENDITURES", sinceVersion: 4),
  nitrogenBalances(name: "NITROGEN_BALANCES", sinceVersion: 5),
  proteinNeeds(name: "PROTEIN_NEEDS", sinceVersion: 5),
  waterNeeds(name: "WATER_NEEDS", sinceVersion: 5),
  enteralNutritionDripping(name: "ENTERAL_NUTRITIONS_DRIPPING", sinceVersion: 6),
  enteralNutritionSpeed(name: "ENTERAL_NUTRITIONS_SPEED", sinceVersion: 6),
  enteralNutritionVolume(name: "ENTERAL_NUTRITIONS_VOLUME", sinceVersion: 6),
  glucoseInfusionRates(name: "GLUCOSE_INFUSION_RATES", sinceVersion: 6),
  weightLossClassifications(
    name: "WEIGHT_LOSS_CLASSIFICATIONS",
    sinceVersion: 7,
  );

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
          TableSqlField(
            name: "enteralNutrition",
            type: .boolean,
            constraints: [.notNull],
            sinceVersion: 2,
            defaultValue: 0,
          ),
          TableSqlField(
            name: "parenteralNutrition",
            type: .boolean,
            constraints: [.notNull],
            sinceVersion: 2,
            defaultValue: 0,
          ),
          TableSqlField(
            name: "hospitalized",
            type: .boolean,
            constraints: [.notNull],
            sinceVersion: 2,
            defaultValue: 0,
          ),
          TableSqlField(
            name: "confinedToBed",
            type: .boolean,
            constraints: [.notNull],
            sinceVersion: 2,
            defaultValue: 0,
          ),
        ];
      case .weights:
        return [
          ..._baseMeasurementTableFields,
          TableSqlField(
            name: "considerForCalculations",
            type: .boolean,
            constraints: [.notNull],
            sinceVersion: 3,
            defaultValue: 1,
          ),
          TableSqlField(
            name: "weightType",
            type: .text,
            constraints: [.notNull],
            sinceVersion: 3,
            defaultValue: "measuredByScale",
          ),
        ];
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

      case .bmi:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(
            name: "classification",
            type: .text,
            constraints: [.notNull],
          ),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .energyExpenditures:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "formula", type: .text, constraints: [.notNull]),
          TableSqlField(name: "minValue", type: .real, constraints: [.notNull]),
          TableSqlField(name: "maxValue", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .nitrogenBalances:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .proteinNeeds:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "minValue", type: .real, constraints: [.notNull]),
          TableSqlField(name: "maxValue", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .waterNeeds:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .enteralNutritionDripping:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .enteralNutritionSpeed:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .enteralNutritionVolume:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .glucoseInfusionRates:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "value", type: .real, constraints: [.notNull]),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
            constraints: [.notNull],
          ),
        ];

      case .weightLossClassifications:
        return [
          TableSqlField(name: "id", type: .text, constraints: [.primaryKey]),
          TableSqlField(name: "patientId", type: .text, constraints: [.notNull]),
          TableSqlField(name: "percentage", type: .real, constraints: [.notNull]),
          TableSqlField(
            name: "timeReference",
            type: .integer,
            constraints: [.notNull],
          ),
          TableSqlField(
            name: "classification",
            type: .text,
            constraints: [.notNull],
          ),
          TableSqlField(name: "createdAt", type: .text, constraints: [.notNull]),
          TableSqlField(
            name: "inputParams",
            type: .json,
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
