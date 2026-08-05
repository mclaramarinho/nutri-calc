import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';
import 'package:sqflite/sqflite.dart';

abstract class AppDatabaseService {
  Future<void> init();

  Future<Result<List<T>, String>> read<T>(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
    String? orderBy,
    int? limit,
    T Function(Map<String, Object?>)? mapper,
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
  Future<void> init() async {
    _db = await openDatabase("nutri_calc.db");

    // Create Tables
    for (final table in AppDatabaseTables.values) {
      await _db.execute(table.sql);
    }
  }

  @override
  Future<Result<List<T>, String>> read<T>(
    AppDatabaseTables table, {
    String? where,
    List<Object>? whereArgs,
    String? orderBy,
    int? limit,
    T Function(Map<String, Object?>)? mapper,
  }) async {
    _validateTypeMapperArgs(mapper);

    try {
      final List<Map<String, Object?>> res = await _db.query(
        table.name,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );

      if (mapper != null) {
        return Ok(res.map((el) => mapper(el)).toList());
      }

      return Ok(res as List<T>);
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

  void _validateTypeMapperArgs<T>(T Function(Map<String, Object?>)? mapper) {
    if (T is! List<Map<String, Object?>> && T != dynamic && mapper == null) {
      throw ArgumentError("Type $T requires a mapper.");
    }
  }
}
