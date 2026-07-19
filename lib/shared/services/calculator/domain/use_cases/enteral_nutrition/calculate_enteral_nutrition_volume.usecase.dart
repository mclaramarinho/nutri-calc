// Volumetotal(ml) = Kcal total diaria / Densidade calorica da dieta (kcal/ml)

import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEnteralNutritionVolume {
  Result<double, String> call({
    required double totalDailyEnergy, // kcal
    required double caloricDensityOfDiet, // kcal per ml
  }) {
    try {
      return Ok(totalDailyEnergy / caloricDensityOfDiet);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
