import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/must/domain/repositories/must_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/must/calculate_must_score.usecase.dart';

abstract class SaveMustCalculationUseCase {
  Future<Result<MustCalculationEntity, String>> call({
    required String patientId,
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  });
}

@Injectable(as: SaveMustCalculationUseCase)
class SaveMustCalculationUseCaseImpl implements SaveMustCalculationUseCase {
  const SaveMustCalculationUseCaseImpl({required this._repository});

  final MustRepository _repository;

  @override
  Future<Result<MustCalculationEntity, String>> call({
    required String patientId,
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  }) async {
    try {
      // The dead `required` positional param on `CalculateMustScore.call()`
      // is intentionally left untouched/unpassed - see the use case file's
      // own doc.
      final res = CalculateMustScore().call(
        bmi: bmi,
        avgWeightLossIn3To6Months: avgWeightLossIn3To6Months,
        severeIllnessPresent: severeIllnessPresent,
        reducedFoodIntakeForMoreThan5Days: reducedFoodIntakeForMoreThan5Days,
        willReduceFoodIntakeForMoreThan5Days:
            willReduceFoodIntakeForMoreThan5Days,
      );

      if (res.isError) {
        return Error((res as Error<MustResult, String>).error);
      }

      final must = (res as Ok<MustResult, String>).value;

      final entity = MustCalculationEntity(
        patientId: patientId,
        score: must.score,
        scoreStep1: must.scoreStep1,
        scoreStep2: must.scoreStep2,
        scoreStep3: must.scoreStep3,
        classification: must.classification,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(key: "bmi", label: "IMC", value: bmi),
          InputParamEntity(
            key: "avg_weight_loss_3_6_months",
            label: "Perda de Peso Média (3-6 meses) (%)",
            value: avgWeightLossIn3To6Months,
          ),
          InputParamEntity(
            key: "severe_illness_present",
            label: "Doença grave presente",
            value: severeIllnessPresent,
          ),
          InputParamEntity(
            key: "reduced_food_intake_5_days",
            label: "Ingestão alimentar reduzida por mais de 5 dias",
            value: reducedFoodIntakeForMoreThan5Days,
          ),
          InputParamEntity(
            key: "will_reduce_food_intake_5_days",
            label: "Irá reduzir ingestão alimentar por mais de 5 dias",
            value: willReduceFoodIntakeForMoreThan5Days,
          ),
        ],
      );

      return _repository.createMustCalculation(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
