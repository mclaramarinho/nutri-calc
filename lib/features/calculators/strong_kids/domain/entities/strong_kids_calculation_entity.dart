import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';

/// A persisted STRONG-Kids (pediatric) screening calculation for a patient
/// (the `SCREENING_STRONG_KIDS` table). `inputParams` stores the raw
/// boolean answers to the 4 questions (not the computed point values), so
/// the exact clinical answers that produced the score can be reviewed
/// later.
class StrongKidsCalculationEntity {
  final String? id;
  final String patientId;
  final int score;
  final StrongKidsScoreClassification classification;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const StrongKidsCalculationEntity({
    required this.patientId,
    required this.score,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
