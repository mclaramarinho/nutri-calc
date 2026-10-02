import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/data/models/height_model.dart';
import 'package:nutri_calc/features/measurements/height/domain/repositories/height_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: HeightRepository)
class HeightRepositoryImpl implements HeightRepository {
  const HeightRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<List<HeightModel>, String>> getHeights(String patientId) async {
    try {
      final res = await _databaseService.read(
        .heights,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => HeightModel.fromJson(json)).toList());
      }

      return Error("Error getting heights for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<HeightModel, String>> createHeight({
    required double value,
    required String patientId,
    required DateTime createdAt,
  }) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting.
      // `AppDatabaseService.insert` returns the sqflite rowid (an int), not
      // the inserted row's data — calling `HeightModel.fromJson` on that raw
      // int used to throw here, get swallowed by this method's own
      // try/catch, and silently return `Error` on every real height
      // creation. Returning the locally-built model on success avoids the
      // bogus round-trip through `fromJson(rowid)`.
      final model = HeightModel(
        value: value,
        createdAt: createdAt,
        patientId: patientId,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(.heights, model.toJson());

      if (res.isOk) {
        return Ok(model);
      }
      return Error("Error creating height.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteHeight(String id) async {
    try {
      final res = await _databaseService.delete(
        .heights,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting height.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}

