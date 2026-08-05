// Velocidade (ml/h) = volume total diario (ml) / 24 (h)

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateEnteralNutritionSpeed {
  Result<double, String> call({required double totalDailyVolume}) {
    try {
      if (totalDailyVolume < 0) {
        return Error("INVALID_PARAMS");
      }
      return Ok(totalDailyVolume / 24);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
