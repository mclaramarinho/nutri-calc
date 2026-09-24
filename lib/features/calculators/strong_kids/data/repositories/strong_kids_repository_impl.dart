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
}
