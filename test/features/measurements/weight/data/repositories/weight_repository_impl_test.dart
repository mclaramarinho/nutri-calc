import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/data/repositories/weight_repository_impl.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `test/core/services/database/app_database_service_test.dart`'s
/// harness (real AppDatabaseServiceImpl backed by sqflite_ffi against a
/// fresh temp-file DB per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync('weight_repo_test_');
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'getWeights only returns rows matching the given patientId',
    () async {
      final path = _newTempDbPath('patient_filter');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      await service.insert(
        AppDatabaseTables.weights,
        WeightModel(
          id: 'w1',
          value: 70,
          createdAt: DateTime(2024, 1, 1),
          patientId: 'patient-a',
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ).toJson(),
      );
      await service.insert(
        AppDatabaseTables.weights,
        WeightModel(
          id: 'w2',
          value: 80,
          createdAt: DateTime(2024, 1, 2),
          patientId: 'patient-b',
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ).toJson(),
      );

      final repository = WeightRepositoryImpl(databaseService: service);

      final res = await repository.getWeights('patient-a');

      expect(res.isOk, isTrue);
      final values = res.getOrElse(() => <WeightModel>[]);
      expect(values, hasLength(1));
      expect(values.single.patientId, 'patient-a');
    },
  );

  test(
    // Regression test for the createWeight bug: `WeightModel.fromJson(rowid)`
    // (rowid is a raw int, not a JSON map) used to throw, get swallowed by
    // the method's own try/catch, and return `Error` on every real DB
    // round-trip — so a real (non-mocked) insert had never been exercised
    // before. This asserts a successful, correctly-shaped `Ok` result
    // against a real sqflite ffi DB.
    'createWeight persists a real row and returns Ok with the generated id and fields',
    () async {
      final path = _newTempDbPath('create_weight');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = WeightRepositoryImpl(databaseService: service);
      final createdAt = DateTime(2024, 3, 10, 9, 30);

      final res = await repository.createWeight(
        value: 82.5,
        patientId: 'patient-c',
        considerForCalculations: true,
        weightType: WeightTypeEnum.measuredByScale,
        createdAt: createdAt,
      );

      expect(res.isOk, isTrue);
      final model = res.getOrElse(() => throw StateError('expected Ok'));
      expect(model.id, isNotNull);
      expect(model.id, isNotEmpty);
      expect(model.value, 82.5);
      expect(model.patientId, 'patient-c');
      expect(model.considerForCalculations, isTrue);
      expect(model.weightType, WeightTypeEnum.measuredByScale);
      expect(model.createdAt, createdAt);

      final readBack = await repository.getWeights('patient-c');
      expect(readBack.isOk, isTrue);
      final persisted = readBack.getOrElse(() => <WeightModel>[]);
      expect(persisted, hasLength(1));
      expect(persisted.single.id, model.id);
      expect(persisted.single.createdAt, createdAt);
    },
  );
}
