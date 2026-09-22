import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/data/repositories/enteral_nutrition_dripping_repository_impl.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `nitrogen_balance_repository_impl_test.dart`'s harness (real
/// AppDatabaseServiceImpl backed by sqflite_ffi against a fresh temp-file DB
/// per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync(
    'enteral_nutrition_dripping_repo_test_',
  );
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createEnteralNutritionDripping persists a real row and returns Ok '
    'with the generated id and fields',
    () async {
      final path = _newTempDbPath('create_enteral_nutrition_dripping');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = EnteralNutritionDrippingRepositoryImpl(
        databaseService: service,
      );

      final entity = EnteralNutritionDrippingCalculationEntity(
        patientId: 'patient-a',
        value: 41.666,
        createdAt: DateTime(2026, 9, 19),
        inputParams: const [
          InputParamEntity(
            key: 'total_volume_ml',
            label: 'Volume Total (mL)',
            value: 1000.0,
          ),
          InputParamEntity(
            key: 'total_hours_for_volume_h',
            label: 'Tempo Total (h)',
            value: 8.0,
          ),
        ],
      );

      final res = await repository.createEnteralNutritionDripping(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.value, 41.666);
      expect(persisted.createdAt, DateTime(2026, 9, 19));
      expect(persisted.inputParams, hasLength(2));

      final readBack = await service.read(
        AppDatabaseTables.enteralNutritionDripping,
        where: 'id = ?',
        whereArgs: [persisted.id!],
      );
      expect(readBack.isOk, isTrue);
      readBack.when(
        ok: (rows) {
          expect(rows, hasLength(1));
          expect(rows.first['patientId'], 'patient-a');
        },
        error: (_) => fail('expected Ok'),
      );
    },
  );
}
