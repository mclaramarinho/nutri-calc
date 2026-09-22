import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/data/repositories/enteral_nutrition_speed_repository_impl.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `nitrogen_balance_repository_impl_test.dart`'s harness (real
/// AppDatabaseServiceImpl backed by sqflite_ffi against a fresh temp-file DB
/// per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync(
    'enteral_nutrition_speed_repo_test_',
  );
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createEnteralNutritionSpeed persists a real row and returns Ok with '
    'the generated id and fields',
    () async {
      final path = _newTempDbPath('create_enteral_nutrition_speed');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = EnteralNutritionSpeedRepositoryImpl(
        databaseService: service,
      );

      final entity = EnteralNutritionSpeedCalculationEntity(
        patientId: 'patient-a',
        value: 100,
        createdAt: DateTime(2026, 9, 19),
        inputParams: const [
          InputParamEntity(
            key: 'total_daily_volume_ml',
            label: 'Volume Diário Total (mL)',
            value: 2400.0,
          ),
        ],
      );

      final res = await repository.createEnteralNutritionSpeed(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.value, 100);
      expect(persisted.createdAt, DateTime(2026, 9, 19));
      expect(persisted.inputParams, hasLength(1));

      final readBack = await service.read(
        AppDatabaseTables.enteralNutritionSpeed,
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
