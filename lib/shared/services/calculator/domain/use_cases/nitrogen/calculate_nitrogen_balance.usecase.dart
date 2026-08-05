// BN = (proteina ingerida (g) / 6.25) / (nitrogenio urinario 24h + 4)

// Interpretação:
// Valor negativo indica catabolismo.
// Valor positivo indica anabolismo.
// O objetivo em pacientes críticos é alcançar o equilíbrio (BN≈0).

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateNitrogenBalance {
  Result<double, String> call({
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) {
    try {
      if (ingestedProtein < 0 || urineNitrogen24h < 0) {
        return Error("INVALID_PARAMS");
      }
      return Ok((ingestedProtein / 6.25) / (urineNitrogen24h / 4));
    } catch (err) {
      return Error(err.toString());
    }
  }
}
