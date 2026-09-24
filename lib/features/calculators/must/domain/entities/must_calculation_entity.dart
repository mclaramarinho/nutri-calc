import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';

/// A persisted MUST (Malnutrition Universal Screening Tool) calculation for
/// a patient (the `SCREENING_MUST` table). Mirrors
/// `WeightLossClassificationCalculationEntity`'s shape - the per-step
/// scores plus the total `score`, the `classification` enum, and the
/// `inputParams` that produced it.
class MustCalculationEntity {
  final String? id;
  final String patientId;
  final int score;
  final int scoreStep1;
  final int scoreStep2;
  final int scoreStep3;
  final MustClassificationResult classification;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const MustCalculationEntity({
    required this.patientId,
    required this.score,
    required this.scoreStep1,
    required this.scoreStep2,
    required this.scoreStep3,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
