import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/data/repositories/energy_expenditure_repository_impl.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `bmi_repository_impl_test.dart`'s harness (real
/// AppDatabaseServiceImpl backed by sqflite_ffi against a fresh temp-file
/// DB per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync('energy_expenditure_repo_test_');
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createEnergyExpenditure persists a real row and returns Ok with the '
    'generated id and fields',
    () async {
      final path = _newTempDbPath('create_energy_expenditure');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = EnergyExpenditureRepositoryImpl(
        databaseService: service,
      );

      final entity = EnergyExpenditureCalculationEntity(
        patientId: 'patient-a',
        formula: EnergyExpenditureFormulaEnum.pocket,
        minValue: 1540,
        maxValue: 1750,
        createdAt: DateTime(2026, 9, 19),
        inputParams: const [
          InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 70.0),
          InputParamEntity(
            key: 'stress_level',
            label: 'Nível de Estresse',
            value: 'noStress',
          ),
        ],
      );

      final res = await repository.createEnergyExpenditure(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.formula, EnergyExpenditureFormulaEnum.pocket);
      expect(persisted.minValue, 1540);
      expect(persisted.maxValue, 1750);
      expect(persisted.createdAt, DateTime(2026, 9, 19));
      expect(persisted.inputParams, hasLength(2));
      expect(persisted.inputParams[0].key, 'weight_kg');
      expect(persisted.inputParams[0].value, 70.0);

      // Round-trip through a fresh connection to prove the row was actually
      // persisted to the real DB (not just returned from the locally-built
      // model), mirroring the BMI repository regression test's shape.
      final readBack = await service.read(
        AppDatabaseTables.energyExpenditures,
        where: 'id = ?',
        whereArgs: [persisted.id!],
      );
      expect(readBack.isOk, isTrue);
      readBack.when(
        ok: (rows) {
          expect(rows, hasLength(1));
          expect(rows.first['patientId'], 'patient-a');
          expect(rows.first['formula'], 'pocket');
          expect(rows.first['minValue'], 1540);
          expect(rows.first['maxValue'], 1750);
        },
        error: (_) => fail('expected Ok'),
      );
    },
  );
}
