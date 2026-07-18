import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateAdjustedObesityWeight {
  Result<double, String> call({
    required double idealWeight,
    required double currentWeight,
  }) {
    try {
      final weight = idealWeight + (0.4 * (currentWeight - idealWeight));
      return Ok(weight);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
