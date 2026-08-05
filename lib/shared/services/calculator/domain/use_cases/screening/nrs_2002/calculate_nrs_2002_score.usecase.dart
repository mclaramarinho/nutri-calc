// NRS-2002
// Adultos/Idosos (Hospitalizados)
// Avalia estado nutricional + gravidade da doença.
// Escore ≥3 indica risco nutricional e necessidade de plano terapêutico.

// Kondrup J, et al. ESPEN guidelines for nutritional screening 2002. Clin Nutr. 2003.
// Society of Critical Care Medicine/ASPEN. Guidelines for the Provision and Assessment of Nutrition Support Therapy in the Adult Critically Ill Patient. 2016.
// https://www.avantenestle.com.br/sites/default/files/2021-03/Anexo_5_NRS.pdf

import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_questionnaire_response.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_score_result.entity.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateNrs2002Score {
  Result<Nrs2002ScoreResult, String> call(
    Nrs2002QuestionnaireResponse response,
  ) {
    try {
      final passedStep1 =
          response.isSeverelyIll ||
          response.weightLossLast3Months ||
          response.reducedFoodIntakeLastWeek ||
          response.lowBmi;

      if (passedStep1) {
        int score =
            response.illnessSeverityClassification.points +
            response.nutritionalStatusClassification.points;
        if (response.age > 70) score++;
        return Ok(Nrs2002ScoreResult(score: score));
      }

      return Ok(Nrs2002ScoreResult(score: 0));
    } catch (err) {
      return Error(err.toString());
    }
  }
}
