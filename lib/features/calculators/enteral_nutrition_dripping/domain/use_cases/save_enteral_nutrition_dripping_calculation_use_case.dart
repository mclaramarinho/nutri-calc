import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/repositories/enteral_nutrition_dripping_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_dripping.usecase.dart';

abstract class SaveEnteralNutritionDrippingCalculationUseCase {
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>> call({
    required String patientId,
    required double totalVolume,
    required double totalHoursForVolume,
  });
}

@Injectable(as: SaveEnteralNutritionDrippingCalculationUseCase)
class SaveEnteralNutritionDrippingCalculationUseCaseImpl
    implements SaveEnteralNutritionDrippingCalculationUseCase {
  const SaveEnteralNutritionDrippingCalculationUseCaseImpl({
    required this._repository,
  });

  final EnteralNutritionDrippingRepository _repository;

  @override
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>> call({
    required String patientId,
    required double totalVolume,
    required double totalHoursForVolume,
  }) async {
    try {
      final res = CalculateEnteralNutritionDripping().call(
        totalVolume: totalVolume,
        totalHoursForVolume: totalHoursForVolume,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = EnteralNutritionDrippingCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "total_volume_ml",
            label: "Volume Total (mL)",
            value: totalVolume,
          ),
          InputParamEntity(
            key: "total_hours_for_volume_h",
            label: "Tempo Total (h)",
            value: totalHoursForVolume,
          ),
        ],
      );

      return _repository.createEnteralNutritionDripping(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
