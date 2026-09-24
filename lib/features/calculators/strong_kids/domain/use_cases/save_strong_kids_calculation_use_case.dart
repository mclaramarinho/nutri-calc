import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/repositories/strong_kids_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/strong_kids/calculate_strong_kids_score.usecase.dart';

abstract class SaveStrongKidsCalculationUseCase {
  Future<Result<StrongKidsCalculationEntity, String>> call({
    required String patientId,
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  });
}

@Injectable(as: SaveStrongKidsCalculationUseCase)
class SaveStrongKidsCalculationUseCaseImpl
    implements SaveStrongKidsCalculationUseCase {
  const SaveStrongKidsCalculationUseCaseImpl({required this._repository});

  final StrongKidsRepository _repository;

  @override
  Future<Result<StrongKidsCalculationEntity, String>> call({
    required String patientId,
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  }) async {
    try {
      // Point mapping (roadmap-confirmed): q1/q2 are worth 2 points each,
      // q3/q4 are worth 1 point each.
      final res = CalculateStrongKidsScore().call(
        stepsResponsesInOrder: [
          clinicalAppearanceOfMalnutrition ? 2 : 0,
          highRiskDiseasePresent ? 2 : 0,
          reducedIntakeOrLosses ? 1 : 0,
          weightLossOrGrowthDeficit ? 1 : 0,
        ],
      );

      if (res.isError) {
        return Error((res as Error<StrongkidsResult, String>).error);
      }

      final strongKids = (res as Ok<StrongkidsResult, String>).value;

      final entity = StrongKidsCalculationEntity(
        patientId: patientId,
        score: strongKids.score,
        classification: strongKids.classification,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "clinical_appearance_of_malnutrition",
            label: "Aparência clínica sugestiva de desnutrição",
            value: clinicalAppearanceOfMalnutrition,
          ),
          InputParamEntity(
            key: "high_risk_disease_present",
            label: "Presença de doença de alto risco",
            value: highRiskDiseasePresent,
          ),
          InputParamEntity(
            key: "reduced_intake_or_losses",
            label: "Ingestão reduzida ou perdas",
            value: reducedIntakeOrLosses,
          ),
          InputParamEntity(
            key: "weight_loss_or_growth_deficit",
            label: "Perda de peso ou déficit de crescimento",
            value: weightLossOrGrowthDeficit,
          ),
        ],
      );

      return _repository.createStrongKidsCalculation(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
