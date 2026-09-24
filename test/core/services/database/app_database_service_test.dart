import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/core/services/database/app_database_version.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/core/services/database/entities/table_sql_constraints.enum.dart';
import 'package:nutri_calc/core/services/database/entities/table_sql_field.entity.dart';
import 'package:nutri_calc/core/services/database/entities/table_sql_types.enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a fresh temp file path for each test so the ffi sqlite backend
/// doesn't reuse a database across tests.
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync('nutri_calc_db_test_');
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

/// Mirrors `AppDatabaseTables._getSqlForCreateTable` (private, so can't be
/// reused directly) using the real, production `TableSqlField.sql` getter.
String _createTableSql(String name, List<TableSqlField> fields) {
  return '''
      CREATE TABLE IF NOT EXISTS $name (
        ${fields.map((fd) => fd.sql).join(", ")}
      )
    ''';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabaseServiceImpl.init - fresh install (real schema)', () {
    test('creates every AppDatabaseTables table with all its columns', () async {
      final path = _newTempDbPath('fresh_install');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final db = await openDatabase(path);
      try {
        for (final table in AppDatabaseTables.values) {
          final columns = await db.rawQuery(
            'PRAGMA table_info(${table.name})',
          );
          final columnNames = columns.map((c) => c['name']).toSet();
          final expectedNames = table.fields.map((f) => f.name).toSet();
          expect(
            columnNames,
            equals(expectedNames),
            reason: '${table.name} should have exactly its declared columns',
          );
        }
      } finally {
        await db.close();
      }
    });

    test('fresh install allows inserting a full row into every table', () async {
      final path = _newTempDbPath('fresh_install_insert');
      final service = AppDatabaseServiceImpl();
      await service.init(dbPath: path);

      final patientResult = await service.insert(AppDatabaseTables.patient, {
        'id': 'p1',
        'patientId': 'PID-1',
        'firstName': 'Ana',
        'lastName': 'Silva',
        'birthdate': '2000-01-01',
        'age': 26,
        'ageUnit': 'years',
      });
      expect(patientResult.isOk, isTrue);

      final weightResult = await service.insert(AppDatabaseTables.weights, {
        'id': 'w1',
        'value': 70.5,
        'createdAt': '2026-09-06',
        'patientId': 'p1',
      });
      expect(weightResult.isOk, isTrue);

      final heightResult = await service.insert(AppDatabaseTables.heights, {
        'id': 'h1',
        'value': 170.0,
        'createdAt': '2026-09-06',
        'patientId': 'p1',
      });
      expect(heightResult.isOk, isTrue);

      final bodyMeasurementResult = await service.insert(
        AppDatabaseTables.bodyMeasurements,
        {
          'id': 'b1',
          'value': 30.0,
          'createdAt': '2026-09-06',
          'patientId': 'p1',
          'measurementType': 'waistCircumference',
        },
      );
      expect(bodyMeasurementResult.isOk, isTrue);
    });
  });

  group('AppDatabaseServiceImpl.init - upgrade path (real production schema)', () {
    test(
      'reopening at a higher version than kAppDatabaseVersion keeps existing data intact',
      () async {
        final path = _newTempDbPath('upgrade_same_schema');

        final first = AppDatabaseServiceImpl();
        await first.init(dbPath: path, version: 1);
        final insertResult = await first.insert(AppDatabaseTables.patient, {
          'id': 'p1',
          'patientId': 'PID-1',
          'firstName': 'Ana',
          'lastName': 'Silva',
          'birthdate': '2000-01-01',
          'age': 26,
          'ageUnit': 'years',
        });
        expect(insertResult.isOk, isTrue);

        // Reopen the same file with a newer target version. Since today's
        // production schema has nothing above sinceVersion 1, onUpgrade
        // should run without applying any ALTER/CREATE and without
        // touching existing rows.
        final second = AppDatabaseServiceImpl();
        await second.init(dbPath: path, version: 2);

        final readResult = await second.read(AppDatabaseTables.patient);
        expect(readResult.isOk, isTrue);
        readResult.when(
          ok: (rows) {
            expect(rows, hasLength(1));
            expect(rows.first['firstName'], 'Ana');
          },
          error: (_) => fail('expected Ok'),
        );
      },
    );

    test(
      'a failure opening/creating the database propagates as a thrown/rejected Future from init()',
      () async {
        // Point dbPath at something that can never be opened as a sqlite
        // file (a directory), so `openDatabase` itself fails inside
        // `init()`. This exercises init()'s "no try/catch, let it surface"
        // contract from the ADR: failures must not be swallowed.
        final dir = Directory.systemTemp.createTempSync(
          'nutri_calc_db_test_not_a_file_',
        );
        final service = AppDatabaseServiceImpl();

        await expectLater(
          service.init(dbPath: dir.path, version: 1),
          throwsA(anything),
        );
      },
    );
  });

  group(
    'PATIENT clinical boolean columns migration (real production schema, '
    'v1 -> v2)',
    () {
      test(
        'fresh install (straight at v2) creates PATIENT with all 4 boolean '
        'columns as INTEGER NOT NULL DEFAULT 0',
        () async {
          final path = _newTempDbPath('boolean_columns_fresh_v2');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 2);

          final db = await openDatabase(path);
          try {
            final columns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.patient.name})',
            );
            final byName = {
              for (final c in columns) c['name'] as String: c,
            };

            for (final name in [
              'enteralNutrition',
              'parenteralNutrition',
              'hospitalized',
              'confinedToBed',
            ]) {
              expect(byName.containsKey(name), isTrue, reason: name);
              expect(byName[name]!['type'], 'INTEGER', reason: name);
              expect(byName[name]!['notnull'], 1, reason: name);
              expect(byName[name]!['dflt_value'], '0', reason: name);
            }
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v1 PATIENT row upgrading to v2 gets the 4 new columns '
        'added, defaulting existing rows to 0/false, without crashing '
        'PatientModel.fromJson',
        () async {
          final path = _newTempDbPath('boolean_columns_upgrade_v1_to_v2');

          // Seed at v1: PATIENT table exists without the 4 new columns.
          final v1Service = AppDatabaseServiceImpl();
          await v1Service.init(dbPath: path, version: 1);
          final insertResult = await v1Service.insert(
            AppDatabaseTables.patient,
            {
              'id': 'p1',
              'patientId': 'PID-1',
              'firstName': 'Ana',
              'lastName': 'Silva',
              'birthdate': '2000-01-01',
              'age': 26,
              // Must match a `TimeUnit` enum name ('day'/'month'/'year') for
              // `PatientModel.fromJson` below to decode it; 'years' is not a
              // valid enum name.
              'ageUnit': 'year',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v2 - onUpgrade must ALTER TABLE ADD COLUMN for the 4
          // new fields.
          final v2Service = AppDatabaseServiceImpl();
          await v2Service.init(dbPath: path, version: 2);

          // Opened with `singleInstance: false` so that closing this
          // inspection-only connection doesn't tear down the shared,
          // path-cached connection `v2Service` still needs for the `read`
          // call below (sqflite caches `openDatabase` by path when
          // `singleInstance: true`, its default).
          final db = await openDatabase(path, singleInstance: false);
          try {
            final columns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.patient.name})',
            );
            final columnNames = columns.map((c) => c['name']).toSet();
            expect(
              columnNames,
              containsAll([
                'enteralNutrition',
                'parenteralNutrition',
                'hospitalized',
                'confinedToBed',
              ]),
            );
          } finally {
            await db.close();
          }

          final readResult = await v2Service.read(
            AppDatabaseTables.patient,
            where: 'id = ?',
            whereArgs: ['p1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              final row = rows.first;
              expect(row['firstName'], 'Ana', reason: 'pre-existing data intact');
              // Pre-existing row should default to 0 (false) for all 4
              // new columns, not null/crash.
              expect(row['enteralNutrition'], 0);
              expect(row['parenteralNutrition'], 0);
              expect(row['hospitalized'], 0);
              expect(row['confinedToBed'], 0);

              // Must decode through PatientModel.fromJson without throwing,
              // and all 4 flags must read back as false.
              final model = PatientModel.fromJson(row);
              expect(model.enteralNutrition, isFalse);
              expect(model.parenteralNutrition, isFalse);
              expect(model.hospitalized, isFalse);
              expect(model.confinedToBed, isFalse);
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group(
    'WEIGHTS/BMI columns migration (real production schema, v2 -> v3)',
    () {
      test(
        'fresh install (straight at v3) creates WEIGHTS with the 2 new '
        'columns and the BMI table in their final shape',
        () async {
          final path = _newTempDbPath('weights_bmi_fresh_v3');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 3);

          final db = await openDatabase(path);
          try {
            final weightColumns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.weights.name})',
            );
            final byName = {
              for (final c in weightColumns) c['name'] as String: c,
            };

            expect(byName.containsKey('considerForCalculations'), isTrue);
            expect(byName['considerForCalculations']!['type'], 'INTEGER');
            expect(byName['considerForCalculations']!['notnull'], 1);
            expect(byName['considerForCalculations']!['dflt_value'], '1');

            expect(byName.containsKey('weightType'), isTrue);
            expect(byName['weightType']!['type'], 'TEXT');
            expect(byName['weightType']!['notnull'], 1);
            expect(
              byName['weightType']!['dflt_value'],
              "'measuredByScale'",
            );

            final bmiTables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='BMI'",
            );
            expect(bmiTables, hasLength(1));

            final bmiColumns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.bmi.name})',
            );
            expect(
              bmiColumns.map((c) => c['name']).toSet(),
              AppDatabaseTables.bmi.fields.map((f) => f.name).toSet(),
            );
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v2 WEIGHTS row upgrading to v3 gets the 2 new columns '
        'added, defaulting to considerForCalculations=1/weightType='
        "'measuredByScale', without crashing WeightModel.fromJson",
        () async {
          final path = _newTempDbPath('weights_bmi_upgrade_v2_to_v3');

          // Seed at v2: WEIGHTS table exists without the 2 new columns
          // (BMI does not exist at all yet, sinceVersion 3).
          final v2Service = AppDatabaseServiceImpl();
          await v2Service.init(dbPath: path, version: 2);
          final insertResult = await v2Service.insert(
            AppDatabaseTables.weights,
            {
              'id': 'w1',
              'value': 70.5,
              'createdAt': '2026-09-06',
              'patientId': 'p1',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v3 - onUpgrade must ALTER TABLE ADD COLUMN for the 2
          // new WEIGHTS fields, and CREATE TABLE BMI whole (it didn't exist
          // at oldVersion 2 - exercises onUpgrade's "table didn't exist at
          // oldVersion" branch, not onCreate's fresh-install branch).
          final v3Service = AppDatabaseServiceImpl();
          await v3Service.init(dbPath: path, version: 3);

          // Opened with `singleInstance: false` so that closing this
          // inspection-only connection doesn't tear down the shared,
          // path-cached connection `v3Service` still needs below.
          final db = await openDatabase(path, singleInstance: false);
          try {
            final weightColumns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.weights.name})',
            );
            final weightColumnNames = weightColumns
                .map((c) => c['name'])
                .toSet();
            expect(
              weightColumnNames,
              containsAll(['considerForCalculations', 'weightType']),
            );

            final bmiTables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='BMI'",
            );
            expect(
              bmiTables,
              hasLength(1),
              reason:
                  'BMI table must be created via onUpgrade, not just onCreate',
            );
          } finally {
            await db.close();
          }

          final readResult = await v3Service.read(
            AppDatabaseTables.weights,
            where: 'id = ?',
            whereArgs: ['w1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              final row = rows.first;
              expect(row['value'], 70.5, reason: 'pre-existing data intact');
              // Pre-existing row should default to 1 (true) / 'measuredByScale'
              // for the 2 new columns, not null/crash.
              expect(row['considerForCalculations'], 1);
              expect(row['weightType'], 'measuredByScale');

              final model = WeightModel.fromJson(row);
              expect(model.considerForCalculations, isTrue);
              expect(model.weightType, WeightTypeEnum.measuredByScale);
            },
            error: (_) => fail('expected Ok'),
          );

          // The new BMI table, created via onUpgrade's "table didn't exist
          // at oldVersion" branch, must actually be usable for real
          // insert/read - not just present in the schema.
          final bmiInsertResult = await v3Service.insert(
            AppDatabaseTables.bmi,
            {
              'id': 'bmi1',
              'patientId': 'p1',
              'value': 24.4,
              'classification': 'eutrophy',
              'createdAt': '2026-09-19',
              'inputParams': '[]',
            },
          );
          expect(bmiInsertResult.isOk, isTrue);

          final bmiReadResult = await v3Service.read(
            AppDatabaseTables.bmi,
            where: 'id = ?',
            whereArgs: ['bmi1'],
          );
          expect(bmiReadResult.isOk, isTrue);
          bmiReadResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
              expect(rows.first['classification'], 'eutrophy');
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group(
    'ENERGY_EXPENDITURES table migration (real production schema, v3 -> v4)',
    () {
      test(
        'fresh install (straight at v4) creates ENERGY_EXPENDITURES with all '
        'its declared columns',
        () async {
          final path = _newTempDbPath('energy_expenditures_fresh_v4');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 4);

          final db = await openDatabase(path);
          try {
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='ENERGY_EXPENDITURES'",
            );
            expect(tables, hasLength(1));

            final columns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.energyExpenditures.name})',
            );
            expect(
              columns.map((c) => c['name']).toSet(),
              AppDatabaseTables.energyExpenditures.fields
                  .map((f) => f.name)
                  .toSet(),
            );
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v3 database upgrading to v4 gets the ENERGY_EXPENDITURES '
        'table created whole (it did not exist at oldVersion 3), and it is '
        'usable for real insert/read',
        () async {
          final path = _newTempDbPath('energy_expenditures_upgrade_v3_to_v4');

          // Seed at v3: ENERGY_EXPENDITURES does not exist yet (sinceVersion 4),
          // but BMI (sinceVersion 3) and the base tables do.
          final v3Service = AppDatabaseServiceImpl();
          await v3Service.init(dbPath: path, version: 3);
          final insertResult = await v3Service.insert(
            AppDatabaseTables.patient,
            {
              'id': 'p1',
              'patientId': 'PID-1',
              'firstName': 'Ana',
              'lastName': 'Silva',
              'birthdate': '2000-01-01',
              'age': 26,
              'ageUnit': 'year',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v4 - onUpgrade must CREATE TABLE ENERGY_EXPENDITURES
          // whole (it didn't exist at oldVersion 3 - exercises onUpgrade's
          // "table didn't exist at oldVersion" branch, not onCreate's
          // fresh-install branch), mirroring BMI's v2->v3 migration test.
          final v4Service = AppDatabaseServiceImpl();
          await v4Service.init(dbPath: path, version: 4);

          // Opened with `singleInstance: false` so that closing this
          // inspection-only connection doesn't tear down the shared,
          // path-cached connection `v4Service` still needs below.
          final db = await openDatabase(path, singleInstance: false);
          try {
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='ENERGY_EXPENDITURES'",
            );
            expect(
              tables,
              hasLength(1),
              reason:
                  'ENERGY_EXPENDITURES table must be created via onUpgrade, '
                  'not just onCreate',
            );
          } finally {
            await db.close();
          }

          final readResult = await v4Service.read(
            AppDatabaseTables.patient,
            where: 'id = ?',
            whereArgs: ['p1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['firstName'], 'Ana', reason: 'pre-existing data intact');
            },
            error: (_) => fail('expected Ok'),
          );

          // The new table, created via onUpgrade's "table didn't exist at
          // oldVersion" branch, must actually be usable for real
          // insert/read - not just present in the schema.
          final insertEnergyExpenditureResult = await v4Service.insert(
            AppDatabaseTables.energyExpenditures,
            {
              'id': 'ee1',
              'patientId': 'p1',
              'formula': 'pocket',
              'minValue': 1540.0,
              'maxValue': 1750.0,
              'createdAt': '2026-09-19',
              'inputParams': '[]',
            },
          );
          expect(insertEnergyExpenditureResult.isOk, isTrue);

          final readEnergyExpenditureResult = await v4Service.read(
            AppDatabaseTables.energyExpenditures,
            where: 'id = ?',
            whereArgs: ['ee1'],
          );
          expect(readEnergyExpenditureResult.isOk, isTrue);
          readEnergyExpenditureResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
              expect(rows.first['formula'], 'pocket');
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group(
    'NITROGEN_BALANCES/PROTEIN_NEEDS/WATER_NEEDS tables migration (real '
    'production schema, v4 -> v5)',
    () {
      test(
        'fresh install (straight at v5) creates all three new tables with '
        'all their declared columns',
        () async {
          final path = _newTempDbPath('slice4_tables_fresh_v5');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 5);

          final db = await openDatabase(path);
          try {
            for (final table in [
              AppDatabaseTables.nitrogenBalances,
              AppDatabaseTables.proteinNeeds,
              AppDatabaseTables.waterNeeds,
            ]) {
              final tables = await db.rawQuery(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='${table.name}'",
              );
              expect(tables, hasLength(1), reason: '${table.name} must exist');

              final columns = await db.rawQuery(
                'PRAGMA table_info(${table.name})',
              );
              expect(
                columns.map((c) => c['name']).toSet(),
                table.fields.map((f) => f.name).toSet(),
                reason: '${table.name} columns must match its declared fields',
              );
            }
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v4 database upgrading to v5 gets NITROGEN_BALANCES, '
        'PROTEIN_NEEDS and WATER_NEEDS created whole (they did not exist at '
        'oldVersion 4), and each is usable for real insert/read',
        () async {
          final path = _newTempDbPath('slice4_tables_upgrade_v4_to_v5');

          // Seed at v4: the new tables do not exist yet (sinceVersion 5), but
          // BMI/ENERGY_EXPENDITURES and the base tables do.
          final v4Service = AppDatabaseServiceImpl();
          await v4Service.init(dbPath: path, version: 4);
          final insertResult = await v4Service.insert(
            AppDatabaseTables.patient,
            {
              'id': 'p1',
              'patientId': 'PID-1',
              'firstName': 'Ana',
              'lastName': 'Silva',
              'birthdate': '2000-01-01',
              'age': 26,
              'ageUnit': 'year',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v5 - onUpgrade must CREATE TABLE each of the new
          // tables whole (they didn't exist at oldVersion 4 - exercises
          // onUpgrade's "table didn't exist at oldVersion" branch, mirroring
          // ENERGY_EXPENDITURES's v3->v4 migration test).
          final v5Service = AppDatabaseServiceImpl();
          await v5Service.init(dbPath: path, version: 5);

          // Opened with `singleInstance: false` so that closing this
          // inspection-only connection doesn't tear down the shared,
          // path-cached connection `v5Service` still needs below.
          final db = await openDatabase(path, singleInstance: false);
          try {
            for (final table in [
              AppDatabaseTables.nitrogenBalances,
              AppDatabaseTables.proteinNeeds,
              AppDatabaseTables.waterNeeds,
            ]) {
              final tables = await db.rawQuery(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='${table.name}'",
              );
              expect(
                tables,
                hasLength(1),
                reason:
                    '${table.name} table must be created via onUpgrade, '
                    'not just onCreate',
              );
            }
          } finally {
            await db.close();
          }

          final readResult = await v5Service.read(
            AppDatabaseTables.patient,
            where: 'id = ?',
            whereArgs: ['p1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['firstName'], 'Ana', reason: 'pre-existing data intact');
            },
            error: (_) => fail('expected Ok'),
          );

          // Each new table, created via onUpgrade's "table didn't exist at
          // oldVersion" branch, must actually be usable for real
          // insert/read - not just present in the schema.
          final insertNitrogenBalanceResult = await v5Service.insert(
            AppDatabaseTables.nitrogenBalances,
            {
              'id': 'nb1',
              'patientId': 'p1',
              'value': 2.5,
              'createdAt': '2026-09-19',
              'inputParams': '[]',
            },
          );
          expect(insertNitrogenBalanceResult.isOk, isTrue);

          final readNitrogenBalanceResult = await v5Service.read(
            AppDatabaseTables.nitrogenBalances,
            where: 'id = ?',
            whereArgs: ['nb1'],
          );
          expect(readNitrogenBalanceResult.isOk, isTrue);
          readNitrogenBalanceResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );

          final insertProteinNeedsResult = await v5Service.insert(
            AppDatabaseTables.proteinNeeds,
            {
              'id': 'pn1',
              'patientId': 'p1',
              'minValue': 56.0,
              'maxValue': 70.0,
              'createdAt': '2026-09-19',
              'inputParams': '[]',
            },
          );
          expect(insertProteinNeedsResult.isOk, isTrue);

          final readProteinNeedsResult = await v5Service.read(
            AppDatabaseTables.proteinNeeds,
            where: 'id = ?',
            whereArgs: ['pn1'],
          );
          expect(readProteinNeedsResult.isOk, isTrue);
          readProteinNeedsResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );

          final insertWaterNeedsResult = await v5Service.insert(
            AppDatabaseTables.waterNeeds,
            {
              'id': 'wn1',
              'patientId': 'p1',
              'value': 2100.0,
              'createdAt': '2026-09-19',
              'inputParams': '[]',
            },
          );
          expect(insertWaterNeedsResult.isOk, isTrue);

          final readWaterNeedsResult = await v5Service.read(
            AppDatabaseTables.waterNeeds,
            where: 'id = ?',
            whereArgs: ['wn1'],
          );
          expect(readWaterNeedsResult.isOk, isTrue);
          readWaterNeedsResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group(
    'SCREENING_MUST/SCREENING_NRS_2002/SCREENING_STRONG_KIDS tables '
    'migration (real production schema, v7 -> v8)',
    () {
      test(
        'fresh install (straight at v8) creates all three new screening '
        'tables with all their declared columns',
        () async {
          final path = _newTempDbPath('slice7_tables_fresh_v8');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 8);

          final db = await openDatabase(path);
          try {
            for (final table in [
              AppDatabaseTables.screeningMust,
              AppDatabaseTables.screeningNrs2002,
              AppDatabaseTables.screeningStrongKids,
            ]) {
              final tables = await db.rawQuery(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='${table.name}'",
              );
              expect(tables, hasLength(1), reason: '${table.name} must exist');

              final columns = await db.rawQuery(
                'PRAGMA table_info(${table.name})',
              );
              expect(
                columns.map((c) => c['name']).toSet(),
                table.fields.map((f) => f.name).toSet(),
                reason: '${table.name} columns must match its declared fields',
              );
            }
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v7 database upgrading to v8 gets SCREENING_MUST, '
        'SCREENING_NRS_2002 and SCREENING_STRONG_KIDS created whole (they '
        'did not exist at oldVersion 7), and each is usable for real '
        'insert/read',
        () async {
          final path = _newTempDbPath('slice7_tables_upgrade_v7_to_v8');

          // Seed at v7: the new screening tables do not exist yet
          // (sinceVersion 8), but WEIGHT_LOSS_CLASSIFICATIONS and the base
          // tables do.
          final v7Service = AppDatabaseServiceImpl();
          await v7Service.init(dbPath: path, version: 7);
          final insertResult = await v7Service.insert(
            AppDatabaseTables.patient,
            {
              'id': 'p1',
              'patientId': 'PID-1',
              'firstName': 'Ana',
              'lastName': 'Silva',
              'birthdate': '2000-01-01',
              'age': 26,
              'ageUnit': 'year',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v8 - onUpgrade must CREATE TABLE each of the new
          // screening tables whole (they didn't exist at oldVersion 7 -
          // exercises onUpgrade's "table didn't exist at oldVersion" branch,
          // mirroring NITROGEN_BALANCES/PROTEIN_NEEDS/WATER_NEEDS's v4->v5
          // migration test).
          final v8Service = AppDatabaseServiceImpl();
          await v8Service.init(dbPath: path, version: 8);

          // Opened with `singleInstance: false` so that closing this
          // inspection-only connection doesn't tear down the shared,
          // path-cached connection `v8Service` still needs below.
          final db = await openDatabase(path, singleInstance: false);
          try {
            for (final table in [
              AppDatabaseTables.screeningMust,
              AppDatabaseTables.screeningNrs2002,
              AppDatabaseTables.screeningStrongKids,
            ]) {
              final tables = await db.rawQuery(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='${table.name}'",
              );
              expect(
                tables,
                hasLength(1),
                reason:
                    '${table.name} table must be created via onUpgrade, '
                    'not just onCreate',
              );
            }
          } finally {
            await db.close();
          }

          final readResult = await v8Service.read(
            AppDatabaseTables.patient,
            where: 'id = ?',
            whereArgs: ['p1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['firstName'], 'Ana', reason: 'pre-existing data intact');
            },
            error: (_) => fail('expected Ok'),
          );

          // Each new table, created via onUpgrade's "table didn't exist at
          // oldVersion" branch, must actually be usable for real
          // insert/read - not just present in the schema.
          final insertMustResult = await v8Service.insert(
            AppDatabaseTables.screeningMust,
            {
              'id': 'must1',
              'patientId': 'p1',
              'score': 0,
              'scoreStep1': 0,
              'scoreStep2': 0,
              'scoreStep3': 0,
              'classification': 'lowRisk',
              'createdAt': '2026-09-22',
              'inputParams': '[]',
            },
          );
          expect(insertMustResult.isOk, isTrue);

          final readMustResult = await v8Service.read(
            AppDatabaseTables.screeningMust,
            where: 'id = ?',
            whereArgs: ['must1'],
          );
          expect(readMustResult.isOk, isTrue);
          readMustResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );

          final insertNrs2002Result = await v8Service.insert(
            AppDatabaseTables.screeningNrs2002,
            {
              'id': 'nrs1',
              'patientId': 'p1',
              'score': 3,
              'createdAt': '2026-09-22',
              'inputParams': '[]',
            },
          );
          expect(insertNrs2002Result.isOk, isTrue);

          final readNrs2002Result = await v8Service.read(
            AppDatabaseTables.screeningNrs2002,
            where: 'id = ?',
            whereArgs: ['nrs1'],
          );
          expect(readNrs2002Result.isOk, isTrue);
          readNrs2002Result.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );

          final insertStrongKidsResult = await v8Service.insert(
            AppDatabaseTables.screeningStrongKids,
            {
              'id': 'sk1',
              'patientId': 'p1',
              'score': 0,
              'classification': 'low',
              'createdAt': '2026-09-22',
              'inputParams': '[]',
            },
          );
          expect(insertStrongKidsResult.isOk, isTrue);

          final readStrongKidsResult = await v8Service.read(
            AppDatabaseTables.screeningStrongKids,
            where: 'id = ?',
            whereArgs: ['sk1'],
          );
          expect(readStrongKidsResult.isOk, isTrue);
          readStrongKidsResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              expect(rows.first['patientId'], 'p1');
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group(
    'WEIGHTS inputParams column migration (real production schema, v8 -> v9)',
    () {
      test(
        'fresh install (straight at v9) creates WEIGHTS with the '
        'inputParams column',
        () async {
          final path = _newTempDbPath('weights_input_params_fresh_v9');
          final service = AppDatabaseServiceImpl();
          await service.init(dbPath: path, version: 9);

          final db = await openDatabase(path);
          try {
            final weightColumns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.weights.name})',
            );
            final byName = {
              for (final c in weightColumns) c['name'] as String: c,
            };

            expect(byName.containsKey('inputParams'), isTrue);
            expect(byName['inputParams']!['type'], 'TEXT');
            expect(byName['inputParams']!['notnull'], 1);
            expect(byName['inputParams']!['dflt_value'], "'[]'");
          } finally {
            await db.close();
          }
        },
      );

      test(
        'an existing v8 WEIGHTS row upgrading to v9 gets inputParams '
        "backfilled to '[]', without crashing WeightModel.fromJson",
        () async {
          final path = _newTempDbPath('weights_input_params_upgrade_v8_to_v9');

          // Seed at v8: WEIGHTS table exists without the inputParams column.
          final v8Service = AppDatabaseServiceImpl();
          await v8Service.init(dbPath: path, version: 8);
          final insertResult = await v8Service.insert(
            AppDatabaseTables.weights,
            {
              'id': 'w1',
              'value': 70.5,
              'createdAt': '2026-09-06',
              'patientId': 'p1',
              'considerForCalculations': 1,
              'weightType': 'measuredByScale',
            },
          );
          expect(insertResult.isOk, isTrue);

          // Reopen at v9 - onUpgrade must ALTER TABLE ADD COLUMN for the new
          // WEIGHTS field.
          final v9Service = AppDatabaseServiceImpl();
          await v9Service.init(dbPath: path, version: 9);

          final db = await openDatabase(path, singleInstance: false);
          try {
            final weightColumns = await db.rawQuery(
              'PRAGMA table_info(${AppDatabaseTables.weights.name})',
            );
            final weightColumnNames = weightColumns
                .map((c) => c['name'])
                .toSet();
            expect(weightColumnNames, contains('inputParams'));
          } finally {
            await db.close();
          }

          final readResult = await v9Service.read(
            AppDatabaseTables.weights,
            where: 'id = ?',
            whereArgs: ['w1'],
          );
          expect(readResult.isOk, isTrue);
          readResult.when(
            ok: (rows) {
              expect(rows, hasLength(1));
              final row = rows.first;
              expect(row['value'], 70.5, reason: 'pre-existing data intact');
              // Pre-existing row should default to '[]' for the new column,
              // not null/crash.
              expect(row['inputParams'], '[]');

              final model = WeightModel.fromJson(row);
              expect(model.inputParams, isEmpty);
            },
            error: (_) => fail('expected Ok'),
          );
        },
      );
    },
  );

  group('Migration mechanics (onCreate/onUpgrade algorithm) against a versioned fixture', () {
    // Local fixture mirroring AppDatabaseTables' shape: a "patient"-like
    // table that exists since v1 and gains a column at v2, plus a brand new
    // table introduced at v2. Field/table definitions use the real,
    // production `TableSqlField` class (and its real `.sql`/`.addColumnSql`
    // getters) so the SQL actually executed is production code; only the
    // outer "for each table/field, decide CREATE vs ALTER" loop is
    // reproduced here, mirroring `AppDatabaseServiceImpl.init()`'s
    // onCreate/onUpgrade closures 1:1, since that loop is not exposed for
    // reuse outside of `AppDatabaseTables.values`.
    const fixtureTables = {
      'PATIENT_FIXTURE': 1,
      'SETTINGS_FIXTURE': 2,
    };

    List<TableSqlField> fieldsFor(String tableName) {
      switch (tableName) {
        case 'PATIENT_FIXTURE':
          return [
            TableSqlField(
              name: 'id',
              type: TableSqlTypes.text,
              constraints: [TableSqlConstraints.primaryKey],
            ),
            TableSqlField(
              name: 'firstName',
              type: TableSqlTypes.text,
              constraints: [TableSqlConstraints.notNull],
            ),
            TableSqlField(
              name: 'email',
              type: TableSqlTypes.text,
              constraints: [TableSqlConstraints.notNull],
              sinceVersion: 2,
              defaultValue: 'unknown@example.com',
            ),
          ];
        case 'SETTINGS_FIXTURE':
          return [
            TableSqlField(
              name: 'id',
              type: TableSqlTypes.text,
              constraints: [TableSqlConstraints.primaryKey],
              sinceVersion: 2,
            ),
            TableSqlField(
              name: 'darkMode',
              type: TableSqlTypes.integer,
              sinceVersion: 2,
            ),
          ];
        default:
          throw ArgumentError(tableName);
      }
    }

    Future<void> onCreateFixture(Database db, int version) async {
      for (final entry in fixtureTables.entries) {
        if (entry.value > version) continue;
        final tableName = entry.key;
        final fieldsAtVersion = fieldsFor(
          tableName,
        ).where((f) => f.sinceVersion <= version).toList();
        await db.execute(_createTableSql(tableName, fieldsAtVersion));
      }
    }

    Future<void> onUpgradeFixture(
      Database db,
      int oldVersion,
      int newVersion,
    ) async {
      for (final entry in fixtureTables.entries) {
        final tableName = entry.key;
        final tableSinceVersion = entry.value;
        if (tableSinceVersion > oldVersion) {
          await db.execute(
            _createTableSql(tableName, fieldsFor(tableName)),
          );
          continue;
        }
        for (final field in fieldsFor(tableName)) {
          if (field.sinceVersion > oldVersion &&
              field.sinceVersion <= newVersion) {
            await db.execute(
              'ALTER TABLE $tableName ADD COLUMN ${field.addColumnSql}',
            );
          }
        }
      }
    }

    test(
      'upgrading from v1 to v2 adds the new column with its default value '
      'and keeps existing rows intact, without touching unrelated tables',
      () async {
        final path = _newTempDbPath('mechanics_upgrade');

        // Seed at v1: only PATIENT_FIXTURE exists, no `email` column yet.
        final dbV1 = await openDatabase(
          path,
          version: 1,
          onCreate: onCreateFixture,
        );
        await dbV1.insert('PATIENT_FIXTURE', {
          'id': 'p1',
          'firstName': 'Ana',
        });
        await dbV1.close();

        // Upgrade to v2: PATIENT_FIXTURE gains `email` (with default),
        // SETTINGS_FIXTURE is created whole.
        final dbV2 = await openDatabase(
          path,
          version: 2,
          onCreate: onCreateFixture,
          onUpgrade: onUpgradeFixture,
        );

        final patientColumns = await dbV2.rawQuery(
          'PRAGMA table_info(PATIENT_FIXTURE)',
        );
        expect(
          patientColumns.map((c) => c['name']).toSet(),
          {'id', 'firstName', 'email'},
        );

        final patientRows = await dbV2.query('PATIENT_FIXTURE');
        expect(patientRows, hasLength(1));
        expect(patientRows.first['id'], 'p1');
        expect(patientRows.first['firstName'], 'Ana');
        expect(patientRows.first['email'], 'unknown@example.com');

        final settingsTables = await dbV2.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='SETTINGS_FIXTURE'",
        );
        expect(settingsTables, hasLength(1));

        final settingsColumns = await dbV2.rawQuery(
          'PRAGMA table_info(SETTINGS_FIXTURE)',
        );
        expect(
          settingsColumns.map((c) => c['name']).toSet(),
          {'id', 'darkMode'},
        );

        await dbV2.close();
      },
    );

    test(
      'fresh install straight at v2 creates both tables in their final shape',
      () async {
        final path = _newTempDbPath('mechanics_fresh_v2');

        final db = await openDatabase(
          path,
          version: 2,
          onCreate: onCreateFixture,
          onUpgrade: onUpgradeFixture,
        );

        for (final tableName in fixtureTables.keys) {
          final columns = await db.rawQuery('PRAGMA table_info($tableName)');
          expect(
            columns.map((c) => c['name']).toSet(),
            fieldsFor(tableName).map((f) => f.name).toSet(),
          );
        }

        await db.close();
      },
    );
  });

  group('TableSqlField.addColumnSql guards (migration failure must not be swallowed)', () {
    test(
      'throws an assertion error when a NOT NULL column has no defaultValue',
      () {
        const field = TableSqlField(
          name: 'email',
          type: TableSqlTypes.text,
          constraints: [TableSqlConstraints.notNull],
          sinceVersion: 2,
        );

        expect(() => field.addColumnSql, throwsA(isA<ArgumentError>()));
      },
    );

    test('throws an assertion error when trying to add a PRIMARY KEY column', () {
      const field = TableSqlField(
        name: 'id',
        type: TableSqlTypes.text,
        constraints: [TableSqlConstraints.primaryKey],
        sinceVersion: 2,
      );

      expect(() => field.addColumnSql, throwsA(isA<ArgumentError>()));
    });

    test('throws an assertion error when trying to add a UNIQUE column', () {
      const field = TableSqlField(
        name: 'email',
        type: TableSqlTypes.text,
        constraints: [TableSqlConstraints.unique],
        sinceVersion: 2,
      );

      expect(() => field.addColumnSql, throwsA(isA<ArgumentError>()));
    });

    test(
      'produces a valid ADD COLUMN definition for a NOT NULL column with a default',
      () {
        const field = TableSqlField(
          name: 'email',
          type: TableSqlTypes.text,
          constraints: [TableSqlConstraints.notNull],
          sinceVersion: 2,
          defaultValue: 'unknown@example.com',
        );

        expect(field.addColumnSql, contains('email TEXT'));
        expect(field.addColumnSql, contains('NOT NULL'));
        expect(field.addColumnSql, contains("DEFAULT 'unknown@example.com'"));
      },
    );

    test('produces a valid ADD COLUMN definition for a nullable column with no default', () {
      const field = TableSqlField(
        name: 'notes',
        type: TableSqlTypes.text,
        sinceVersion: 2,
      );

      expect(field.addColumnSql.trim(), 'notes TEXT');
    });
  });

  test('kAppDatabaseVersion is a positive integer (sanity check)', () {
    expect(kAppDatabaseVersion, greaterThanOrEqualTo(1));
  });
}
