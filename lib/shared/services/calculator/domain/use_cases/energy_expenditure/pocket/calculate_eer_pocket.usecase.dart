// Fonte: National Advisory Group on Standards and Practice Guidelines for Parenteral Nutrition, 1998.
// https://professor.pucgoias.edu.br/SiteDocente/admin/arquivosUpload/14052/material/Apostila%20Avaliação%20Nutricional.pdf

import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer_pocket.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEerPocket {
  Result<EERPocket, String> call({
    required double weight,
    StressLevel stressLevel = StressLevel.noStress,
  }) {
    try {
      double min, max;
      switch (stressLevel) {
        case .noStress:
          min = 22;
          max = 25;
          break;
        case .mildStress:
          min = 25;
          max = 27;
          break;
        case .moderateStress:
          min = 25;
          max = 30;
          break;
        case .severeStress:
          min = 30;
          max = 33;
          break;
        case .burnLessThan30Percent:
          min = 30;
          max = 35;
          break;
        case .obese:
          // Use adjusted weight
          min = 20;
          max = 22;
          break;
      }

      return Ok(EERPocket(min: min * weight, max: max * weight));
    } catch (err) {
      return Error(err.toString());
    }
  }
}
