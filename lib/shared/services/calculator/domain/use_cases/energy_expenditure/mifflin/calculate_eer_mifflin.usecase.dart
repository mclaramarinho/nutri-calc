// Mifflin-St Jeor (A mais validada para adultos saudáveis/clínicos):
// Homens: GET=(10×peso)+(6.25×altura)−(5×idade)+5
// Mulheres: GET=(10×peso)+(6.25×altura)−(5×idade)−161
// (Multiplicar pelo Fator de Atividade/Injúria, se necessário).

import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEerMifflin {
  Result<EER, String> call({
    required int age,
    required double height,
    required double weight,
    required Gender gender,
    required ActivityFactor activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
  }) {
    try {
      if (age < 0 || height < 0 || weight < 0) {
        return Error("INVALID_PARAMS");
      }
      
      double eer;

      switch (gender) {
        case .female:
          eer = (10 * weight) + (6.25 * height) - (5 * age) - 161;
        case .male:
          eer = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      }

      return Ok(
        EER(
          eer: eer,
          temperatureFactor: temperatureFactor,
          injuryFactor: injuryFactor,
          activityFactor: activityFactor,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
