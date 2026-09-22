import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/repositories/enteral_nutrition_speed_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_speed.usecase.dart';

abstract class SaveEnteralNutritionSpeedCalculationUseCase {
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyVolume,
  });
}

@Injectable(as: SaveEnteralNutritionSpeedCalculationUseCase)
class SaveEnteralNutritionSpeedCalculationUseCaseImpl
    implements SaveEnteralNutritionSpeedCalculationUseCase {
  const SaveEnteralNutritionSpeedCalculationUseCaseImpl({
    required this._repository,
  });

  final EnteralNutritionSpeedRepository _repository;

  @override
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyVolume,
  }) async {
    try {
      final res = CalculateEnteralNutritionSpeed().call(
        totalDailyVolume: totalDailyVolume,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = EnteralNutritionSpeedCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "total_daily_volume_ml",
            label: "Volume Diário Total (mL)",
            value: totalDailyVolume,
          ),
        ],
      );

      return _repository.createEnteralNutritionSpeed(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
