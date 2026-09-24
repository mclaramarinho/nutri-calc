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
}
