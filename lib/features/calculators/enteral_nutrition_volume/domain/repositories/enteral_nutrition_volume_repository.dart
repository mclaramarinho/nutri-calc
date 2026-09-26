import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/data/models/enteral_nutrition_volume_model.dart';

abstract class EnteralNutritionVolumeRepository {
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>>
  createEnteralNutritionVolume(
    EnteralNutritionVolumeCalculationEntity enteralNutritionVolume,
  );

  Future<Result<List<EnteralNutritionVolumeModel>, String>> getEnteralNutritionVolumes(String patientId);
  Future<Result<void, String>> deleteEnteralNutritionVolume(String id);
}
