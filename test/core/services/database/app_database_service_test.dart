import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/core/services/database/app_database_version.dart';
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
