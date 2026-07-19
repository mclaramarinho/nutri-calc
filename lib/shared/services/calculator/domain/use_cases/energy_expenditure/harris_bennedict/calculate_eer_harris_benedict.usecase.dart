// Equação de Harris-Benedict (Revisada 1984)
// Esta fórmula calcula o Gasto Energético Basal (GEB). Para obter o Gasto Energético Total (GET) em ambiente hospitalar, você deve multiplicar o resultado pelo Fator de Injúria/Estresse e Fator de Atividade.

// Homens:
// GEB=88.362+(13.397×peso)+(4.799×altura)−(5.677×idade)

// Mulheres:
// GEB=447.593+(9.247×peso)+(3.098×altura)−(4.330×idade)

// Legenda:
// Peso: kg
// Altura: cm
// Idade: anos

// https://espen.org/documents/A174-02PaedPNGuidel_ESPGHANESPENPNGuidelines2Energy.pdf

import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEerHarrisBenedict {
  Result<EER, String> call({
    required Gender gender,
    required double weight,
    required double height,
    required int age,
    required ActivityFactor activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
  }) {
    try {
      double eer;
      switch (gender) {
        case .female:
          eer = _calculateFemale(weight, height, age);
          break;
        case .male:
          eer = _calculateMale(weight, height, age);
          break;
      }

      return Ok(
        EER(
          eer: eer,
          injuryFactor: injuryFactor,
          activityFactor: activityFactor,
          temperatureFactor: temperatureFactor,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }

  double _calculateFemale(double weight, double height, int age) {
    if (age > 18) {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    return 655.10 + 9.56 * weight + 1.85 * height - 4.68 * age;
  }

  double _calculateMale(double weight, double height, int age) {
    if (age > 18) {
      return 66.47 + (13.75 * weight) + (5 * height) - (6.76 * age);
    }
    return 655.10 + 9.56 * weight + 1.85 * height - 4.68 * age;
  }
}
