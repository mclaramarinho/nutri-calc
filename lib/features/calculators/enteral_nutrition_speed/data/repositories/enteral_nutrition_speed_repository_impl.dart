import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/data/models/enteral_nutrition_speed_model.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/repositories/enteral_nutrition_speed_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: EnteralNutritionSpeedRepository)
class EnteralNutritionSpeedRepositoryImpl
    implements EnteralNutritionSpeedRepository {
  const EnteralNutritionSpeedRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>>
  createEnteralNutritionSpeed(
    EnteralNutritionSpeedCalculationEntity enteralNutritionSpeed,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = EnteralNutritionSpeedModel.fromEntity(
        enteralNutritionSpeed,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .enteralNutritionSpeed,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Enteral Nutrition Speed calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
