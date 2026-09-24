/// Single source of truth for the calculator id strings shared between
/// `patient_calculators_tab.dart`'s `CalculatorDefinition` registry and
/// `PatientDetailsCubit`/`PatientDetailsStateLoaded.calculatorStatuses`.
///
/// See ADR 0008 for the rationale.
class CalculatorIds {
  CalculatorIds._();

  static const String bmi = "bmi";
  static const String energyExpenditure = "energy_expenditure";
  static const String nitrogenBalance = "nitrogen_balance";
  static const String proteinNeeds = "protein_needs";
  static const String waterNeeds = "water_needs";
  static const String enteralNutritionDripping = "enteral_nutrition_dripping";
  static const String enteralNutritionSpeed = "enteral_nutrition_speed";
  static const String enteralNutritionVolume = "enteral_nutrition_volume";
  static const String glucoseInfusionRate = "glucose_infusion_rate";
  static const String weightLossClassification = "weight_loss_classification";
  static const String must = "must";
  static const String nrs2002 = "nrs_2002";
  static const String strongKids = "strong_kids";
  static const String idealWeight = "ideal_weight";
}
