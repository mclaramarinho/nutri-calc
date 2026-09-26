import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adjusted/calculate_adjusted_obesity_weight.usecase.dart';

/// Wraps `CalculateAdjustedObesityWeight` unmodified and persists the result
/// as a new `WEIGHTS` row (`weightType: .adjustedObesity`), per ADR 0007's
/// "weight-producing calculators write into WEIGHTS, not their own table"
/// decision.
abstract class SaveAdjustedObesityCalculationUseCase {
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required double idealWeight,
    required bool considerForCalculations,
  });
}

@Injectable(as: SaveAdjustedObesityCalculationUseCase)
class SaveAdjustedObesityCalculationUseCaseImpl
    implements SaveAdjustedObesityCalculationUseCase {
  const SaveAdjustedObesityCalculationUseCaseImpl({
    required this._createWeightUseCase,
  });

  final CreateWeightUseCase _createWeightUseCase;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required double idealWeight,
    required bool considerForCalculations,
  }) async {
    try {
      final res = CalculateAdjustedObesityWeight().call(
        idealWeight: idealWeight,
        currentWeight: currentWeight,
      );

      if (res.isError) {
        return Error((res as Error<double, String>).error);
      }

      final value = (res as Ok<double, String>).value;

      final weight = WeightEntity(
        createdAt: DateTime.now(),
        value: value,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adjustedObesity,
        inputParams: [
          InputParamEntity(
            key: "current_weight_kg",
            label: "Peso Atual (kg)",
            value: currentWeight,
          ),
          InputParamEntity(
            key: "ideal_weight_kg",
            label: "Peso Ideal (kg)",
            value: idealWeight,
          ),
        ],
      );

      return _createWeightUseCase(weight: weight);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
