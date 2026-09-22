import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';

abstract class EnteralNutritionVolumeRepository {
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>>
  createEnteralNutritionVolume(
    EnteralNutritionVolumeCalculationEntity enteralNutritionVolume,
  );
}
