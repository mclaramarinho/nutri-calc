import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/core/services/database/app_database_version.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:sqflite/sqflite.dart';

abstract class AppDatabaseService {
  Future<void> init({String? dbPath, int? version});

  Future<Result<List<Map<String, Object?>>, String>> read(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
    String? orderBy,
    int? limit,
  });

  Future<Result<int, String>> insert(
    AppDatabaseTables table,
    Map<String, Object?> values,
  );

  Future<Result<int, String>> update(
    AppDatabaseTables table, {
    required Map<String, Object?> values,
    String? where,
    List<Object>? whereArgs,
  });

  Future<Result<int, String>> delete(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
  });
}

@Singleton(as: AppDatabaseService)
class AppDatabaseServiceImpl implements AppDatabaseService {
  late Database _db;

  AppDatabaseServiceImpl();

  @override
  Future<void> init({String? dbPath, int? version}) async {
    final path = dbPath ?? "nutri_calc.db";
    final targetVersion = version ?? kAppDatabaseVersion;

    _db = await openDatabase(
      path,
      version: targetVersion,
      onCreate: (db, version) async {
        // Fresh install
        for (final table in AppDatabaseTables.values) {
          await db.execute(table.sql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (final table in AppDatabaseTables.values) {
          if (table.sinceVersion > oldVersion) {
            // Table didn't exist at oldVersion — create it whole at its
            // current shape.
            await db.execute(table.sql);
            continue;
          }
          // Table already existed — apply only the columns introduced
          // since oldVersion.
          for (final field in table.fields) {
            if (field.sinceVersion > oldVersion &&
                field.sinceVersion <= newVersion) {
              await db.execute(
                "ALTER TABLE ${table.name} ADD COLUMN ${field.addColumnSql}",
              );
            }
          }
        }
      },
    );
  }

  @override
  Future<Result<List<Map<String, Object?>>, String>> read(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final List<Map<String, Object?>> res = await _db.query(
        table.name,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );

      return Ok(res);
    } catch (err) {
      return Error(err.toString());
    }
  }

  @override
  Future<Result<int, String>> insert(
    AppDatabaseTables table,
    Map<String, Object?> values,
  ) async {
    try {
      final res = await _db.insert(table.name, values);
      if (res == 0) {
        return Error("DB_ERROR - INSERT - Did not insert");
      }
      return Ok(res);
    } catch (err) {
      return Error(err.toString());
    }
  }

  @override
  Future<Result<int, String>> update(
    AppDatabaseTables table, {
    required Map<String, Object?> values,
    String? where,
    List<Object>? whereArgs,
  }) async {
    try {
      final res = await _db.update(
        table.name,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      if (res == 0) {
        return Error("DB_ERROR - UPDATE - Did not update");
      }
      return Ok(res);
    } catch (err) {
      return Error(err.toString());
    }
  }

  @override
  Future<Result<int, String>> delete(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    try {
      final res = await _db.delete(
        table.name,
        where: where,
        whereArgs: whereArgs,
      );

      return Ok(res);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
