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

import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEerHarrisBenedict {
  Result<double, String> call({
    required Gender gender,
    required double weight,
    required double height,
    required int age,
  }) {
    try {
      switch (gender) {
        case .female:
          return Ok(
            447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age),
          );
        case .male:
          return Ok(
            88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age),
          );
      }
    } catch (err) {
      return Error(err.toString());
    }
  }
}
