import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/must/data/models/must_model.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/must/domain/repositories/must_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: MustRepository)
class MustRepositoryImpl implements MustRepository {
  const MustRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<MustCalculationEntity, String>> createMustCalculation(
    MustCalculationEntity must,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors
      // `WeightLossClassificationRepositoryImpl`: the DB service's `insert`
      // only returns the sqflite rowid (an int), not the row's data, so
      // round-tripping through `fromJson(rowid)` would throw.
      final model = MustModel.fromEntity(must, id: Uuid().v4());

      final res = await _databaseService.insert(.screeningMust, model.toJson());

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating MUST calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<List<MustModel>, String>> getMustCalculations(String patientId) async {
    try {
      final res = await _databaseService.read(
        .screeningMust,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => MustModel.fromJson(json)).toList());
      }

      return Error("Error getting must history for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteMustCalculation(String id) async {
    try {
      final res = await _databaseService.delete(
        .screeningMust,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting must calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
