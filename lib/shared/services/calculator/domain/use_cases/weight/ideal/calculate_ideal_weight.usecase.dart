// Fórmula do Peso Ideal (IMC Médio)
// Homens: IMC = 22
// Mulheres: IMC = 21
// Fórmula: Peso Ideal = IMC × Altura²

import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/amputation_weight.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateIdealWeight {
  Result<double, String> call({
    required double weight,
    required double height,
    required Gender gender,
    AmputationWeight? amputation,
  }) {
    try {
      if (weight < 0 || height < 0) {
        return Error("INVALID_PARAMS");
      }

      final idealBmi = gender == .female ? 21 : 22;
      double idealWeight = idealBmi * (height * height);

      if (amputation != null) {
        idealWeight = amputation.adjustWeightByAmputation(idealWeight);
      }

      return Ok(idealWeight);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
