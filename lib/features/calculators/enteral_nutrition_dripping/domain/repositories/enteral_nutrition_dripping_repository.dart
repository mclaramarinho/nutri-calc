import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';

abstract class EnteralNutritionDrippingRepository {
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>>
  createEnteralNutritionDripping(
    EnteralNutritionDrippingCalculationEntity enteralNutritionDripping,
  );
}
