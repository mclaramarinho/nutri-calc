/// One value per queryable history source (13 calculator tables + `weight`,
/// since `WEIGHTS` backs 5 `CalculatorType.weight` sub-types). Distinct from
/// `CalculatorType` (10 values, grouping) and `CalculatorIds` (18 values,
/// save-flow ids, ADR 0008). Keys the get/delete dispatch tables in
/// `GetPatientCalculatorHistoryUseCase`/`DeleteCalculatorHistoryEntryUseCase`.
/// See ADR 0009/0010.
enum HistorySourceType {
  bmi,
  energyExpenditure,
  nitrogenBalance,
  proteinNeeds,
  waterNeeds,
  enteralNutritionDripping,
  enteralNutritionSpeed,
  enteralNutritionVolume,
  glucoseInfusionRate,
  weightLossClassification,
  must,
  nrs2002,
  strongKids,
  weight,
}
