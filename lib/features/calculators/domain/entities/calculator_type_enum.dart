enum CalculatorType {
  bmi,
  energyExpenditure,
  enteralNutrition,
  nitrogenBalance,
  parenteralNutrition,
  proteinNeeds,
  screening,
  waterNeeds,
  weight,
  weightLossClassification;

  String get label {
    switch (this) {
      case .bmi:
        return "IMC";
      case .energyExpenditure:
        return "Gasto Energético";
      case .enteralNutrition:
        return "Nutrição Enteral";
      case .nitrogenBalance:
        return "Balanço Nitrogenado";
      case .parenteralNutrition:
        return "Nutrição Parenteral";
      case .proteinNeeds:
        return "Necessidades Proteicas";
      case .screening:
        return "Triagem";
      case .waterNeeds:
        return "Necessidades Hídricas";
      case .weight:
        return "Peso";
      case .weightLossClassification:
        return "Classificação de Perda de Peso";
    }
  }
}
