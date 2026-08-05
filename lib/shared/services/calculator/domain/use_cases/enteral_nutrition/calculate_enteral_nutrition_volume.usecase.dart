// Volumetotal(ml) = Kcal total diaria / Densidade calorica da dieta (kcal/ml)

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateEnteralNutritionVolume {
  Result<double, String> call({
    required double totalDailyEnergy, // kcal
    required double caloricDensityOfDiet, // kcal per ml
  }) {
    try {
      if (totalDailyEnergy < 0 || caloricDensityOfDiet < 0) {
        return Error("INVALID_PARAMS");
      }
      return Ok(totalDailyEnergy / caloricDensityOfDiet);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
