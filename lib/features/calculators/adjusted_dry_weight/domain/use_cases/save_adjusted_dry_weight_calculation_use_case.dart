import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/dry_weight.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adjusted/calculate_dry_weight.usecase.dart';

/// Wraps `CalculateDryWeight` unmodified and persists the result as a new
/// `WEIGHTS` row (`weightType: .adjustedDryWeight`), per ADR 0007's
/// "weight-producing calculators write into WEIGHTS, not their own table"
/// decision.
///
/// `CalculateDryWeight` returns a min/max range, but `WEIGHTS.value` is a
/// single double column - per Slice 10's po decision (2026-09-26), the
/// midpoint `(min + max) / 2` is persisted into `value` (so anything
/// downstream needing a single current-weight figure, e.g.
/// `resolveWeightForCalculations`, keeps working), while both bounds are
/// preserved losslessly in `inputParams` (`dry_weight_min_kg`/
/// `dry_weight_max_kg`) for display/traceability.
abstract class SaveAdjustedDryWeightCalculationUseCase {
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required Bmi imc,
    AscitisLevel? ascitis,
    OedemaLevel? oedema,
    required bool considerForCalculations,
  });
}

@Injectable(as: SaveAdjustedDryWeightCalculationUseCase)
class SaveAdjustedDryWeightCalculationUseCaseImpl
    implements SaveAdjustedDryWeightCalculationUseCase {
  const SaveAdjustedDryWeightCalculationUseCaseImpl({
    required this._createWeightUseCase,
  });

  final CreateWeightUseCase _createWeightUseCase;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required Bmi imc,
    AscitisLevel? ascitis,
    OedemaLevel? oedema,
    required bool considerForCalculations,
  }) async {
    try {
      final res = CalculateDryWeight().call(
        currentWeight: currentWeight,
        imc: imc,
        ascitis: ascitis,
        oedema: oedema,
      );

      if (res.isError) {
        return Error((res as Error<DryWeight, String>).error);
      }

      final dryWeight = (res as Ok<DryWeight, String>).value;

      final weight = WeightEntity(
        createdAt: DateTime.now(),
        // Midpoint-persisted/min-max-in-inputParams convention - see the
        // class doc above.
        value: (dryWeight.min + dryWeight.max) / 2,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adjustedDryWeight,
        inputParams: [
          InputParamEntity(
            key: "dry_weight_min_kg",
            label: "Peso Seco Mínimo (kg)",
            value: dryWeight.min,
          ),
          InputParamEntity(
            key: "dry_weight_max_kg",
            label: "Peso Seco Máximo (kg)",
            value: dryWeight.max,
          ),
          InputParamEntity(
            key: "current_weight_kg",
            label: "Peso Atual (kg)",
            value: currentWeight,
          ),
          InputParamEntity(key: "bmi", label: "IMC", value: imc.value),
          InputParamEntity(
            key: "ascitis",
            label: "Ascite",
            value: ascitis?.name,
          ),
          InputParamEntity(key: "oedema", label: "Edema", value: oedema?.name),
        ],
      );

      return _createWeightUseCase(weight: weight);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
