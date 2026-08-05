// TIG = (Glicose total g x 1000) / (1400 x peso corporal kg)

// Limite de segurança:
// Em adultos, o limite de oxidação de glicose costuma ser de 4 a 5 mg/kg/min.
// Acima disso, há risco metabólico.

import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateGlucoseInfusionRate {
  Result<double, String> call({
    required double totalGlucose,
    required double weight,
  }) {
    try {
      if (totalGlucose < 0 || weight < 0) {
        return Error("INVALID_PARAMS");
      }

      return Ok((totalGlucose * 1000) / (1400 * weight));
    } catch (err) {
      return Error(err.toString());
    }
  }
}
