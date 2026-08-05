// Necessidade Hídrica:
// Adultos: 30 - 35 ml/kg/dia (ajustar em caso de insuficiência cardíaca ou renal).
// Idosos: 25 - 30 ml/kg/dia.

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateWaterNeeds {
  Result<double, String> call({required double weight, required int age}) {
    try {
      if (age < 0 || weight < 0) {
        return Error("INVALID_PARAMS");
      }
      
      return Ok(age >= 60 ? 25 * weight : 30 * weight);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
