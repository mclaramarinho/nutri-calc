import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/estimated/calculate_estimated_weight.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// Wraps `CalculateEstimatedWeight` unmodified and persists the result as a
/// new `WEIGHTS` row (`weightType: .estimated`), per ADR 0007's
/// "weight-producing calculators write into WEIGHTS, not their own table"
/// decision.
abstract class SaveEstimatedWeightCalculationUseCase {
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double kneeHeight,
    required double armCircumference,
    required Gender gender,
    required int age,
    required Ethnicity ethnicity,
    required bool considerForCalculations,
  });
}

@Injectable(as: SaveEstimatedWeightCalculationUseCase)
class SaveEstimatedWeightCalculationUseCaseImpl
    implements SaveEstimatedWeightCalculationUseCase {
  const SaveEstimatedWeightCalculationUseCaseImpl({
    required this._createWeightUseCase,
  });

  final CreateWeightUseCase _createWeightUseCase;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double kneeHeight,
    required double armCircumference,
    required Gender gender,
    required int age,
    required Ethnicity ethnicity,
    required bool considerForCalculations,
  }) async {
    try {
      // KNOWN LIMITATION: amputation is scope-deferred (roadmap Slice 10 po
      // decision) even though it affects this formula's output, unlike
      // Ideal Weight where it was a no-op.
      final res = CalculateEstimatedWeight().call(
        kneeHeight: kneeHeight,
        armCircumference: armCircumference,
        gender: gender,
        age: age,
        ethnicity: ethnicity,
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
        weightType: WeightTypeEnum.estimated,
        inputParams: [
          InputParamEntity(
            key: "knee_height_cm",
            label: "Altura do Joelho (cm)",
            value: kneeHeight,
          ),
          InputParamEntity(
            key: "arm_circumference_cm",
            label: "Circunferência do Braço (cm)",
            value: armCircumference,
          ),
          InputParamEntity(key: "gender", label: "Sexo", value: gender.name),
          InputParamEntity(
            key: "ethnicity",
            label: "Etnia",
            value: ethnicity.name,
          ),
        ],
      );

      return _createWeightUseCase(weight: weight);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
