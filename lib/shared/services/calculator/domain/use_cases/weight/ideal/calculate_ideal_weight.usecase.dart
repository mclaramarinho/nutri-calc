// Fórmula do Peso Ideal (IMC Médio)
// Homens: IMC = 22
// Mulheres: IMC = 21
// Fórmula: Peso Ideal = IMC × Altura²

import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateIdealWeight {
  Result<double, String> call({
    required double weight,
    required double height,
    required Gender gender,
  }) {
    try {
      final idealBmi = gender == .female ? 21 : 22;
      final idealWeight = idealBmi * (height * height);

      return Ok(idealWeight);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
