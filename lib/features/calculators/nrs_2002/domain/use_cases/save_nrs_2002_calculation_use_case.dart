import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/repositories/nrs_2002_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_questionnaire_response.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_score_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/nrs_2002/calculate_nrs_2002_score.usecase.dart';

abstract class SaveNrs2002CalculationUseCase {
  Future<Result<Nrs2002CalculationEntity, String>> call({
    required String patientId,
    required int age,
    required bool isSeverelyIll,
    required bool weightLossLast3Months,
    required bool reducedFoodIntakeLastWeek,
    required bool lowBmi,
    required Nrs2002Step2Classification nutritionalStatusClassification,
    required Nrs2002Step2Classification illnessSeverityClassification,
  });
}

@Injectable(as: SaveNrs2002CalculationUseCase)
class SaveNrs2002CalculationUseCaseImpl
    implements SaveNrs2002CalculationUseCase {
  const SaveNrs2002CalculationUseCaseImpl({required this._repository});

  final Nrs2002Repository _repository;

  @override
  Future<Result<Nrs2002CalculationEntity, String>> call({
    required String patientId,
    required int age,
    required bool isSeverelyIll,
    required bool weightLossLast3Months,
    required bool reducedFoodIntakeLastWeek,
    required bool lowBmi,
    required Nrs2002Step2Classification nutritionalStatusClassification,
    required Nrs2002Step2Classification illnessSeverityClassification,
  }) async {
    try {
      final response = Nrs2002QuestionnaireResponse(
        age: age,
        isSeverelyIll: isSeverelyIll,
        weightLossLast3Months: weightLossLast3Months,
        reducedFoodIntakeLastWeek: reducedFoodIntakeLastWeek,
        lowBmi: lowBmi,
        nutritionalStatusClassification: nutritionalStatusClassification,
        illnessSeverityClassification: illnessSeverityClassification,
      );

      final res = CalculateNrs2002Score().call(response);

      if (res.isError) {
        return Error((res as Error<Nrs2002ScoreResult, String>).error);
      }

      final score = (res as Ok<Nrs2002ScoreResult, String>).value.score;

      final entity = Nrs2002CalculationEntity(
        patientId: patientId,
        score: score,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(key: "age", label: "Idade", value: age),
          InputParamEntity(
            key: "is_severely_ill",
            label: "Paciente gravemente enfermo",
            value: isSeverelyIll,
          ),
          InputParamEntity(
            key: "weight_loss_last_3_months",
            label: "Perda de peso nos últimos 3 meses",
            value: weightLossLast3Months,
          ),
          InputParamEntity(
            key: "reduced_food_intake_last_week",
            label: "Redução da ingestão alimentar na última semana",
            value: reducedFoodIntakeLastWeek,
          ),
          InputParamEntity(key: "low_bmi", label: "IMC baixo", value: lowBmi),
          InputParamEntity(
            key: "nutritional_status_classification",
            label: "Estado Nutricional",
            value: nutritionalStatusClassification.name,
          ),
          InputParamEntity(
            key: "illness_severity_classification",
            label: "Gravidade da Doença",
            value: illnessSeverityClassification.name,
          ),
        ],
      );

      return _repository.createNrs2002Calculation(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
