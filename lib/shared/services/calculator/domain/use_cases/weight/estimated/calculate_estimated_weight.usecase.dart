// Peso Estimado= Peso Anterior / 1−% do segmento

// Valores de referência para segmento:
// Mão (0.7%),
// Antebraço (2.3%),
// Braço inteiro (6.5%),
// Pé (1.5%),
// Perna (5.9%),
// Coxa (11.6%).

import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/amputation_weight.enum.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEstimatedWeight {
  Result<double, String> call({
    required double kneeHeight,
    required double armCircumference,
    required Gender gender,
    required int age,
    required Ethnicity ethnicity,
    AmputationWeight? amputation,
  }) {
    try {
      if (age < 0 || kneeHeight < 0 || armCircumference < 0) {
        return Error("INVALID_PARAMS");
      }

      if (age > 80) {
        return Error("INVALID_AGE");
      }

      double Function(double, double)? formulae;

      switch (gender) {
        case .female:
          formulae = ethnicity == .white
              ? _getFemaleWhiteFormula(age)
              : _getFemaleBlackFormula(age);
        case .male:
          formulae = ethnicity == .white
              ? _getMaleWhiteFormula(age)
              : _getMaleBlackFormula(age);
      }

      double weight = formulae(kneeHeight, armCircumference);

      if (amputation != null) {
        weight = amputation.adjustWeightByAmputation(weight);
      }

      return Ok(weight);
    } catch (err) {
      return Error(err.toString());
    }
  }

  double Function(double kh, double ac) _getFemaleBlackFormula(int age) {
    if (age >= 19 && age <= 59) {
      return (kh, ac) => (kh * 1.24) + (ac * 2.97) - 82.48;
    }

    return (kh, ac) => (kh * 1.50) + (ac * 2.58) - 84.22;
  }

  double Function(double kh, double ac) _getFemaleWhiteFormula(int age) {
    if (age >= 19 && age <= 59) {
      return (kh, ac) => (kh * 1.01) + (ac * 2.81) - 66.04;
    }

    return (kh, ac) => (kh * 1.09) + (ac * 2.68) - 65.51;
  }

  double Function(double kh, double ac) _getMaleBlackFormula(int age) {
    if (age >= 19 && age <= 59) {
      return (kh, ac) => (kh * 1.09) + (ac * 3.14) - 83.72;
    }

    return (kh, ac) => (kh * 0.44) + (ac * 2.86) - 39.21;
  }

  double Function(double kh, double ac) _getMaleWhiteFormula(int age) {
    if (age >= 19 && age <= 59) {
      return (kh, ac) => (kh * 1.19) + (ac * 3.14) - 86.82;
    }

    return (kh, ac) => (kh * 1.10) + (ac * 3.07) - 75.81;
  }
}
