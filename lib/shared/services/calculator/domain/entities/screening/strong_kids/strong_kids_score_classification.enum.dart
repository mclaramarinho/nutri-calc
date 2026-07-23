enum StrongKidsScoreClassification {
  low(min: 0),
  medium(min: 1),
  highRisk(min: 4);

  final int min;
  const StrongKidsScoreClassification({required this.min});

  static StrongKidsScoreClassification getByScore(int score) {
    if (score >= 4) return .highRisk;
    if (score >= 1) return .medium;
    return .low;
  }
}
