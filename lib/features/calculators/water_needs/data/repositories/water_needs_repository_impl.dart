import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/water_needs/data/models/water_needs_model.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/repositories/water_needs_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: WaterNeedsRepository)
class WaterNeedsRepositoryImpl implements WaterNeedsRepository {
  const WaterNeedsRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<WaterNeedsCalculationEntity, String>> createWaterNeeds(
    WaterNeedsCalculationEntity waterNeeds,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = WaterNeedsModel.fromEntity(waterNeeds, id: Uuid().v4());

      final res = await _databaseService.insert(.waterNeeds, model.toJson());

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Water Needs calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
