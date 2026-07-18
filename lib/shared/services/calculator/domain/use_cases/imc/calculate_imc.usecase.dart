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

import 'package:nutri_calc/shared/services/calculator/domain/entities/imc/imc.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/imc/imc_classification.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateImc {
  Result<Imc, String> call({
    required double weight,
    required double height,
    required int age,
  }) {
    try {
      final imc = weight / (height * height);
      late ImcClassification classification;

      if (age < 60) {
        classification = _classificateAdult(imc);
      } else {
        classification = _classificateElder(imc);
      }
      return Ok(Imc(value: imc, classification: classification));
    } catch (err) {
      return Error(err.toString());
    }
  }

  ImcClassification _classificateAdult(double imc) {
    if (imc >= 40) {
      return .obesityGrade3;
    } else if (imc >= 35) {
      return .obesityGrade2;
    } else if (imc >= 30) {
      return .obesity;
    } else if (imc >= 25) {
      return .overweight;
    } else if (imc >= 18.5) {
      return .eutrophy;
    } else {
      return .low;
    }
  }

  ImcClassification _classificateElder(double imc) {
    if (imc > 27) {
      return .overweight;
    } else if (imc >= 22) {
      return .eutrophy;
    } else {
      return .low;
    }
  }
}
