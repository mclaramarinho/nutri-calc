import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/ideal/calculate_ideal_weight.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// Wraps `CalculateIdealWeight` unmodified and persists the result as a new
/// `WEIGHTS` row (`weightType: .ideal`), per ADR 0007's "weight-producing
/// calculators write into WEIGHTS, not their own table" decision.
abstract class SaveIdealWeightCalculationUseCase {
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double heightCm,
    required Gender gender,
    required double weightKg,
    required bool considerForCalculations,
  });
}

@Injectable(as: SaveIdealWeightCalculationUseCase)
class SaveIdealWeightCalculationUseCaseImpl
    implements SaveIdealWeightCalculationUseCase {
  const SaveIdealWeightCalculationUseCaseImpl({
    required this._createWeightUseCase,
  });

  final CreateWeightUseCase _createWeightUseCase;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double heightCm,
    required Gender gender,
    required double weightKg,
    required bool considerForCalculations,
  }) async {
    try {
      // `weightKg` only feeds `CalculateIdealWeight`'s required `weight`
      // param (its `weight < 0` validation guard) - it plays no role in the
      // ideal-weight formula itself, which is `idealBmi * height^2`.
      // `amputation` is intentionally not exposed this slice (design's
      // explicit scoping - no amputation UI exists yet).
      final res = CalculateIdealWeight().call(
        weight: weightKg,
        height: heightCm / 100, // cm -> m, mirrors BMI's convention
        gender: gender,
        amputation: null,
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
        weightType: WeightTypeEnum.ideal,
        inputParams: [
          InputParamEntity(
            key: "height_cm",
            label: "Altura (cm)",
            value: heightCm,
          ),
          InputParamEntity(key: "gender", label: "Sexo", value: gender.name),
          // Passthrough value used only to satisfy the use case's
          // signature/validation guard - kept here for traceability.
          InputParamEntity(
            key: "weight_kg",
            label: "Peso (kg)",
            value: weightKg,
          ),
        ],
      );

      return _createWeightUseCase(weight: weight);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
