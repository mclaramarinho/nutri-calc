import 'package:nutri_calc/shared/utils/result/result.dart';

// REFERENCE
class CalculateAdjustedObesityWeight {
  Result<double, String> call({
    required double idealWeight,
    required double currentWeight,
  }) {
    try {
      if (idealWeight < 0 || currentWeight < 0) {
        return Error("INVALID_PARAMS");
      }
      final weight = idealWeight + (0.4 * (currentWeight - idealWeight));
      return Ok(weight);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
