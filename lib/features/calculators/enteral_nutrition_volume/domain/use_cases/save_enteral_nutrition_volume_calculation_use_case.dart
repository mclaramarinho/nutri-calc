import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/repositories/enteral_nutrition_volume_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_volume.usecase.dart';

abstract class SaveEnteralNutritionVolumeCalculationUseCase {
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  });
}

@Injectable(as: SaveEnteralNutritionVolumeCalculationUseCase)
class SaveEnteralNutritionVolumeCalculationUseCaseImpl
    implements SaveEnteralNutritionVolumeCalculationUseCase {
  const SaveEnteralNutritionVolumeCalculationUseCaseImpl({
    required this._repository,
  });

  final EnteralNutritionVolumeRepository _repository;

  @override
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  }) async {
    try {
      final res = CalculateEnteralNutritionVolume().call(
        totalDailyEnergy: totalDailyEnergy,
        caloricDensityOfDiet: caloricDensityOfDiet,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = EnteralNutritionVolumeCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "total_daily_energy_kcal",
            label: "Energia Diária Total (kcal)",
            value: totalDailyEnergy,
          ),
          InputParamEntity(
            key: "caloric_density_of_diet_kcal_ml",
            label: "Densidade Calórica da Dieta (kcal/mL)",
            value: caloricDensityOfDiet,
          ),
        ],
      );

      return _repository.createEnteralNutritionVolume(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
