import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/data/models/enteral_nutrition_speed_model.dart';

abstract class EnteralNutritionSpeedRepository {
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>>
  createEnteralNutritionSpeed(
    EnteralNutritionSpeedCalculationEntity enteralNutritionSpeed,
  );

  Future<Result<List<EnteralNutritionSpeedModel>, String>> getEnteralNutritionSpeeds(String patientId);
  Future<Result<void, String>> deleteEnteralNutritionSpeed(String id);
}
