import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `test/features/measurements/weight/data/repositories/weight_repository_impl_test.dart`'s
/// harness (real AppDatabaseServiceImpl backed by sqflite_ffi against a
/// fresh temp-file DB per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync('bmi_repo_test_');
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createBmi persists a real row and returns Ok with the generated id and fields',
    () async {
      final path = _newTempDbPath('create_bmi');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = BmiRepositoryImpl(databaseService: service);

      final entity = BmiCalculationEntity(
        patientId: 'patient-a',
        value: 24.4,
        classification: BmiClassification.eutrophy,
        createdAt: DateTime(2026, 9, 19),
        inputParams: const [
          InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 70.0),
          InputParamEntity(key: 'height_m', label: 'Altura (m)', value: 1.7),
          InputParamEntity(key: 'age', label: 'Idade', value: 30),
        ],
      );

      final res = await repository.createBmi(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.value, 24.4);
      expect(persisted.classification, BmiClassification.eutrophy);
      expect(persisted.createdAt, DateTime(2026, 9, 19));
      expect(persisted.inputParams, hasLength(3));
      expect(persisted.inputParams[0].key, 'weight_kg');
      expect(persisted.inputParams[0].value, 70.0);

      // Round-trip through a fresh connection to prove the row was actually
      // persisted to the real DB (not just returned from the locally-built
      // model), mirroring the weight repository regression test's shape.
      final readBack = await service.read(
        AppDatabaseTables.bmi,
        where: 'id = ?',
        whereArgs: [persisted.id!],
      );
      expect(readBack.isOk, isTrue);
      readBack.when(
        ok: (rows) {
          expect(rows, hasLength(1));
          expect(rows.first['patientId'], 'patient-a');
          expect(rows.first['classification'], 'eutrophy');
        },
        error: (_) => fail('expected Ok'),
      );
    },
  );
}
