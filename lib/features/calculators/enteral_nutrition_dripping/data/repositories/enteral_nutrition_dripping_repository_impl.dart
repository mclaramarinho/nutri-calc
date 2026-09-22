import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/data/models/enteral_nutrition_dripping_model.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/repositories/enteral_nutrition_dripping_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: EnteralNutritionDrippingRepository)
class EnteralNutritionDrippingRepositoryImpl
    implements EnteralNutritionDrippingRepository {
  const EnteralNutritionDrippingRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>>
  createEnteralNutritionDripping(
    EnteralNutritionDrippingCalculationEntity enteralNutritionDripping,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = EnteralNutritionDrippingModel.fromEntity(
        enteralNutritionDripping,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .enteralNutritionDripping,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Enteral Nutrition Dripping calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
