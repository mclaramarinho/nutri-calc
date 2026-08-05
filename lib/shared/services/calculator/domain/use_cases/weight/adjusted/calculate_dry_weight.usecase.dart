// Peso Ajustado para Edema/Ascite (Estimativa):
// Edema leve (pernas): subtrair 1 a 2 kg.
// Edema moderado (generalizado): subtrair 3 a 5 kg.
// Ascite leve: subtrair 2 kg.
// Ascite moderada: subtrair 4 a 6 kg.
// Ascite grave: subtrair 10 a 14 kg.

// Se o paciente tem obesidade, usa-se o peso ajustado para calcular a dieta.
// Peso Ajustado para Obesidade (IMC > 30):
// Peso Ajustado=(Peso Atual−Peso Ideal)×0.25+Peso Ideal

import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/dry_weight.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

// POP n. 01 - Hospital universitario Prof. Polydoro Ernani de Sao Thiago da Univ. Federal de Santa Catarina (2015)

class CalculateDryWeight {
  Result<DryWeight, String> call({
    required double currentWeight,
    required Bmi imc,
    AscitisLevel? ascitis,
    OedemaLevel? oedema,
  }) {
    try {
      if(currentWeight < 0) {
        return Error("INVALID_PARAMS");
      }

      final ascitisValue = ascitis?.value ?? 0;

      return Ok(
        DryWeight(
          min: currentWeight - ascitisValue - (oedema?.min ?? 0),
          max: currentWeight - ascitisValue - (oedema?.max ?? 0),
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
