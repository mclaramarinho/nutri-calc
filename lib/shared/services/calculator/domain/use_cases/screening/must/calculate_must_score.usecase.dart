// MUST
// Adultos/Idosos
// Risco de desnutrição (IMC + perda de peso + efeito da doença).

// Kondrup J, et al. ESPEN guidelines for nutritional screening 2002. Clin Nutr. 2003.
// Society of Critical Care Medicine/ASPEN. Guidelines for the Provision and Assessment of Nutrition Support Therapy in the Adult Critically Ill Patient. 2016.
// https://www.bapen.org.uk/images/pdfs/must/portuguese/must-toolkit.pdf

import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_result.entity.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateMustScore {
  Result<MustResult, String> call({
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
    required,
  }) {
    try {
      // STEP 1 - BMI
      final bmiScore = _classifyBmiScore(bmi);

      // STEP 2 - WEIGHT LOSS
      final weightLossScore = _classifyWeightLossScore(
        avgWeightLossIn3To6Months,
      );

      // STEP 3 - ILLNESS AND FOOD INTAKE
      int illnessScore = _classifyIllnessRisk(
        severeIllnessPresent: severeIllnessPresent,
        reducedFoodIntakeForMoreThan5Days: reducedFoodIntakeForMoreThan5Days,
        willReduceFoodIntakeForMoreThan5Days:
            willReduceFoodIntakeForMoreThan5Days,
      );

      // STEP 4 - GENERAL MALNUTRITION RISK
      final totalScore = bmiScore + weightLossScore + illnessScore;

      return Ok(
        MustResult(
          score: totalScore,
          scoreStep1: bmiScore,
          scoreStep2: weightLossScore,
          scoreStep3: illnessScore,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }

  int _classifyBmiScore(double bmi) {
    if (bmi > 20) return 0;
    if (bmi > 18.5 && bmi <= 20) return 1;
    return 2;
  }

  int _classifyWeightLossScore(double weightLoss) {
    if (weightLoss < 5) return 0;
    if (weightLoss >= 5 && weightLoss <= 10) return 1;
    return 2;
  }

  int _classifyIllnessRisk({
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  }) {
    final reducedFoodIntake =
        reducedFoodIntakeForMoreThan5Days ||
        willReduceFoodIntakeForMoreThan5Days;

    return severeIllnessPresent && reducedFoodIntake ? 2 : 0;
  }
}
