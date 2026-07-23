import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';

class StrongkidsResult {
  final int score;

  const StrongkidsResult({required this.score});

  StrongKidsScoreClassification get classification =>
      StrongKidsScoreClassification.getByScore(score);
}
