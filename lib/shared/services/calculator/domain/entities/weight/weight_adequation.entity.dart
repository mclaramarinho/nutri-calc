import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation_classification.enum.dart';

class WeightAdequation {
  final WeightAdequationClassification classification;
  final double value;

  const WeightAdequation({
    required this.classification,
    required this.value
  });
}