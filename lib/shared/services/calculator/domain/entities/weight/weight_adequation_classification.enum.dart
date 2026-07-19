enum WeightAdequationClassification {
  severeMalnutrition(min: -1, max: 70),
  moderateMalnutrition(min: 70.1, max: 80),
  mildMalnutrition(min: 80.1, max: 90),
  eutrophy(min: 90.1, max: 110),
  overweight(min: 110.1, max: 120),
  obesity(min: 120, max: -1);

  final double min;
  final double max;

  const WeightAdequationClassification({required this.min, required this.max});

  static WeightAdequationClassification getByValue(double value) {
    if(value <= 70) return severeMalnutrition;

    if(value <= 80) return moderateMalnutrition;

    if(value <= 90) return mildMalnutrition;

    if(value <= 110) return eutrophy;

    if(value <= 120) return overweight;

    return obesity;
  }
}
