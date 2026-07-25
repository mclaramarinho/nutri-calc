import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';

class Nrs2002QuestionnaireResponse {
  final bool lowBmi;
  final bool weightLossLast3Months;
  final bool reducedFoodIntakeLastWeek;
  final bool isSeverelyIll;

  final Nrs2002Step2Classification nutritionalStatusClassification;
  final Nrs2002Step2Classification illnessSeverityClassification;

  final int age;

  const Nrs2002QuestionnaireResponse({
    required this.age,
    required this.illnessSeverityClassification,
    required this.isSeverelyIll,
    required this.lowBmi,
    required this.nutritionalStatusClassification,
    required this.reducedFoodIntakeLastWeek,
    required this.weightLossLast3Months,
  });
}
