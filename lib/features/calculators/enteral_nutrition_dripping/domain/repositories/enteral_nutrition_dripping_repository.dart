import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/data/models/enteral_nutrition_dripping_model.dart';

abstract class EnteralNutritionDrippingRepository {
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>>
  createEnteralNutritionDripping(
    EnteralNutritionDrippingCalculationEntity enteralNutritionDripping,
  );

  Future<Result<List<EnteralNutritionDrippingModel>, String>> getEnteralNutritionDrippings(String patientId);
  Future<Result<void, String>> deleteEnteralNutritionDripping(String id);
}
