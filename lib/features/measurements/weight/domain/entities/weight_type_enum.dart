enum WeightTypeEnum {
  measuredByScale,
  adequation,
  adjustedDryWeight,
  adjustedObesity,
  estimated,
  ideal;

  static WeightTypeEnum fromJson(String value) {
    switch (value) {
      case "measuredByScale":
        return .measuredByScale;
      case "adequation":
        return .adequation;
      case "adjustedDryWeight":
        return .adjustedDryWeight;
      case "adjustedObesity":
        return .adjustedObesity;
      case "estimated":
        return .estimated;
      case "ideal":
        return .ideal;
      default:
        throw UnsupportedError("Unsupported weight type");
    }
  }

  String get label {
    switch (this) {
      case .measuredByScale:
        return "Medida por balança";
      case .adequation:
        return "Adequação";
      case .adjustedDryWeight:
        return "Ajustado - Peso seco";
      case .adjustedObesity:
        return "Ajustado - Obesidade";
      case .estimated:
        return "Estimado";
      case .ideal:
        return "Ideal";
    }
  }
}
