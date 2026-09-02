enum BodyMeasurementTypeEnum {
  armCircumference,
  calfCircumference,
  waistCircumference,
  neckCircumference,
  kneeHeight;

  static BodyMeasurementTypeEnum fromJson(String value) {
    switch (value) {
      case "armCircumference":
        return .armCircumference;
      case "calfCircumference":
        return .calfCircumference;
      case "waistCircumference":
        return .waistCircumference;
      case "neckCircumference":
        return .neckCircumference;
      case "kneeHeight":
        return .kneeHeight;
      default:
        throw UnsupportedError("Unsupported body measurement type");
    }
  }

  String get label {
    switch(this) {
      case .armCircumference: return "Circ. de Braço";
      case .calfCircumference: return "Circ. de Panturrilha";
      case .waistCircumference: return "Circ. de Cintura";
      case .neckCircumference: return "Circ. de Pescoço";
      case .kneeHeight: return "Alt. do Joelho";
    }
  }
}
