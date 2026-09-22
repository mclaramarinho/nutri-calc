import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/data/repositories/glucose_infusion_rate_repository_impl.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `nitrogen_balance_repository_impl_test.dart`'s harness (real
/// AppDatabaseServiceImpl backed by sqflite_ffi against a fresh temp-file DB
/// per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync(
    'glucose_infusion_rate_repo_test_',
  );
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'createGlucoseInfusionRate persists a real row and returns Ok with the '
    'generated id and fields',
    () async {
      final path = _newTempDbPath('create_glucose_infusion_rate');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final repository = GlucoseInfusionRateRepositoryImpl(
        databaseService: service,
      );

      final entity = GlucoseInfusionRateCalculationEntity(
        patientId: 'patient-a',
        value: 0.5102,
        createdAt: DateTime(2026, 9, 19),
        inputParams: const [
          InputParamEntity(
            key: 'weight_kg',
            label: 'Peso (kg)',
            value: 70.0,
          ),
          InputParamEntity(
            key: 'total_glucose_g',
            label: 'Glicose Total (g)',
            value: 50.0,
          ),
        ],
      );

      final res = await repository.createGlucoseInfusionRate(entity);

      expect(res.isOk, isTrue);
      final persisted = res.getOrElse(() => throw StateError('expected Ok'));
      expect(persisted.id, isNotNull);
      expect(persisted.id, isNotEmpty);
      expect(persisted.patientId, 'patient-a');
      expect(persisted.value, 0.5102);
      expect(persisted.createdAt, DateTime(2026, 9, 19));
      expect(persisted.inputParams, hasLength(2));

      final readBack = await service.read(
        AppDatabaseTables.glucoseInfusionRates,
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
