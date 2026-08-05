// Adultos (19 a 59 anos) - Critério OMS
// Classificação        IMC (kg/m²)
// Baixo Peso	          < 18,5
// Eutrofia	            18,5 – 24,9
// Sobrepeso	          25,0 – 29,9
// Obesidade Grau I	    30,0 – 34,9
// Obesidade Grau II	  35,0 – 39,9
// Obesidade Grau III	  ≥ 40,0

// Idosos (≥ 60 anos) - Critério de Lipshitz (1994)
// Classificação	      IMC (kg/m²)
// Baixo Peso	          < 22,0
// Eutrofia	            22,0 – 27,0
// Sobrepeso	          > 27,0

import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

class CalculateBmi {
  Result<Bmi, String> call({
    required double weight,
    required double height,
    required int age,
  }) {
    try {
      final bmi = weight / (height * height);
      late BmiClassification classification;

      if (age < 60) {
        classification = _classifyAdult(bmi);
      } else {
        classification = _classifyElder(bmi);
      }
      return Ok(Bmi(value: bmi, classification: classification));
    } catch (err) {
      return Error(err.toString());
    }
  }

  BmiClassification _classifyAdult(double bmi) {
    if (bmi >= 40) {
      return .obesityGrade3;
    } else if (bmi >= 35) {
      return .obesityGrade2;
    } else if (bmi >= 30) {
      return .obesity;
    } else if (bmi >= 25) {
      return .overweight;
    } else if (bmi >= 18.5) {
      return .eutrophy;
    } else {
      return .low;
    }
  }

  BmiClassification _classifyElder(double bmi) {
    if (bmi > 27) {
      return .overweight;
    } else if (bmi >= 22) {
      return .eutrophy;
    } else {
      return .low;
    }
  }
}
