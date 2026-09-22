import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';

/// A persisted Weight Loss Classification calculation for a patient (the
/// `WEIGHT_LOSS_CLASSIFICATIONS` table). Mirrors `BmiCalculationEntity`'s
/// shape - a numeric result (`percentage`/`timeReference`) plus the
/// `classification` enum and the `inputParams` that produced it.
class WeightLossClassificationCalculationEntity {
  final String? id;
  final String patientId;
  final double percentage;
  final int timeReference;
  final WeightLossClassification classification;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const WeightLossClassificationCalculationEntity({
    required this.patientId,
    required this.percentage,
    required this.timeReference,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
