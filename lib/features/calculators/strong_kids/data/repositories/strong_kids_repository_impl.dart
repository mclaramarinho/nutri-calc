import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/strong_kids/data/models/strong_kids_model.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/repositories/strong_kids_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: StrongKidsRepository)
class StrongKidsRepositoryImpl implements StrongKidsRepository {
  const StrongKidsRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<StrongKidsCalculationEntity, String>>
  createStrongKidsCalculation(StrongKidsCalculationEntity strongKids) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors
      // `WeightLossClassificationRepositoryImpl`: the DB service's `insert`
      // only returns the sqflite rowid (an int), not the row's data, so
      // round-tripping through `fromJson(rowid)` would throw.
      final model = StrongKidsModel.fromEntity(strongKids, id: Uuid().v4());

      final res = await _databaseService.insert(
        .screeningStrongKids,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating STRONG-Kids calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<List<StrongKidsModel>, String>> getStrongKidsCalculations(String patientId) async {
    try {
      final res = await _databaseService.read(
        .screeningStrongKids,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => StrongKidsModel.fromJson(json)).toList());
      }

      return Error("Error getting strong kids history for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteStrongKidsCalculation(String id) async {
    try {
      final res = await _databaseService.delete(
        .screeningStrongKids,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting strong kids calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
