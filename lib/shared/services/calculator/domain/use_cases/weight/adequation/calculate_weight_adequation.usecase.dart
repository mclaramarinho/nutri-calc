import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation_classification.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

// REFERENCE
class CalculateWeightAdequation {
  Result<WeightAdequation, String> call({
    required double currentWeight,
    required double idealWeight,
  }) {
    try {
      if (idealWeight < 0 || currentWeight < 0) {
        return Error("INVALID_PARAMS");
      }

      final val = (currentWeight * 100) / idealWeight;

      return Ok(
        WeightAdequation(
          classification: WeightAdequationClassification.getByValue(val),
          value: val,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
