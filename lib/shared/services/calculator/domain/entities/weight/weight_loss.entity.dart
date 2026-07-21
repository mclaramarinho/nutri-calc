import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';

class WeightLoss {
  final double percentage;
  final int timeReference;
  final WeightLossClassification classification;

  const WeightLoss({
    required this.percentage,
    required this.timeReference,
    required this.classification,
  });
}
