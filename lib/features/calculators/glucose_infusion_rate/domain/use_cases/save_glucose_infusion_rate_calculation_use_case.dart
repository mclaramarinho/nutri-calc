import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/repositories/glucose_infusion_rate_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/parenteral_nutrition/calculate_glucose_infusion_rate.usecase.dart';

abstract class SaveGlucoseInfusionRateCalculationUseCase {
  Future<Result<GlucoseInfusionRateCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double totalGlucose,
  });
}

@Injectable(as: SaveGlucoseInfusionRateCalculationUseCase)
class SaveGlucoseInfusionRateCalculationUseCaseImpl
    implements SaveGlucoseInfusionRateCalculationUseCase {
  const SaveGlucoseInfusionRateCalculationUseCaseImpl({
    required this._repository,
  });

  final GlucoseInfusionRateRepository _repository;

  @override
  Future<Result<GlucoseInfusionRateCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double totalGlucose,
  }) async {
    try {
      final res = CalculateGlucoseInfusionRate().call(
        totalGlucose: totalGlucose,
        weight: weightKg,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final entity = GlucoseInfusionRateCalculationEntity(
        patientId: patientId,
        value: value,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "weight_kg",
            label: "Peso (kg)",
            value: weightKg,
          ),
          InputParamEntity(
            key: "total_glucose_g",
            label: "Glicose Total (g)",
            value: totalGlucose,
          ),
        ],
      );

      return _repository.createGlucoseInfusionRate(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
