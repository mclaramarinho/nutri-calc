import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/measurements/height/data/models/height_model.dart';
import 'package:nutri_calc/features/measurements/height/data/repositories/height_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mirrors `test/core/services/database/app_database_service_test.dart`'s
/// harness (real AppDatabaseServiceImpl backed by sqflite_ffi against a
/// fresh temp-file DB per test).
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync('height_repo_test_');
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'getHeights only returns rows matching the given patientId',
    () async {
      final path = _newTempDbPath('patient_filter');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      await service.insert(
        AppDatabaseTables.heights,
        HeightModel(
          id: 'h1',
          value: 170,
          createdAt: DateTime(2024, 1, 1),
          patientId: 'patient-a',
        ).toJson(),
      );
      await service.insert(
        AppDatabaseTables.heights,
        HeightModel(
          id: 'h2',
          value: 180,
          createdAt: DateTime(2024, 1, 2),
          patientId: 'patient-b',
        ).toJson(),
      );

      final repository = HeightRepositoryImpl(databaseService: service);

      final res = await repository.getHeights('patient-a');

      expect(res.isOk, isTrue);
      final values = res.getOrElse(() => <HeightModel>[]);
      expect(values, hasLength(1));
      expect(values.single.patientId, 'patient-a');
    },
  );
}
