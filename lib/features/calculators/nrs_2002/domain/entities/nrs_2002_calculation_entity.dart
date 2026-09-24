import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// A persisted NRS-2002 (Nutritional Risk Screening 2002) calculation for a
/// patient (the `SCREENING_NRS_2002` table). No `classification` column -
/// `Nrs2002ScoreResult` has none; "risco nutricional identificado" at
/// score>=3 is display-only (computed at render time from `score`), never
/// persisted.
class Nrs2002CalculationEntity {
  final String? id;
  final String patientId;
  final int score;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const Nrs2002CalculationEntity({
    required this.patientId,
    required this.score,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
