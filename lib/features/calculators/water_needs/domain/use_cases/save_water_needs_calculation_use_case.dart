import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/repositories/water_needs_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/water/calculate_water_needs.usecase.dart';

abstract class SaveWaterNeedsCalculationUseCase {
  Future<Result<WaterNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required int age,
  });
}

@Injectable(as: SaveWaterNeedsCalculationUseCase)
class SaveWaterNeedsCalculationUseCaseImpl
    implements SaveWaterNeedsCalculationUseCase {
  const SaveWaterNeedsCalculationUseCaseImpl({required this._repository});

  final WaterNeedsRepository _repository;

  @override
  Future<Result<WaterNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required int age,
  }) async {
    try {
      final res = CalculateWaterNeeds().call(weight: weightKg, age: age);

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = WaterNeedsCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "weight_kg",
            label: "Peso (kg)",
            value: weightKg,
          ),
          InputParamEntity(key: "age", label: "Idade", value: age),
        ],
      );

      return _repository.createWaterNeeds(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
