// Gotas/min = Volume total (ml) / 3 x Tempo(h)

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateEnteralNutritionDripping {
  Result<double, String> call({
    required double totalVolume,
    required double totalHoursForVolume,
  }) {
    try {
      if (totalVolume < 0 || totalHoursForVolume < 0) {
        return Error("INVALID_PARAMS");
      }
      return Ok(totalVolume / (3 * totalHoursForVolume));
    } catch (err) {
      return Error(err.toString());
    }
  }
}
