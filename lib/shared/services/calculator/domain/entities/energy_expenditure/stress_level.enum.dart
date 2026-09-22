enum StressLevel {
  noStress,
  mildStress,
  moderateStress,
  severeStress,
  burnLessThan30Percent,
  obese;

  String get label {
    switch (this) {
      case .noStress:
        return "Sem estresse";
      case .mildStress:
        return "Estresse leve";
      case .moderateStress:
        return "Estresse moderado";
      case .severeStress:
        return "Estresse grave";
      case .burnLessThan30Percent:
        return "Queimadura < 30%";
      case .obese:
        return "Obesidade";
    }
  }
}