import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';
// https://www.bapen.org.uk/images/pdfs/must/portuguese/must-exp-bk.pdf

class MustResult {
  final int score;
  final int scoreStep1;
  final int scoreStep2;
  final int scoreStep3;

  const MustResult({
    required this.score,
    required this.scoreStep1,
    required this.scoreStep2,
    required this.scoreStep3,
  });

  MustClassificationResult get classification {
    switch (score) {
      case 0:
        return .lowRisk;
      case 1:
        return .mediumRisk;
      default:
        return .highRisk;
    }
  }
}
