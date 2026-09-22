enum EnergyExpenditureFormulaEnum {
  harrisBenedict,
  mifflin,
  pocket,
  schofield,
  who;

  String get label {
    switch (this) {
      case .harrisBenedict:
        return "Harris-Benedict";
      case .mifflin:
        return "Mifflin-St Jeor";
      case .pocket:
        return "Fórmula de Bolso";
      case .schofield:
        return "Schofield (crianças até 10 anos)";
      case .who:
        return "OMS (crianças até 18 anos)";
    }
  }
}
