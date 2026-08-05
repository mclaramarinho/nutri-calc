// STRONGkids
// Pediátrica
// Avalia risco em crianças hospitalizadas.

// Kondrup J, et al. ESPEN guidelines for nutritional screening 2002. Clin Nutr. 2003.
// Society of Critical Care Medicine/ASPEN. Guidelines for the Provision and Assessment of Nutrition Support Therapy in the Adult Critically Ill Patient. 2016.

import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_result.entity.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateStrongKidsScore {
  Result<StrongkidsResult, String> call({
    required List<int> stepsResponsesInOrder,
  }) {
    try {
      return Ok(
        StrongkidsResult(
          score: stepsResponsesInOrder.reduce((val, acc) => acc + val),
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
