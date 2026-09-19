import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class CalculatorRelevanceContext {
  final int? age;
  final TimeUnit? ageUnit;
  final bool enteralNutrition;
  final bool parenteralNutrition;
  final bool hospitalized;
  final bool confinedToBed;
  final List<WeightEntity> weights;
  final Bmi? bmi;

  const CalculatorRelevanceContext({
    this.age,
    this.ageUnit,
    this.enteralNutrition = false,
    this.parenteralNutrition = false,
    this.hospitalized = false,
    this.confinedToBed = false,
    this.weights = const [],
    this.bmi,
  });
}
