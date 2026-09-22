import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/data/repositories/weight_loss_classification_repository_impl.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `water_needs_repository_impl_test.dart`'s harness (real
/// AppDatabaseServiceImpl backed by sqflite_ffi against a fresh temp-file DB
/// per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync(
    'weight_loss_classification_repo_test_',
  );
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createWeightLossClassification persists a real row and returns Ok '
    'with the generated id and fields',
    () async {
      final path = _newTempDbPath('create_weight_loss_classification');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = WeightLossClassificationRepositoryImpl(
        databaseService: service,
      );

      final entity = WeightLossClassificationCalculationEntity(
        patientId: 'patient-a',
        percentage: 10,
        timeReference: 7,
        classification: WeightLossClassification.severe,
        createdAt: DateTime(2026, 9, 20),
        inputParams: const [
          InputParamEntity(
            key: 'current_weight_kg',
            label: 'Peso Atual (kg)',
            value: 63.0,
          ),
          InputParamEntity(
            key: 'last_weight_kg',
            label: 'Peso Anterior (kg)',
            value: 70.0,
          ),
        ],
      );

      final res = await repository.createWeightLossClassification(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.percentage, 10);
      expect(persisted.timeReference, 7);
      expect(persisted.classification, WeightLossClassification.severe);
      expect(persisted.createdAt, DateTime(2026, 9, 20));
      expect(persisted.inputParams, hasLength(2));

      final readBack = await service.read(
        AppDatabaseTables.weightLossClassifications,
        where: 'id = ?',
        whereArgs: [persisted.id!],
      );
      expect(readBack.isOk, isTrue);
      readBack.when(
        ok: (rows) {
          expect(rows, hasLength(1));
          expect(rows.first['patientId'], 'patient-a');
          expect(rows.first['classification'], 'severe');
        },
        error: (_) => fail('expected Ok'),
      );
    },
  );
}
