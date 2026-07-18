import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

class Bmi {
  final double value;
  final BmiClassification classification;

  const Bmi({
    required this.value,
    required this.classification
  });
}