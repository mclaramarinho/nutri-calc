// Velocidade (ml/h) = volume total diario (ml) / 24 (h)

import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEnteralNutritionSpeed {
  Result<double, String> call({required double totalDailyVolume}) {
    try {
      return Ok(totalDailyVolume / 24);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
