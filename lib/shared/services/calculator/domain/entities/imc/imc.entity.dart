import 'package:nutri_calc/shared/services/calculator/domain/entities/imc/imc_classification.enum.dart';

class Imc {
  final double value;
  final ImcClassification classification;

  const Imc({
    required this.value,
    required this.classification
  });
}