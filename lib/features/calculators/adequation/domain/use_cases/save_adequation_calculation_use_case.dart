import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adequation/calculate_weight_adequation.usecase.dart';

/// Wraps `CalculateWeightAdequation` unmodified and persists the result as a
/// new `WEIGHTS` row (`weightType: .adequation`), per ADR 0007's
/// "weight-producing calculators write into WEIGHTS, not their own table"
/// decision. `value` is the computed adequation percentage, not a kg figure
/// (Slice 10 po decision, 2026-09-26) - display concerns for this live in
/// `patient_measurements_tab.dart`.
abstract class SaveAdequationCalculationUseCase {
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required double idealWeight,
    required bool considerForCalculations,
  });
}

@Injectable(as: SaveAdequationCalculationUseCase)
class SaveAdequationCalculationUseCaseImpl
    implements SaveAdequationCalculationUseCase {
  const SaveAdequationCalculationUseCaseImpl({
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
      final res = CalculateWeightAdequation().call(
        currentWeight: currentWeight,
        idealWeight: idealWeight,
      );

      if (res.isError) {
        return Error((res as Error<WeightAdequation, String>).error);
      }

      final adequation = (res as Ok<WeightAdequation, String>).value;

      final weight = WeightEntity(
        createdAt: DateTime.now(),
        value: adequation.value,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adequation,
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
          InputParamEntity(
            key: "classification",
            label: "Classificação",
            value: adequation.classification.name,
          ),
        ],
      );

      return _createWeightUseCase(weight: weight);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
